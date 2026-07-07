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

public import Pair_Primitives

#if os(Windows)
    internal import WinSDK
#endif

// MARK: - Pipe.Descriptors (Tagged<Pipe, Pair<Descriptor, Descriptor>>)

extension Windows.`32`.Kernel.Pipe {
    /// The result of creating a pipe: a `~Copyable` pair of read and write
    /// descriptors.
    ///
    /// `Descriptors` mirrors the POSIX iso-9945 shape
    /// (``ISO_9945/Kernel/Pipe/Descriptors``) for cross-platform consumer
    /// parity. Each end has its own deinit-close path, so dropping a
    /// `Descriptors` value closes both handles via the underlying
    /// `Windows.\`32\`.Kernel.Descriptor` ``deinit`` (which invokes
    /// `CloseHandle`).
    public typealias Descriptors = Tagged<
        Windows.`32`.Kernel.Pipe,
        Pair<Windows.`32`.Kernel.Descriptor, Windows.`32`.Kernel.Descriptor>
    >
}

extension Tagged
where
    Tag == Windows.`32`.Kernel.Pipe,
    Underlying == Pair<Windows.`32`.Kernel.Descriptor, Windows.`32`.Kernel.Descriptor>
{
    /// The read end of the pipe.
    public var read: Windows.`32`.Kernel.Descriptor {
        @inlinable _read { yield underlying.first }
    }

    /// The write end of the pipe.
    public var write: Windows.`32`.Kernel.Descriptor {
        @inlinable _read { yield underlying.second }
    }

    /// Creates pipe descriptors from read and write ends.
    @inlinable
    internal init(
        read: consuming Windows.`32`.Kernel.Descriptor,
        write: consuming Windows.`32`.Kernel.Descriptor
    ) {
        self.init(_unchecked: Pair(read, write))
    }
}

// MARK: - CreatePipe wrapper

extension Windows.`32`.Kernel.Pipe {
    /// Creates an anonymous pipe via Win32 `CreatePipe`.
    ///
    /// Both handles are created as INHERITABLE by default so the pipe ends
    /// can be passed across a `CreateProcessW` call for child-process
    /// stdio redirection. Callers that want to keep specific ends out of
    /// child processes SHOULD strip inheritance via `SetHandleInformation`
    /// on a per-end basis, OR use ``Process/Spawn/Configuration`` which
    /// applies the precise inheritance discipline via
    /// `PROC_THREAD_ATTRIBUTE_HANDLE_LIST`.
    ///
    /// - Returns: A ``Descriptors`` value bundling the read and write ends.
    /// - Throws: ``Error`` on `CreatePipe` failure.
    public static func pipe() throws(Error) -> Descriptors {
        #if os(Windows)
            var readHandle: HANDLE? = nil
            var writeHandle: HANDLE? = nil

            // CreatePipe with inheritable SECURITY_ATTRIBUTES; bufferSize 0
            // selects the system default.
            var security = SECURITY_ATTRIBUTES()
            security.nLength = DWORD(MemoryLayout<SECURITY_ATTRIBUTES>.size)
            security.bInheritHandle = true
            security.lpSecurityDescriptor = nil

            guard unsafe CreatePipe(&readHandle, &writeHandle, &security, 0) else {
                throw Error.current()
            }

            guard let read = readHandle, let write = writeHandle else {
                throw Error.current()
            }

            return Descriptors(
                read: Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: read)),
                write: Windows.`32`.Kernel.Descriptor(_raw: UInt(bitPattern: write))
            )
        #else
            // Non-Windows builds: this code path is unreachable at runtime but
            // the symbol must exist for cross-platform builds to link cleanly.
            throw Error.platform(Error_Primitives.Error(code: .win32(0)))
        #endif
    }
}

// MARK: - Error Construction

extension Windows.`32`.Kernel.Pipe.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        #if os(Windows)
            return Self(code: Error_Primitives.Error.captureLastError())
        #else
            return .platform(Error_Primitives.Error(code: .win32(0)))
        #endif
    }
}
