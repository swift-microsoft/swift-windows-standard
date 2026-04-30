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
public import WinSDK

// MARK: - Windows Process Operations

extension Windows.`32`.Kernel.Process {
    /// Gets the current process ID.
    ///
    /// - Returns: The current process ID.
    @inlinable
    public static func getCurrentId() -> UInt32 {
        GetCurrentProcessId()
    }

    /// Gets the current process handle.
    ///
    /// - Returns: A pseudo-handle to the current process.
    @inlinable
    public static func getCurrentHandle() -> HANDLE {
        GetCurrentProcess()
    }

    /// Terminates another process.
    ///
    /// - Parameters:
    ///   - handle: Handle to the process to terminate.
    ///   - exitCode: The exit code for the process.
    /// - Returns: True if successful.
    public static func terminate(handle: HANDLE, exitCode: UInt32) -> Bool {
        TerminateProcess(handle, exitCode)
    }

    /// Gets the exit code of a process.
    ///
    /// - Parameter handle: Handle to the process.
    /// - Returns: The exit code, or nil if still running.
    public static func getExitCode(handle: HANDLE) -> UInt32? {
        var exitCode: DWORD = 0
        guard GetExitCodeProcess(handle, &exitCode) else {
            return nil
        }
        // STILL_ACTIVE (259) means the process is still running
        if exitCode == DWORD(STILL_ACTIVE) {
            return nil
        }
        return exitCode
    }

    /// Waits for a process to terminate.
    ///
    /// - Parameters:
    ///   - handle: Handle to the process.
    ///   - timeout: Maximum wait time in milliseconds, or INFINITE.
    /// - Returns: The wait result.
    public static func wait(handle: HANDLE, timeout: DWORD = DWORD(INFINITE)) -> DWORD {
        WaitForSingleObject(handle, timeout)
    }
}

// MARK: - Process Creation

extension Windows.`32`.Kernel.Process {
    /// Information about a created process.
    public struct Info {
        /// Handle to the new process.
        public let processHandle: HANDLE
        /// Handle to the primary thread.
        public let threadHandle: HANDLE
        /// Process ID.
        public let processId: UInt32
        /// Thread ID of the primary thread.
        public let threadId: UInt32

        /// Closes the process and thread handles.
        public func close() {
            _ = CloseHandle(processHandle)
            _ = CloseHandle(threadHandle)
        }
    }

    /// Creates a new process.
    ///
    /// This is the Windows equivalent of fork+exec. Windows does not have fork().
    ///
    /// - Parameters:
    ///   - applicationName: Path to the executable, or nil to use command line.
    ///   - commandLine: The command line string.
    ///   - inheritHandles: Whether to inherit parent handles.
    ///   - creationFlags: Process creation flags.
    ///   - environment: Environment block, or nil to inherit.
    ///   - currentDirectory: Working directory, or nil to inherit.
    /// - Returns: Process information on success.
    /// - Throws: Error on failure.
    public static func create(
        applicationName: UnsafePointer<WCHAR>? = nil,
        commandLine: UnsafeMutablePointer<WCHAR>,
        inheritHandles: Bool = false,
        creationFlags: DWORD = 0,
        environment: UnsafeMutableRawPointer? = nil,
        currentDirectory: UnsafePointer<WCHAR>? = nil
    ) throws(Error) -> Info {
        var startupInfo = STARTUPINFOW()
        startupInfo.cb = DWORD(MemoryLayout<STARTUPINFOW>.size)

        var processInfo = PROCESS_INFORMATION()

        let success = CreateProcessW(
            applicationName,
            commandLine,
            nil,  // Process security attributes
            nil,  // Thread security attributes
            inheritHandles,
            creationFlags,
            environment,
            currentDirectory,
            &startupInfo,
            &processInfo
        )

        guard success else {
            throw .create(Error_Primitives.Error.captureLastError())
        }

        return Info(
            processHandle: processInfo.hProcess,
            threadHandle: processInfo.hThread,
            processId: processInfo.dwProcessId,
            threadId: processInfo.dwThreadId
        )
    }

    /// Creates a new process with startup info configuration.
    ///
    /// - Parameters:
    ///   - commandLine: The command line string.
    ///   - startupInfo: Startup information including stdin/stdout/stderr handles.
    ///   - inheritHandles: Whether to inherit parent handles.
    ///   - creationFlags: Process creation flags.
    /// - Returns: Process information on success.
    /// - Throws: Error on failure.
    public static func create(
        commandLine: UnsafeMutablePointer<WCHAR>,
        startupInfo: inout STARTUPINFOW,
        inheritHandles: Bool = true,
        creationFlags: DWORD = 0
    ) throws(Error) -> Info {
        var processInfo = PROCESS_INFORMATION()

        let success = CreateProcessW(
            nil,
            commandLine,
            nil,
            nil,
            inheritHandles,
            creationFlags,
            nil,
            nil,
            &startupInfo,
            &processInfo
        )

        guard success else {
            throw .create(Error_Primitives.Error.captureLastError())
        }

        return Info(
            processHandle: processInfo.hProcess,
            threadHandle: processInfo.hThread,
            processId: processInfo.dwProcessId,
            threadId: processInfo.dwThreadId
        )
    }
}

// MARK: - Error Type

extension Windows.`32`.Kernel.Process {
    /// Errors from process operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Process creation failed.
        case create(Error_Primitives.Error.Code)

        /// Wait operation failed.
        case wait(Error_Primitives.Error.Code)

        /// Platform error.
        case platform(Error_Primitives.Error)
    }
}

#endif
