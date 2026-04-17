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

extension Windows.Kernel.Process {
    /// Exit operations namespace.
    public enum Exit {}
}

extension Windows.Kernel.Process.Exit {
    /// Terminates the calling process immediately.
    ///
    /// - Parameter exitCode: Exit code for the process (`UINT`).
    ///
    /// ## Important
    ///
    /// - This function does NOT return.
    /// - Uses `ExitProcess()` — no CRT atexit handlers, no stdio flush.
    /// - Equivalent to POSIX `_exit()`.
    ///
    /// ## Exit Code Conventions
    ///
    /// - `0`: Success
    /// - `1-255`: Application-defined errors
    ///
    /// ## Usage
    ///
    /// ```swift
    /// Kernel.Process.Exit.now(0)  // success
    /// Kernel.Process.Exit.now(1)  // failure
    /// ```
    public static func now(_ exitCode: UInt32) -> Never {
        ExitProcess(exitCode)
    }
}

#endif
