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
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows Named Pipe Operations

extension Windows.Kernel.Pipe {
    /// Named pipe configuration.
    public struct Named {
        private init() {}
    }
}

// MARK: - Pipe Mode

extension Windows.Kernel.Pipe.Named {
    /// Named pipe open mode flags.
    public struct OpenMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// Pipe is bidirectional (server and client can read/write).
        public static let accessDuplex = OpenMode(rawValue: DWORD(PIPE_ACCESS_DUPLEX))

        /// Pipe is inbound (client writes, server reads).
        public static let accessInbound = OpenMode(rawValue: DWORD(PIPE_ACCESS_INBOUND))

        /// Pipe is outbound (server writes, client reads).
        public static let accessOutbound = OpenMode(rawValue: DWORD(PIPE_ACCESS_OUTBOUND))

        /// Enable overlapped (async) I/O.
        public static let overlapped = OpenMode(rawValue: DWORD(FILE_FLAG_OVERLAPPED))

        /// Enable write-through mode.
        public static let writeThrough = OpenMode(rawValue: DWORD(FILE_FLAG_WRITE_THROUGH))

        /// First instance of the pipe (fail if already exists).
        public static let firstPipeInstance = OpenMode(rawValue: DWORD(FILE_FLAG_FIRST_PIPE_INSTANCE))
    }

    /// Named pipe type/mode flags.
    public struct PipeMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// Data is written as a stream of bytes.
        public static let typeByte = PipeMode(rawValue: DWORD(PIPE_TYPE_BYTE))

        /// Data is written as a stream of messages.
        public static let typeMessage = PipeMode(rawValue: DWORD(PIPE_TYPE_MESSAGE))

        /// Data is read as a stream of bytes.
        public static let readModeByte = PipeMode(rawValue: DWORD(PIPE_READMODE_BYTE))

        /// Data is read as a stream of messages.
        public static let readModeMessage = PipeMode(rawValue: DWORD(PIPE_READMODE_MESSAGE))

        /// Blocking mode (reads block until data available).
        public static let wait = PipeMode(rawValue: DWORD(PIPE_WAIT))

        /// Non-blocking mode.
        public static let noWait = PipeMode(rawValue: DWORD(PIPE_NOWAIT))

        /// Accept remote clients.
        public static let acceptRemoteClients = PipeMode(rawValue: DWORD(PIPE_ACCEPT_REMOTE_CLIENTS))

        /// Reject remote clients (local only).
        public static let rejectRemoteClients = PipeMode(rawValue: DWORD(PIPE_REJECT_REMOTE_CLIENTS))

        /// Default byte pipe mode.
        public static let defaultByte: PipeMode = [.typeByte, .readModeByte, .wait]

        /// Default message pipe mode.
        public static let defaultMessage: PipeMode = [.typeMessage, .readModeMessage, .wait]
    }
}

// MARK: - Server Operations

extension Windows.Kernel.Pipe.Named {
    /// Creates a named pipe server instance.
    ///
    /// - Parameters:
    ///   - name: The pipe name (must start with `\\.\pipe\`).
    ///   - openMode: Pipe access flags.
    ///   - pipeMode: Pipe type and read mode flags.
    ///   - maxInstances: Maximum number of pipe instances (1-255, or 255 for unlimited).
    ///   - outBufferSize: Output buffer size in bytes.
    ///   - inBufferSize: Input buffer size in bytes.
    ///   - defaultTimeout: Default timeout in milliseconds (0 for 50ms default).
    /// - Returns: Handle to the pipe, or throws on failure.
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func create(
        name: UnsafePointer<WCHAR>,
        openMode: OpenMode = .accessDuplex,
        pipeMode: PipeMode = .defaultByte,
        maxInstances: DWORD = DWORD(PIPE_UNLIMITED_INSTANCES),
        outBufferSize: DWORD = 4096,
        inBufferSize: DWORD = 4096,
        defaultTimeout: DWORD = 0
    ) throws(Kernel.Pipe.Error) -> Kernel.Descriptor {
        let handle = CreateNamedPipeW(
            name,
            openMode.rawValue,
            pipeMode.rawValue,
            maxInstances,
            outBufferSize,
            inBufferSize,
            defaultTimeout,
            nil  // default security
        )

        guard handle != INVALID_HANDLE_VALUE else {
            throw .current()
        }

        return Kernel.Descriptor.borrowing(handle: handle)
    }

    /// Waits for a client to connect to the named pipe.
    ///
    /// - Parameter pipe: The named pipe handle (server side).
    /// - Returns: `true` if a client connected, `false` if already connected.
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func connect(
        _ pipe: Kernel.Descriptor
    ) throws(Kernel.Pipe.Error) -> Bool {
        if ConnectNamedPipe(pipe.handle, nil) {
            return true
        }

        let error = GetLastError()
        if error == DWORD(ERROR_PIPE_CONNECTED) {
            return false  // Already connected
        }

        throw .platform(Kernel.Error(code: .win32(error)))
    }

    /// Disconnects the server end of a named pipe.
    ///
    /// - Parameter pipe: The named pipe handle (server side).
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func disconnect(
        _ pipe: Kernel.Descriptor
    ) throws(Kernel.Pipe.Error) {
        guard DisconnectNamedPipe(pipe.handle) else {
            throw .current()
        }
    }
}

// MARK: - Client Operations

extension Windows.Kernel.Pipe.Named {
    /// Connects to a named pipe server.
    ///
    /// - Parameters:
    ///   - name: The pipe name (e.g., `\\.\pipe\mypipe`).
    ///   - access: Desired access (read, write, or both).
    /// - Returns: Handle to the connected pipe.
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func open(
        name: UnsafePointer<WCHAR>,
        access: Kernel.File.Open.Mode = [.read, .write]
    ) throws(Kernel.Pipe.Error) -> Kernel.Descriptor {
        let handle = CreateFileW(
            name,
            access.windowsDesiredAccess,
            0,  // no sharing
            nil,  // default security
            DWORD(OPEN_EXISTING),
            0,  // default attributes
            nil  // no template
        )

        guard handle != INVALID_HANDLE_VALUE else {
            throw .current()
        }

        return Kernel.Descriptor.borrowing(handle: handle)
    }

    /// Waits for a named pipe to become available.
    ///
    /// - Parameters:
    ///   - name: The pipe name.
    ///   - timeout: Timeout in milliseconds, or `NMPWAIT_WAIT_FOREVER`.
    /// - Returns: `true` if the pipe is available, `false` if timed out.
    public static func wait(
        name: UnsafePointer<WCHAR>,
        timeout: DWORD = DWORD(NMPWAIT_WAIT_FOREVER)
    ) -> Bool {
        WaitNamedPipeW(name, timeout)
    }
}

// MARK: - Pipe State

extension Windows.Kernel.Pipe.Named {
    /// Gets information about a named pipe.
    ///
    /// - Parameter pipe: The pipe handle.
    /// - Returns: Tuple of (currentInstances, maxInstances), or `nil` on failure.
    public static func getInfo(_ pipe: Kernel.Descriptor) -> (current: DWORD, max: DWORD)? {
        var flags: DWORD = 0
        var outBufferSize: DWORD = 0
        var inBufferSize: DWORD = 0
        var maxInstances: DWORD = 0

        guard GetNamedPipeInfo(pipe.handle, &flags, &outBufferSize, &inBufferSize, &maxInstances) else {
            return nil
        }

        // Get current instances via handle state
        var state: DWORD = 0
        var curInstances: DWORD = 0
        guard GetNamedPipeHandleStateW(pipe.handle, &state, &curInstances, nil, nil, nil, 0) else {
            return (0, maxInstances)
        }

        return (curInstances, maxInstances)
    }

    /// Peeks at data in a named pipe without removing it.
    ///
    /// - Parameters:
    ///   - pipe: The pipe handle.
    ///   - buffer: Buffer to receive peeked data (can be nil).
    /// - Returns: Tuple of (bytesRead, totalBytesAvailable, bytesLeftInMessage).
    public static func peek(
        _ pipe: Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer? = nil
    ) -> (read: DWORD, available: DWORD, leftInMessage: DWORD)? {
        var bytesRead: DWORD = 0
        var totalAvailable: DWORD = 0
        var leftInMessage: DWORD = 0

        let result = PeekNamedPipe(
            pipe.handle,
            buffer?.baseAddress,
            DWORD(buffer?.count ?? 0),
            &bytesRead,
            &totalAvailable,
            &leftInMessage
        )

        guard result else { return nil }
        return (bytesRead, totalAvailable, leftInMessage)
    }
}

#endif
