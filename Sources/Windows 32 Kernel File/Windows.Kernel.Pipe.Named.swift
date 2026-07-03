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

// MARK: - Windows Named Pipe Operations

extension Windows.`32`.Kernel.Pipe {
    /// Named pipe configuration.
    public struct Named {
        private init() {}
    }
}

// MARK: - Pipe Mode

extension Windows.`32`.Kernel.Pipe.Named {
    /// Named pipe open mode flags.
    package struct OpenMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }
    }

    /// Named pipe type/mode flags.
    package struct PipeMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }
    }
}

extension Windows.`32`.Kernel.Pipe.Named.OpenMode {
    /// Pipe is bidirectional (server and client can read/write).
    public static let accessDuplex = Self(rawValue: DWORD(PIPE_ACCESS_DUPLEX))

    /// Pipe is inbound (client writes, server reads).
    public static let accessInbound = Self(rawValue: DWORD(PIPE_ACCESS_INBOUND))

    /// Pipe is outbound (server writes, client reads).
    public static let accessOutbound = Self(rawValue: DWORD(PIPE_ACCESS_OUTBOUND))

    /// Enable overlapped (async) I/O.
    public static let overlapped = Self(rawValue: DWORD(FILE_FLAG_OVERLAPPED))

    /// Enable write-through mode.
    public static let writeThrough = Self(rawValue: DWORD(FILE_FLAG_WRITE_THROUGH))

    /// First instance of the pipe (fail if already exists).
    public static let firstPipeInstance = Self(rawValue: DWORD(FILE_FLAG_FIRST_PIPE_INSTANCE))
}

extension Windows.`32`.Kernel.Pipe.Named.PipeMode {
    /// Data is written as a stream of bytes.
    public static let typeByte = Self(rawValue: DWORD(PIPE_TYPE_BYTE))

    /// Data is written as a stream of messages.
    public static let typeMessage = Self(rawValue: DWORD(PIPE_TYPE_MESSAGE))

    /// Data is read as a stream of bytes.
    public static let readModeByte = Self(rawValue: DWORD(PIPE_READMODE_BYTE))

    /// Data is read as a stream of messages.
    public static let readModeMessage = Self(rawValue: DWORD(PIPE_READMODE_MESSAGE))

    /// Blocking mode (reads block until data available).
    public static let wait = Self(rawValue: DWORD(PIPE_WAIT))

    /// Non-blocking mode.
    public static let noWait = Self(rawValue: DWORD(PIPE_NOWAIT))

    /// Accept remote clients.
    public static let acceptRemoteClients = Self(rawValue: DWORD(PIPE_ACCEPT_REMOTE_CLIENTS))

    /// Reject remote clients (local only).
    public static let rejectRemoteClients = Self(rawValue: DWORD(PIPE_REJECT_REMOTE_CLIENTS))

    /// Default byte pipe mode.
    public static let defaultByte: Self = [.typeByte, .readModeByte, .wait]

    /// Default message pipe mode.
    public static let defaultMessage: Self = [.typeMessage, .readModeMessage, .wait]
}

// MARK: - Server Operations

extension Windows.`32`.Kernel.Pipe.Named {
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
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
    public static func create(
        name: UnsafePointer<WCHAR>,
        openMode: OpenMode = .accessDuplex,
        pipeMode: PipeMode = .defaultByte,
        maxInstances: DWORD = DWORD(PIPE_UNLIMITED_INSTANCES),
        outBufferSize: DWORD = 4096,
        inBufferSize: DWORD = 4096,
        defaultTimeout: DWORD = 0
    ) throws(Windows.`32`.Kernel.Pipe.Error) -> Windows.`32`.Kernel.Descriptor {
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

        return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
    }

    /// Waits for a client to connect to a named pipe via HANDLE bit pattern.
    ///
    /// Spec-literal raw `ConnectNamedPipe`. The typed L2 convenience
    /// (`connect(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw SPI
    /// internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern (server side).
    /// - Returns: `true` if a client connected, `false` if already connected.
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
        package static func connect(
        _ handle: UInt
    ) throws(Windows.`32`.Kernel.Pipe.Error) -> Bool {
        if ConnectNamedPipe(UnsafeMutableRawPointer(bitPattern: handle)!, nil) {
            return true
        }

        let error = GetLastError()
        if error == DWORD(ERROR_PIPE_CONNECTED) {
            return false  // Already connected
        }

        throw .platform(Error_Primitives.Error(code: .win32(error)))
    }

    /// Disconnects the server end of a named pipe via HANDLE bit pattern.
    ///
    /// Spec-literal raw `DisconnectNamedPipe`. The typed L2 convenience
    /// (`disconnect(_:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw
    /// SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern (server side).
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
        package static func disconnect(
        _ handle: UInt
    ) throws(Windows.`32`.Kernel.Pipe.Error) {
        guard DisconnectNamedPipe(UnsafeMutableRawPointer(bitPattern: handle)!) else {
            throw .current()
        }
    }

    /// Waits for a client to connect to the named pipe.
    ///
    /// Typed L2 form. Delegates to the raw `connect(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter pipe: The named pipe handle (server side).
    /// - Returns: `true` if a client connected, `false` if already connected.
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
    public static func connect(
        _ pipe: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.Pipe.Error) -> Bool {
        try connect(pipe._rawValue)
    }

    /// Disconnects the server end of a named pipe.
    ///
    /// Typed L2 form. Delegates to the raw `disconnect(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter pipe: The named pipe handle (server side).
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
    public static func disconnect(
        _ pipe: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.Pipe.Error) {
        try disconnect(pipe._rawValue)
    }
}

// MARK: - Client Operations

extension Windows.`32`.Kernel.Pipe.Named {
    /// Connects to a named pipe server.
    ///
    /// - Parameters:
    ///   - name: The pipe name (e.g., `\\.\pipe\mypipe`).
    ///   - access: Desired access (read, write, or both).
    /// - Returns: Handle to the connected pipe.
    /// - Throws: `Windows.`32`.Kernel.Pipe.Error` on failure.
    public static func open(
        name: UnsafePointer<WCHAR>,
        access: Windows.`32`.Kernel.File.Open.Mode = .readWrite
    ) throws(Windows.`32`.Kernel.Pipe.Error) -> Windows.`32`.Kernel.Descriptor {
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

        return Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: handle))
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

extension Windows.`32`.Kernel.Pipe.Named {
    /// Gets information about a named pipe via HANDLE bit pattern.
    ///
    /// Spec-literal raw `GetNamedPipeInfo + GetNamedPipeHandleStateW`. The
    /// typed L2 convenience (`getInfo(_:)` taking `Windows.`32`.Kernel.Descriptor`)
    /// delegates to this raw SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: Tuple of (currentInstances, maxInstances), or `nil` on failure.
        package static func getInfo(_ handle: UInt) -> (current: DWORD, max: DWORD)? {
        var flags: DWORD = 0
        var outBufferSize: DWORD = 0
        var inBufferSize: DWORD = 0
        var maxInstances: DWORD = 0

        let pipePtr = UnsafeMutableRawPointer(bitPattern: handle)!
        guard GetNamedPipeInfo(pipePtr, &flags, &outBufferSize, &inBufferSize, &maxInstances) else {
            return nil
        }

        // Get current instances via handle state
        var state: DWORD = 0
        var curInstances: DWORD = 0
        guard GetNamedPipeHandleStateW(pipePtr, &state, &curInstances, nil, nil, nil, 0) else {
            return (0, maxInstances)
        }

        return (curInstances, maxInstances)
    }

    /// Peeks at data in a named pipe via HANDLE bit pattern without removing it.
    ///
    /// Spec-literal raw `PeekNamedPipe`. The typed L2 convenience
    /// (`peek(_:into:)` taking `Windows.`32`.Kernel.Descriptor`) delegates to this raw
    /// SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - buffer: Buffer to receive peeked data (can be nil).
    /// - Returns: Tuple of (bytesRead, totalBytesAvailable, bytesLeftInMessage).
        package static func peek(
        _ handle: UInt,
        into buffer: UnsafeMutableRawBufferPointer? = nil
    ) -> (read: DWORD, available: DWORD, leftInMessage: DWORD)? {
        var bytesRead: DWORD = 0
        var totalAvailable: DWORD = 0
        var leftInMessage: DWORD = 0

        let result = PeekNamedPipe(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            buffer?.baseAddress,
            DWORD(buffer?.count ?? 0),
            &bytesRead,
            &totalAvailable,
            &leftInMessage
        )

        guard result else { return nil }
        return (bytesRead, totalAvailable, leftInMessage)
    }

    /// Gets information about a named pipe.
    ///
    /// Typed L2 form. Delegates to the raw `getInfo(_:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter pipe: The pipe handle.
    /// - Returns: Tuple of (currentInstances, maxInstances), or `nil` on failure.
    package static func getInfo(_ pipe: borrowing Windows.`32`.Kernel.Descriptor) -> (current: DWORD, max: DWORD)? {
        getInfo(pipe._rawValue)
    }

    /// Peeks at data in a named pipe without removing it.
    ///
    /// Typed L2 form. Delegates to the raw `peek(_:into:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameters:
    ///   - pipe: The pipe handle.
    ///   - buffer: Buffer to receive peeked data (can be nil).
    /// - Returns: Tuple of (bytesRead, totalBytesAvailable, bytesLeftInMessage).
    public static func peek(
        _ pipe: borrowing Windows.`32`.Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer? = nil
    ) -> (read: DWORD, available: DWORD, leftInMessage: DWORD)? {
        peek(pipe._rawValue, into: buffer)
    }
}

#endif
