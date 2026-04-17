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
@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows CloseHandle syscall

extension Windows.Kernel.Close {
    /// Closes a handle, releasing the associated kernel resource.
    ///
    /// ## Threading
    /// This call blocks until the close completes. On most systems, close is fast,
    /// but may block on network handles while flushing data.
    ///
    /// ## Descriptor Invalidation
    /// After a successful close, the descriptor becomes invalid. Passing a closed
    /// descriptor to any operation is undefined behavior—the kernel may have
    /// reassigned the handle value to a new resource.
    ///
    /// ## Errors
    /// - ``Error/handle(_:)``: The handle is invalid (`.invalid`)
    /// - ``Error/io(_:)``: An I/O error occurred during close (data may be lost)
    ///
    /// - Parameter descriptor: The file descriptor to close.
    /// - Throws: ``Kernel/Close/Error`` on failure.
    public static func close(_ descriptor: Kernel.Descriptor) throws(Kernel.Close.Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        let result = CloseHandle(descriptor.handle)
        guard result else {
            throw .current()
        }
    }
}

// MARK: - Error Construction

extension Kernel.Close.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        Self(code: Windows.Kernel.Error.captureLastError())
    }
}

#endif
