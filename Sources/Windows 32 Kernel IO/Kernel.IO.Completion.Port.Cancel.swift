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
    public import WinSDK

    extension Windows.`32`.Kernel.IO.Completion.Port {
        /// Operations for cancelling pending I/O on port-associated handles.
        ///
        /// Provides both fire-and-forget and status-returning variants for
        /// cancelling all pending operations or specific operations.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Cancel all pending I/O on a handle
        /// Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle)
        ///
        /// // Cancel a specific operation
        /// Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: &myOverlapped)
        ///
        /// // Check if cancellation succeeded (using nested accessor)
        /// if Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle).status {
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

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {
        /// Cancels all pending I/O on a HANDLE bit pattern (raw `CancelIoEx`).
        ///
        /// Spec-literal raw `CancelIoEx(handle, nil)`. The typed L2 accessor
        /// (`Cancel.all(_ descriptor:)` returning `All`) delegates to this raw
        /// SPI internally via `descriptor._rawValue`.
        ///
        /// - Parameter handle: HANDLE bit pattern.
        /// - Returns: `true` if cancelled, `false` otherwise (use `GetLastError`
        ///   to inspect the failure mode).
        @inlinable
        package static func all(_ handle: UInt) -> Bool {
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
        @unsafe
        @inlinable
        package static func pending(_ handle: UInt, overlapped: LPOVERLAPPED) -> Bool {
            unsafe CancelIoEx(UnsafeMutableRawPointer(bitPattern: handle)!, overlapped)
        }
    }

    // MARK: - Cancel All

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling all pending I/O operations.
        ///
        /// Holds the HANDLE bit pattern rather than the descriptor itself:
        /// `Descriptor` is `~Copyable`, so an ephemeral accessor borrows the
        /// handle value and must not outlive the descriptor.
        public struct All: Sendable {
            let handle: UInt

            init(_ handle: UInt) {
                self.handle = handle
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.All {
        /// Cancels all pending I/O (fire-and-forget).
        ///
        /// Delegates to the raw `Cancel.all(_:)` SPI. Returns silently if
        /// no operations are pending.
        public func callAsFunction() {
            _ = Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle)
        }

        /// Returns whether cancellation succeeded.
        ///
        /// Delegates to the raw `Cancel.all(_:)` SPI.
        ///
        /// - Returns: `true` if cancelled, `false` if no pending operations.
        public var status: Bool {
            if Windows.`32`.Kernel.IO.Completion.Port.Cancel.all(handle) {
                return true
            }
            return GetLastError() != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {
        /// Cancels all pending I/O on a handle.
        ///
        /// Typed L2 form. Returns an accessor whose
        /// ``All/callAsFunction()``/``All/status`` delegate to the raw
        /// `Cancel.all(_:)` SPI via `descriptor._rawValue`.
        ///
        /// - Parameter descriptor: The descriptor with pending I/O.
        /// - Returns: An accessor for cancel operations.
        public static func all(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) -> All {
            All(descriptor._rawValue)
        }
    }

    // MARK: - Cancel Specific

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {
        /// Result of cancelling a specific pending I/O operation.
        ///
        /// Holds the HANDLE bit pattern rather than the descriptor itself:
        /// `Descriptor` is `~Copyable`, so an ephemeral accessor borrows the
        /// handle value and must not outlive the descriptor.
        @safe
        public struct Pending: @unchecked Sendable {
            let handle: UInt

            let overlappedPtr: UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>

            @unsafe
            init(_ handle: UInt, overlapped: UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>) {
                self.handle = handle
                self.overlappedPtr = unsafe overlapped
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending {
        /// Cancels the specific pending I/O (fire-and-forget).
        ///
        /// Delegates to the raw `Cancel.pending(_:overlapped:)` SPI.
        /// Returns silently if the operation already completed.
        public func callAsFunction() {
            let ptr = unsafe overlappedPtr
            _ = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
        }

        /// Returns whether cancellation succeeded.
        ///
        /// Delegates to the raw `Cancel.pending(_:overlapped:)` SPI.
        ///
        /// - Returns: `true` if cancelled, `false` if already completed.
        public var status: Bool {
            let ptr = unsafe overlappedPtr
            let result = unsafe withUnsafeMutablePointer(to: &ptr.pointee.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
            if result {
                return true
            }
            return GetLastError() != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    // MARK: - Cancel Specific (Safe, Immediate)

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending {
        /// Result of a specific pending-I/O cancellation that has **already
        /// executed**.
        ///
        /// Unlike ``Pending`` itself, a `Result` stores no pointer into
        /// caller storage. It is produced by the safe, `inout`-taking
        /// `Cancel.pending(_:overlapped:)` overload, which must call
        /// `CancelIoEx` *inside* the scope that produces a valid
        /// `LPOVERLAPPED` (see that overload's doc comment for why): by the
        /// time a `Result` exists, the cancel has already happened, so there
        /// is nothing left to defer and nothing that could reference memory
        /// past the caller's `overlapped` local going out of scope.
        public struct Result: Sendable {
            let succeeded: Bool
            let lastError: DWORD

            init(succeeded: Bool, lastError: DWORD) {
                self.succeeded = succeeded
                self.lastError = lastError
            }
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel.Pending.Result {
        /// No-op: the cancel already ran when this value was constructed.
        ///
        /// Kept for call-site symmetry with ``Pending/callAsFunction()`` so
        /// existing fire-and-forget call sites
        /// (`Cancel.pending(descriptor, overlapped: &overlapped)()`) keep
        /// compiling unchanged.
        public func callAsFunction() {}

        /// Whether cancellation succeeded.
        ///
        /// Mirrors ``Pending/status``'s exact success formula, just
        /// evaluated eagerly at cancel time instead of lazily at access
        /// time.
        ///
        /// - Returns: `true` if cancelled, `false` if already completed.
        public var status: Bool {
            if succeeded {
                return true
            }
            return lastError != Windows.`32`.Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
        }
    }

    extension Windows.`32`.Kernel.IO.Completion.Port.Cancel {
        /// Cancels a specific pending I/O operation.
        ///
        /// Typed L2 form, safe (no `@unsafe`). Executes `CancelIoEx`
        /// **immediately**, inside the pointer scope that
        /// `withUnsafeMutablePointer(to:)` guarantees is valid, and returns
        /// an already-computed ``Pending/Result``.
        ///
        /// ## Why not return `Pending`
        ///
        /// An earlier revision returned `Pending` — an accessor that stored
        /// an `UnsafeMutablePointer` obtained from
        /// `withUnsafeMutablePointer(to: &overlapped)` and deferred the
        /// actual `CancelIoEx` call to `callAsFunction()`/`status`. That
        /// pointer is only guaranteed valid for the duration of the
        /// `withUnsafeMutablePointer` closure; storing it in the returned
        /// value and dereferencing it later, after the closure (and this
        /// function) has returned, is undefined behavior — the compiler is
        /// free to treat the pointee as dead the moment the closure exits.
        /// Executing the cancel inside the closure and returning only the
        /// already-computed result removes the escape entirely.
        ///
        /// - Parameters:
        ///   - descriptor: The descriptor with pending I/O.
        ///   - overlapped: The overlapped structure for the operation to cancel.
        /// - Returns: The already-executed cancel result.
        public static func pending(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            overlapped: inout Windows.`32`.Kernel.IO.Completion.Port.Overlapped
        ) -> Pending.Result {
            let handle = descriptor._rawValue
            let succeeded = unsafe withUnsafeMutablePointer(to: &overlapped.raw) { rawPtr in
                Windows.`32`.Kernel.IO.Completion.Port.Cancel.pending(handle, overlapped: rawPtr)
            }
            let lastError = succeeded ? DWORD(0) : GetLastError()
            return Pending.Result(succeeded: succeeded, lastError: lastError)
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
        public static func pending(
            _ descriptor: borrowing Windows.`32`.Kernel.Descriptor,
            overlapped: UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>
        ) -> Pending {
            unsafe Pending(descriptor._rawValue, overlapped: overlapped)
        }
    }

#endif
