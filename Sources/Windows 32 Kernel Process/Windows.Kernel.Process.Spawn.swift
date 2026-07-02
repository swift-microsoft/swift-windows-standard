// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
public import WinSDK
public import Path_Primitives
#endif

// MARK: - Process.Spawn namespace

extension Windows.`32`.Kernel.Process {
    /// Process spawn operations via Win32 `CreateProcessW`.
    ///
    /// Mirrors the POSIX iso-9945 ``ISO_9945/Kernel/Process/Spawn`` namespace
    /// in shape so the L3-unifier swift-process can compose typed Spawn calls
    /// uniformly across platforms.
    ///
    /// ## v2 Coverage
    ///
    /// `Spawn` ships:
    ///
    /// - ``Actions`` builder for stdio handle inheritance via
    ///   `PROC_THREAD_ATTRIBUTE_HANDLE_LIST`.
    /// - ``spawn(executable:commandLine:environment:workingDirectory:actions:)``
    ///   entry point taking the actions and a UTF-16 command line.
    ///
    /// ## Reserved for v3
    ///
    /// Additional `PROC_THREAD_ATTRIBUTE_*` configurations (security
    /// descriptors, parent-process inheritance, mitigation policies) are
    /// reserved for v3.
    public enum Spawn: Sendable {}
}

// MARK: - Process.Spawn.Result

extension Windows.`32`.Kernel.Process.Spawn {
    /// The result of a successful `CreateProcessW` call.
    ///
    /// Bundles the process and primary-thread handles together with their
    /// numeric IDs. Callers are responsible for closing both handles via
    /// ``Windows/32/Kernel/Close/close(_:)`` after they are done with the
    /// child (typically after a `WaitForSingleObject` on the process
    /// handle returns).
    public struct Result: ~Copyable, Sendable {
        /// Handle to the spawned process.
        public let processHandle: Windows.`32`.Kernel.Descriptor

        /// Handle to the primary thread of the spawned process.
        public let threadHandle: Windows.`32`.Kernel.Descriptor

        /// Numeric ID of the spawned process.
        public let processID: UInt32

        /// Numeric ID of the primary thread.
        public let threadID: UInt32

        @inlinable
        public init(
            processHandle: consuming Windows.`32`.Kernel.Descriptor,
            threadHandle: consuming Windows.`32`.Kernel.Descriptor,
            processID: UInt32,
            threadID: UInt32
        ) {
            self.processHandle = processHandle
            self.threadHandle = threadHandle
            self.processID = processID
            self.threadID = threadID
        }
    }
}

// MARK: - Spawn entry point

#if os(Windows)

extension Windows.`32`.Kernel.Process.Spawn {
    /// Spawns a child process via `CreateProcessW`.
    ///
    /// - Parameters:
    ///   - executable: NUL-terminated UTF-16 path to the executable
    ///     (`lpApplicationName`). May be `nil` if the command line embeds
    ///     the path as its first token.
    ///   - commandLine: Mutable NUL-terminated UTF-16 command line
    ///     (`lpCommandLine`). Win32 reserves the right to modify this
    ///     buffer in place; callers MUST pass a writable copy.
    ///   - environment: NUL-terminated UTF-16 environment block
    ///     (`lpEnvironment`) with `CREATE_UNICODE_ENVIRONMENT`. Entries
    ///     are `KEY=VALUE\0` and the block ends with an additional
    ///     `\0\0`. `nil` inherits the parent's environment.
    ///   - workingDirectory: NUL-terminated UTF-16 path
    ///     (`lpCurrentDirectory`). `nil` inherits the parent's CWD.
    ///   - actions: Handle-inheritance discipline builder. Specifies the
    ///     STARTUPINFOEX attribute list (`PROC_THREAD_ATTRIBUTE_HANDLE_LIST`)
    ///     used to control which parent handles the child inherits.
    /// - Returns: A ``Result`` bundling the process / thread handles and IDs.
    /// - Throws: ``Windows/32/Kernel/Process/Error`` on `CreateProcessW`
    ///   failure.
    @unsafe
    public static func spawn(
        executable: UnsafePointer<WCHAR>?,
        commandLine: UnsafeMutablePointer<WCHAR>,
        environment: UnsafeMutableRawPointer?,
        workingDirectory: UnsafePointer<WCHAR>?,
        actions: borrowing Actions
    ) throws(Windows.`32`.Kernel.Process.Error) -> Result {
        var startupInfo = STARTUPINFOEXW()
        startupInfo.StartupInfo.cb = DWORD(MemoryLayout<STARTUPINFOEXW>.size)
        startupInfo.lpAttributeList = unsafe actions._attributeList

        // Wire the stdio slots from the actions builder. CreateProcessW
        // honors STARTF_USESTDHANDLES when set; otherwise the child
        // inherits the parent's stdio.
        if let handles = unsafe actions._stdioHandles {
            unsafe startupInfo.StartupInfo.dwFlags |= DWORD(STARTF_USESTDHANDLES)
            unsafe startupInfo.StartupInfo.hStdInput  = handles.stdin
            unsafe startupInfo.StartupInfo.hStdOutput = handles.stdout
            unsafe startupInfo.StartupInfo.hStdError  = handles.stderr
        }

        var processInfo = PROCESS_INFORMATION()

        // CREATE_UNICODE_ENVIRONMENT is required when `lpEnvironment` is
        // a UTF-16 block (OQ 3 disposition: UTF-16 for parity with Win32
        // wide-string conventions and consistent file-path encoding).
        let creationFlags: DWORD = DWORD(
            CREATE_UNICODE_ENVIRONMENT | EXTENDED_STARTUPINFO_PRESENT
        )

        let success = unsafe withUnsafePointer(to: &startupInfo.StartupInfo) {
            (siPtr: UnsafePointer<STARTUPINFOW>) -> Bool in
            let mutableSI = unsafe UnsafeMutablePointer(mutating: siPtr)
            return unsafe CreateProcessW(
                executable,
                commandLine,
                nil,                    // lpProcessAttributes
                nil,                    // lpThreadAttributes
                true,                   // bInheritHandles (selective via attr-list)
                creationFlags,
                environment,
                workingDirectory,
                mutableSI,
                &processInfo
            )
        }

        guard success else {
            throw .create(Error_Primitives.Error.captureLastError())
        }

        return Result(
            processHandle: Windows.`32`.Kernel.Descriptor(
                _raw: UInt(bitPattern: processInfo.hProcess)
            ),
            threadHandle: Windows.`32`.Kernel.Descriptor(
                _raw: UInt(bitPattern: processInfo.hThread)
            ),
            processID: processInfo.dwProcessId,
            threadID: processInfo.dwThreadId
        )
    }
}

#endif
