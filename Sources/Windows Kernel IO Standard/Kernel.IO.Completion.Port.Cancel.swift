// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    public import Kernel_IO_Primitives
    public import Kernel_File_Primitives
    public import WinSDK

    extension Kernel.IO.Completion.Port {
        /// Operations for cancelling pending I/O on port-associated handles.
        ///
        /// Provides both fire-and-forget and status-returning variants for
        /// cancelling all pending operations or specific operations.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Cancel all pending I/O on a handle
        /// Kernel.IO.Completion.Port.Cancel.all(handle)
        ///
        /// // Cancel a specific operation
        /// Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: &myOverlapped)
        ///
        /// // Check if cancellation succeeded (using nested accessor)
        /// if Kernel.IO.Completion.Port.Cancel.all(handle).status {
        ///     // Operations were cancelled
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Overlapped``
        public enum Cancel {}
    }

    // MARK: - Raw Syscalls (@_spi(Syscall))

    extension Kernel.IO.Completion.Port.Cancel {
        /// Cancels all pending I/O on a HANDLE bit pattern (raw `CancelIoEx`).
        ///
        /// Spec-literal raw `CancelIoEx(handle, nil)`. The typed L2 accessor
        /// (`Cancel.all(_ descriptor:)` returning `All`) delegates to this raw
        /// SPI internally via `descriptor._rawValue`.
        ///
        /// - Parameter handle: HANDLE bit pattern.
        /// - Returns: `true` if cancelled, `false` otherwise (use `GetLastError`
        ///   to inspect the failure mode).
        @_spi(Syscall)
        @inlinable
        public static func all(_ handle: UInt) -> Bool {
            CancelIoEx(UnsafeMutableRawPointer(bitPattern: handle)!, nil)
        }

        /// Cancels a specific pending I/O on a HANDLE bit pattern (raw `CancelIoEx`).
        ///
        /// Spec-literal raw `CancelIoEx(handle, overlapped)`. The typed L2
        /// accessor (`Cancel.pending(_ descriptor:overlapped:)` returning
        /// `Pending`) delegates to this raw SPI internally via
        /// `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - handle: HANDLE bit pattern.
        ///   - overlapped: The OVERLAPPED pointer for the operation to cancel.
        /// - Returns: `true` if cancelled, `false` otherwise (use `GetLastError`
        ///   to inspect the failure mode).
        @_spi(Syscall)
        @unsafe
        @inlinable
        public static func pending(_ handle: UInt, overlapped: LPOVERLAPPED) -> Bool {
            unsafe CancelIoEx(UnsafeMutableRawPointer(bitPattern: handle)!, overlapped)
        }
    }

    // MARK: - Cancel All

    extension Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling all pending I/O operations.
        public struct All: Sendable {
            @usableFromInline
            let descriptor: Kernel.Descriptor

            @usableFromInline
            init(_ descriptor: Kernel.Descriptor) {
                self.descriptor = descriptor
            }

            /// Cancels all pending I/O (fire-and-forget).
            ///
            /// Delegates to the raw `Cancel.all(_:)` SPI via
            /// `descriptor._rawValue`. Returns silently if no operations are
            /// pending.
            @inlinable
            public func callAsFunction() {
                _ = Kernel.IO.Completion.Port.Cancel.all(descriptor._rawValue)
            }

            /// Returns whether cancellation succeeded.
            ///
            /// Delegates to the raw `Cancel.all(_:)` SPI via
            /// `descriptor._rawValue`.
            ///
            /// - Returns: `true` if cancelled, `false` if no pending operations.
            @inlinable
            public var status: Bool {
                if Kernel.IO.Completion.Port.Cancel.all(descriptor._rawValue) {
                    return true
                }
                return GetLastError() != Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            }
        }

        /// Cancels all pending I/O on a handle.
        ///
        /// Typed L2 form. Returns an accessor whose
        /// ``All/callAsFunction()``/``All/status`` delegate to the raw
        /// `Cancel.all(_:)` SPI via `descriptor._rawValue`.
        ///
        /// - Parameter descriptor: The descriptor with pending I/O.
        /// - Returns: An accessor for cancel operations.
        @inlinable
        public static func all(_ descriptor: Kernel.Descriptor) -> All {
            All(descriptor)
        }
    }

    // MARK: - Cancel Specific

    extension Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling a specific pending I/O operation.
        @safe
        public struct Pending: @unchecked Sendable {
            @usableFromInline
            let descriptor: Kernel.Descriptor

            @usableFromInline
            let overlappedPtr: UnsafeMutablePointer<Kernel.IO.Completion.Port.Overlapped>

            @unsafe
            @usableFromInline
            init(_ descriptor: Kernel.Descriptor, overlapped: UnsafeMutablePointer<Kernel.IO.Completion.Port.Overlapped>) {
                self.descriptor = descriptor
                unsafe { self.overlappedPtr = overlapped }
            }

            /// Cancels the specific pending I/O (fire-and-forget).
            ///
            /// Delegates to the raw `Cancel.pending(_:overlapped:)` SPI via
            /// `descriptor._rawValue`. Returns silently if the operation
            /// already completed.
            @inlinable
            public func callAsFunction() {
                let ptr = unsafe overlappedPtr
                _ = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                    Kernel.IO.Completion.Port.Cancel.pending(descriptor._rawValue, overlapped: rawPtr)
                }
            }

            /// Returns whether cancellation succeeded.
            ///
            /// Delegates to the raw `Cancel.pending(_:overlapped:)` SPI via
            /// `descriptor._rawValue`.
            ///
            /// - Returns: `true` if cancelled, `false` if already completed.
            @inlinable
            public var status: Bool {
                let ptr = unsafe overlappedPtr
                let result = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                    Kernel.IO.Completion.Port.Cancel.pending(descriptor._rawValue, overlapped: rawPtr)
                }
                if result {
                    return true
                }
                return GetLastError() != Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            }
        }

        /// Cancels a specific pending I/O operation.
        ///
        /// Typed L2 form. Returns an accessor whose
        /// ``Pending/callAsFunction()``/``Pending/status`` delegate to the raw
        /// `Cancel.pending(_:overlapped:)` SPI via `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: The overlapped structure for the operation to cancel.
        /// - Returns: An accessor for cancel operations.
        @inlinable
        public static func pending(
            _ descriptor: Kernel.Descriptor,
            overlapped: inout Kernel.IO.Completion.Port.Overlapped
        ) -> Pending {
            unsafe withUnsafeMutablePointer(to: &overlapped) { ptr in
                unsafe Pending(descriptor, overlapped: ptr)
            }
        }

        /// Cancels a specific pending I/O operation via pointer.
        ///
        /// Typed L2 form. Returns an accessor whose
        /// ``Pending/callAsFunction()``/``Pending/status`` delegate to the raw
        /// `Cancel.pending(_:overlapped:)` SPI via `descriptor._rawValue`.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: Pointer to the overlapped structure for the operation to cancel.
        /// - Returns: An accessor for cancel operations.
        @unsafe
        @inlinable
        public static func pending(
            _ descriptor: Kernel.Descriptor,
            overlapped: UnsafeMutablePointer<Kernel.IO.Completion.Port.Overlapped>
        ) -> Pending {
            unsafe Pending(descriptor, overlapped: overlapped)
        }
    }

#endif
