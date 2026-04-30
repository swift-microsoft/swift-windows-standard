// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.Kernel.IO.Completion.Port {
        /// Operations for retrieving completed I/O from a port.
        ///
        /// Provides both single-entry and batch dequeue operations. Batch
        /// dequeuing is more efficient when multiple completions are expected.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Single completion
        /// let item = try Windows.Kernel.IO.Completion.Port.Dequeue.single(port, timeout: INFINITE)
        /// switch item.status {
        /// case .ok:
        ///     // I/O completed successfully
        ///     print("Transferred \(item.bytes) bytes")
        /// case .platform(let code):
        ///     // I/O failed but was dequeued
        ///     print("Operation failed: \(code)")
        /// }
        ///
        /// // Batch completion (more efficient)
        /// var entries = [OVERLAPPED_ENTRY](repeating: .init(), count: 64)
        /// let count = try entries.withUnsafeMutableBufferPointer { buffer in
        ///     try Windows.Kernel.IO.Completion.Port.Dequeue.batch(port, entries: buffer, timeout: 100)
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Entry``
        /// - ``Kernel/IO/Completion/Port/Key``
        public enum Dequeue {

        }
    }

    // MARK: - Status

    extension Windows.Kernel.IO.Completion.Port.Dequeue {
        /// Status of a completed I/O operation.
        @frozen
        public enum Status: Sendable, Equatable {
            /// The I/O operation completed successfully.
            case ok

            /// The I/O operation completed with a platform error.
            case platform(Error_Primitives.Error)
        }
    }

    // MARK: - Item

    extension Windows.Kernel.IO.Completion.Port.Dequeue {
        /// A dequeued I/O completion.
        ///
        /// - Important: `overlapped` points to storage that must remain valid until
        ///   the completion is fully processed. This type is `@unchecked Sendable`
        ///   for IOCP usage; callers must ensure correct lifetime and synchronization
        ///   of the pointed-to storage.
        @safe
        @frozen
        public struct Item: @unchecked Sendable {
            /// Number of bytes transferred.
            public let bytes: UInt32

            /// Application-defined completion key.
            public let key: Windows.Kernel.IO.Completion.Port.Key

            /// Pointer to the Overlapped structure associated with the operation.
            ///
            /// May be `nil` for synthetic completions posted via `PostQueuedCompletionStatus`
            /// without an associated overlapped structure.
            public let overlapped: UnsafeMutablePointer<Windows.Kernel.IO.Completion.Port.Overlapped>?

            /// Status of the completed I/O operation.
            public let status: Status

            @unsafe
            @inlinable
            public init(
                bytes: UInt32,
                key: Windows.Kernel.IO.Completion.Port.Key,
                overlapped: UnsafeMutablePointer<Windows.Kernel.IO.Completion.Port.Overlapped>?,
                status: Status
            ) {
                self.bytes = bytes
                self.key = key
                unsafe { self.overlapped = overlapped }
                self.status = status
            }
        }
    }

    // MARK: - Operations (raw @_spi(Syscall))

    extension Windows.Kernel.IO.Completion.Port.Dequeue {
        /// Dequeues a single completion packet from a port HANDLE bit pattern.
        ///
        /// Spec-literal raw `GetQueuedCompletionStatus`. The typed L2
        /// convenience (`single(_:timeout:)` taking `Windows.Kernel.Descriptor`)
        /// delegates to this raw SPI internally via `descriptor._rawValue`.
        ///
        /// - Note: This operation **blocks the calling thread** until a completion
        ///   arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: Port HANDLE bit pattern.
        ///   - timeout: Timeout in milliseconds (`Windows.Kernel.IO.Completion.Port.Error.Timeout.infinite` = 0xFFFFFFFF).
        /// - Returns: The dequeued completion item.
        /// - Throws: `.timeout` on timeout, `.dequeue` only on actual port failure.
        ///   Operation failures are returned via `Item.status`.
        @_spi(Syscall)
        @inlinable
        public static func single(
            _ port: UInt,
            timeout: UInt32
        ) throws(Windows.Kernel.IO.Completion.Port.Error) -> Item {
            var bytes: DWORD = 0
            var key: ULONG_PTR = 0
            var overlapped: LPOVERLAPPED? = nil

            let ok = unsafe GetQueuedCompletionStatus(
                UnsafeMutableRawPointer(bitPattern: port)!,
                &bytes,
                &key,
                &overlapped,
                DWORD(timeout)
            )

            // Helper to convert raw pointer to Swift wrapper pointer
            @unsafe
            func toOverlapped(_ raw: LPOVERLAPPED?) -> UnsafeMutablePointer<Windows.Kernel.IO.Completion.Port.Overlapped>? {
                guard let raw = unsafe raw else { return nil }
                return unsafe UnsafeMutableRawPointer(raw)
                    .assumingMemoryBound(to: Windows.Kernel.IO.Completion.Port.Overlapped.self)
            }

            if ok {
                return unsafe Item(
                    bytes: UInt32(bytes),
                    key: Windows.Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: toOverlapped(overlapped),
                    status: .ok
                )
            }

            let error = GetLastError()

            if error == WAIT_TIMEOUT {
                throw .timeout
            }

            let overlappedPtr = unsafe overlapped
            if overlappedPtr != nil {
                // Correct: dequeued completion of a FAILED I/O operation
                return unsafe Item(
                    bytes: UInt32(bytes),
                    key: Windows.Kernel.IO.Completion.Port.Key(rawValue: key),
                    overlapped: toOverlapped(overlapped),
                    status: .platform(Error_Primitives.Error(code: .win32(error)))
                )
            }

            // Correct: true port-level failure
            throw .dequeue(.win32(error))
        }

        /// Dequeues multiple completion packets (batch) from a port HANDLE bit pattern.
        ///
        /// Spec-literal raw `GetQueuedCompletionStatusEx`. The typed L2
        /// convenience (`batch(_:entries:timeout:)` taking `Windows.Kernel.Descriptor`)
        /// delegates to this raw SPI internally via `descriptor._rawValue`.
        ///
        /// More efficient than calling `single` in a loop when multiple
        /// completions are expected.
        ///
        /// - Note: This operation **blocks the calling thread** until at least one
        ///   completion arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: Port HANDLE bit pattern.
        ///   - entries: Buffer for completion entries.
        ///   - timeout: Timeout in milliseconds.
        /// - Returns: Number of entries dequeued (0 on timeout).
        /// - Throws: `Error.dequeue` on failure.
        @_spi(Syscall)
        @unsafe
        @inlinable
        public static func batch(
            _ port: UInt,
            entries: UnsafeMutableBufferPointer<Windows.Kernel.IO.Completion.Port.Entry>,
            timeout: UInt32
        ) throws(Windows.Kernel.IO.Completion.Port.Error) -> Int {
            guard let base = unsafe entries.baseAddress else { return 0 }

            // Entry is a transparent wrapper around OVERLAPPED_ENTRY,
            // so we can safely reinterpret the buffer pointer
            let rawBase = unsafe UnsafeMutableRawPointer(base)
                .assumingMemoryBound(to: OVERLAPPED_ENTRY.self)

            var removed: ULONG = 0
            let result = unsafe GetQueuedCompletionStatusEx(
                UnsafeMutableRawPointer(bitPattern: port)!,
                rawBase,
                ULONG(entries.count),
                &removed,
                DWORD(timeout),
                false  // Not alertable
            )

            if !result {
                let error = GetLastError()
                if error == WAIT_TIMEOUT {
                    return 0
                }
                throw .dequeue(.win32(UInt32(error)))
            }

            return Int(removed)
        }
    }

    // MARK: - Typed Convenience

    extension Windows.Kernel.IO.Completion.Port.Dequeue {
        /// Dequeues a single completion packet.
        ///
        /// Typed L2 form. Delegates to the raw `single(_:timeout:)` SPI via
        /// `descriptor._rawValue`.
        ///
        /// - Note: This operation **blocks the calling thread** until a completion
        ///   arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - timeout: Timeout in milliseconds (`Windows.Kernel.IO.Completion.Port.Error.Timeout.infinite` = 0xFFFFFFFF).
        /// - Returns: The dequeued completion item.
        /// - Throws: `.timeout` on timeout, `.dequeue` only on actual port failure.
        ///   Operation failures are returned via `Item.status`.
        @inlinable
        public static func single(
            _ port: Windows.Kernel.Descriptor,
            timeout: UInt32
        ) throws(Windows.Kernel.IO.Completion.Port.Error) -> Item {
            try single(port._rawValue, timeout: timeout)
        }

        /// Dequeues multiple completion packets (batch).
        ///
        /// Typed L2 form. Delegates to the raw `batch(_:entries:timeout:)`
        /// SPI via `descriptor._rawValue`.
        ///
        /// - Note: This operation **blocks the calling thread** until at least one
        ///   completion arrives or the timeout expires. For non-blocking polling, use `timeout: 0`.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - entries: Buffer for completion entries.
        ///   - timeout: Timeout in milliseconds.
        /// - Returns: Number of entries dequeued (0 on timeout).
        /// - Throws: `Error.dequeue` on failure.
        @unsafe
        @inlinable
        public static func batch(
            _ port: Windows.Kernel.Descriptor,
            entries: UnsafeMutableBufferPointer<Windows.Kernel.IO.Completion.Port.Entry>,
            timeout: UInt32
        ) throws(Windows.Kernel.IO.Completion.Port.Error) -> Int {
            try unsafe batch(port._rawValue, entries: entries, timeout: timeout)
        }
    }

#endif
