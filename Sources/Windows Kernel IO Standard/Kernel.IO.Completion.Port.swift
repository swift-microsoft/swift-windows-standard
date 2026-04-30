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
    public import Kernel_IO_Primitives
    public import WinSDK

    extension Windows.Kernel.IO.Completion {
        /// Raw I/O Completion Port wrappers (Windows only).
        ///
        /// I/O Completion Ports are the high-performance asynchronous I/O
        /// interface for Windows. This namespace provides policy-free syscall wrappers.
        ///
        /// Higher layers (swift-io) build registration management,
        /// handle tracking, and event dispatch on top of these primitives.
        ///
        /// ## Threading
        ///
        /// All operations in this namespace are **synchronous syscall wrappers**.
        /// They execute on the calling thread and return when the syscall completes.
        ///
        /// - `create`, `associate`, `post`, `close`: Non-blocking syscalls
        /// - `read`, `write`: Initiate async I/O, return immediately (`.pending` or `.completed`)
        /// - `Dequeue.single`, `Dequeue.batch`: **Block** until completion arrives or timeout expires
        public enum Port {

        }
    }

    // MARK: - Syscalls (raw @_spi(Syscall))

    extension Windows.Kernel.IO.Completion.Port {
        /// Creates a new I/O completion port.
        ///
        /// - Parameter threads: Maximum number of threads allowed to
        ///   concurrently process completions. Pass 0 to use the number of CPUs.
        /// - Returns: The port handle.
        /// - Throws: `Error.create` if creation fails.
        @inlinable
        public static func create(
            threads: UInt32 = 0
        ) throws(Error) -> Windows.Kernel.Descriptor {
            let handle = CreateIoCompletionPort(
                INVALID_HANDLE_VALUE,
                nil,
                0,
                DWORD(threads)
            )
            guard let handle, handle != INVALID_HANDLE_VALUE else {
                throw .create(.captureLastError())
            }
            return Windows.Kernel.Descriptor(rawValue: handle)
        }

        /// Associates a file handle bit pattern with a completion port bit pattern.
        ///
        /// Spec-literal raw `CreateIoCompletionPort`. The typed L2 convenience
        /// (`associate(_:handle:key:)` taking `Windows.Kernel.Descriptor`) delegates
        /// to this raw SPI internally via `descriptor._rawValue` after a
        /// fast-fail validity check.
        ///
        /// The file handle must have been opened with `FILE_FLAG_OVERLAPPED`.
        ///
        /// - Parameters:
        ///   - port: Port HANDLE bit pattern.
        ///   - handle: File HANDLE bit pattern to associate.
        ///   - key: Application-defined value returned with completions.
        /// - Throws: `Error.associate` if association fails.
        @_spi(Syscall)
        @inlinable
        public static func associate(
            _ port: UInt,
            handle: UInt,
            key: Key
        ) throws(Error) {
            let result = CreateIoCompletionPort(
                UnsafeMutableRawPointer(bitPattern: handle)!,
                UnsafeMutableRawPointer(bitPattern: port)!,
                key.rawValue,
                0
            )
            guard result != nil else {
                throw .associate(.captureLastError())
            }
        }

        /// Posts a completion packet to a port HANDLE bit pattern.
        ///
        /// Spec-literal raw `PostQueuedCompletionStatus`. The typed L2
        /// convenience (`post(_:bytes:key:overlapped:)` taking
        /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
        /// `descriptor._rawValue` after a fast-fail validity check.
        ///
        /// - Parameters:
        ///   - port: Port HANDLE bit pattern.
        ///   - bytes: Number of bytes to report.
        ///   - key: The completion key to return.
        ///   - overlapped: The overlapped pointer to return (can be nil).
        /// - Throws: `Error.post` on failure.
        @_spi(Syscall)
        @unsafe
        @inlinable
        public static func post(
            _ port: UInt,
            bytes: DWORD = 0,
            key: Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            let result = unsafe PostQueuedCompletionStatus(
                UnsafeMutableRawPointer(bitPattern: port)!,
                bytes,
                key.rawValue,
                overlapped
            )
            guard result else {
                throw .post(.captureLastError())
            }
        }

        /// Closes a port HANDLE bit pattern.
        ///
        /// Spec-literal raw delegate to `Windows.Kernel.Close.close(_:)`. The
        /// typed L2 convenience (`close(_:)` taking `Windows.Kernel.Descriptor`)
        /// delegates to this raw SPI internally via `descriptor._rawValue`
        /// after a fast-fail validity check.
        ///
        /// Fire-and-forget: errors are ignored. Any threads blocked in
        /// `Dequeue` will receive an error on their next dequeue attempt.
        ///
        /// - Parameter port: The port HANDLE bit pattern to close.
        @_spi(Syscall)
        @inlinable
        public static func close(_ port: UInt) {
            _ = Windows.Kernel.Close.close(port)
        }

        /// Initiates an overlapped read on a HANDLE bit pattern.
        ///
        /// Spec-literal raw `ReadFile` over an overlapped structure. The
        /// typed L2 convenience (`read(_:into:overlapped:)` taking
        /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
        /// `descriptor._rawValue` after a fast-fail validity check.
        ///
        /// - Parameters:
        ///   - handle: File HANDLE bit pattern (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to read into.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.read` on failure (excluding ERROR_IO_PENDING).
        @_spi(Syscall)
        @unsafe
        @inlinable
        public static func read(
            _ handle: UInt,
            into buffer: UnsafeMutableRawBufferPointer,
            overlapped: inout Overlapped
        ) throws(Error) -> Read.Result {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                ReadFile(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    buffer.baseAddress,
                    DWORD(buffer.count),
                    &count,
                    rawPtr
                )
            }

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
                return .pending
            }

            throw .read(.win32(UInt32(error)))
        }

        /// Initiates an overlapped write on a HANDLE bit pattern.
        ///
        /// Spec-literal raw `WriteFile` over an overlapped structure. The
        /// typed L2 convenience (`write(_:from:overlapped:)` taking
        /// `Windows.Kernel.Descriptor`) delegates to this raw SPI internally via
        /// `descriptor._rawValue` after a fast-fail validity check.
        ///
        /// - Parameters:
        ///   - handle: File HANDLE bit pattern (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to write from.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.write` on failure (excluding ERROR_IO_PENDING).
        @_spi(Syscall)
        @unsafe
        @inlinable
        public static func write(
            _ handle: UInt,
            from buffer: UnsafeRawBufferPointer,
            overlapped: inout Overlapped
        ) throws(Error) -> Write.Result {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                WriteFile(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    buffer.baseAddress,
                    DWORD(buffer.count),
                    &count,
                    rawPtr
                )
            }

            if success {
                return .completed(bytes: count)
            }

            let error = GetLastError()
            if error == Error.Code.IO.pending {
                return .pending
            }

            throw .write(.win32(UInt32(error)))
        }

        /// Gets the result of a completed overlapped operation on a HANDLE bit pattern.
        ///
        /// Spec-literal raw `GetOverlappedResult`. The typed L2 convenience
        /// (`result(_:overlapped:wait:)` taking `Windows.Kernel.Descriptor`)
        /// delegates to this raw SPI internally via `descriptor._rawValue`
        /// after a fast-fail validity check.
        ///
        /// - Parameters:
        ///   - handle: File HANDLE bit pattern.
        ///   - overlapped: The overlapped structure.
        ///   - wait: If `true`, blocks until the operation completes.
        /// - Returns: The number of bytes transferred.
        /// - Throws: `Error.result` on failure.
        @_spi(Syscall)
        @inlinable
        public static func result(
            _ handle: UInt,
            overlapped: inout Overlapped,
            wait: Bool = false
        ) throws(Error) -> UInt32 {
            var count: DWORD = 0
            let success = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                GetOverlappedResult(
                    UnsafeMutableRawPointer(bitPattern: handle)!,
                    rawPtr,
                    &count,
                    wait
                )
            }

            if success {
                return count
            }

            throw .result(.captureLastError())
        }
    }

    // MARK: - Typed Convenience

    extension Windows.Kernel.IO.Completion.Port {
        /// Associates a file handle with the completion port.
        ///
        /// Typed L2 form. Delegates to the raw `associate(_:handle:key:)` SPI
        /// via `descriptor._rawValue`. The file handle must have been opened
        /// with `FILE_FLAG_OVERLAPPED`.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - handle: The file handle to associate.
        ///   - key: Application-defined value returned with completions.
        /// - Throws: `Error.associate` if association fails.
        @inlinable
        public static func associate(
            _ port: Windows.Kernel.Descriptor,
            handle: Windows.Kernel.Descriptor,
            key: Key
        ) throws(Error) {
            try associate(port._rawValue, handle: handle._rawValue, key: key)
        }

        /// Posts a completion packet to the port.
        ///
        /// Typed L2 form. Delegates to the raw `post(_:bytes:key:overlapped:)`
        /// SPI via `descriptor._rawValue`. This can be used to wake up a
        /// thread waiting on the port, or to manually signal completion of
        /// an operation.
        ///
        /// - Parameters:
        ///   - port: The port handle.
        ///   - bytes: Number of bytes to report.
        ///   - key: The completion key to return.
        ///   - overlapped: The overlapped pointer to return (can be nil).
        /// - Throws: `Error.post` on failure.
        @unsafe
        @inlinable
        public static func post(
            _ port: Windows.Kernel.Descriptor,
            bytes: DWORD = 0,
            key: Key = .zero,
            overlapped: LPOVERLAPPED? = nil
        ) throws(Error) {
            try unsafe post(port._rawValue, bytes: bytes, key: key, overlapped: overlapped)
        }

        /// Closes the completion port.
        ///
        /// Typed L2 form. Delegates to the raw `close(_:)` SPI via
        /// `descriptor._rawValue`. Fire-and-forget: errors are ignored.
        /// Any threads blocked in `Dequeue` will receive an error on their
        /// next dequeue attempt.
        ///
        /// - Parameter port: The port handle to close.
        @inlinable
        public static func close(_ port: Windows.Kernel.Descriptor) {
            close(port._rawValue)
        }

        /// Initiates an overlapped read operation.
        ///
        /// Typed L2 form. Delegates to the raw `read(_:into:overlapped:)` SPI
        /// via `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - handle: The file handle (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to read into.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.read` on failure (excluding ERROR_IO_PENDING).
        @unsafe
        @inlinable
        public static func read(
            _ handle: Windows.Kernel.Descriptor,
            into buffer: UnsafeMutableRawBufferPointer,
            overlapped: inout Overlapped
        ) throws(Error) -> Read.Result {
            try unsafe read(handle._rawValue, into: buffer, overlapped: &overlapped)
        }

        /// Initiates an overlapped write operation.
        ///
        /// Typed L2 form. Delegates to the raw `write(_:from:overlapped:)` SPI
        /// via `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - handle: The file handle (must be opened with FILE_FLAG_OVERLAPPED).
        ///   - buffer: The buffer to write from.
        ///   - overlapped: The overlapped structure for this operation.
        /// - Returns: `.pending` if async, `.completed(bytes:)` if sync completion.
        /// - Throws: `Error.write` on failure (excluding ERROR_IO_PENDING).
        @unsafe
        @inlinable
        public static func write(
            _ handle: Windows.Kernel.Descriptor,
            from buffer: UnsafeRawBufferPointer,
            overlapped: inout Overlapped
        ) throws(Error) -> Write.Result {
            try unsafe write(handle._rawValue, from: buffer, overlapped: &overlapped)
        }

        /// Gets the result of a completed overlapped operation.
        ///
        /// Typed L2 form. Delegates to the raw `result(_:overlapped:wait:)`
        /// SPI via `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - handle: The file handle.
        ///   - overlapped: The overlapped structure.
        ///   - wait: If `true`, blocks until the operation completes.
        /// - Returns: The number of bytes transferred.
        /// - Throws: `Error.result` on failure.
        @inlinable
        public static func result(
            _ handle: Windows.Kernel.Descriptor,
            overlapped: inout Overlapped,
            wait: Bool = false
        ) throws(Error) -> UInt32 {
            try result(handle._rawValue, overlapped: &overlapped, wait: wait)
        }
    }

#endif
