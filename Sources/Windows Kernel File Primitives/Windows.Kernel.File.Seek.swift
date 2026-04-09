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
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
public import WinSDK

// MARK: - Windows SetFilePointerEx syscall

extension Windows.Kernel.File.Seek {
    /// Repositions the file offset of a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - offset: The offset value.
    ///   - origin: The reference point for the offset.
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    @discardableResult
    public static func seek(
        _ descriptor: Kernel.Descriptor,
        offset: Int64,
        origin: Origin
    ) throws(Error) -> Int64 {
        guard descriptor.isValid else {
            throw .invalidDescriptor
        }

        var distance: LARGE_INTEGER = LARGE_INTEGER()
        distance.QuadPart = offset

        var newPosition: LARGE_INTEGER = LARGE_INTEGER()
        let success = SetFilePointerEx(
            descriptor.handle,
            distance,
            &newPosition,
            origin.windowsMoveMethod
        )

        guard success else {
            throw Error.current()
        }

        return newPosition.QuadPart
    }

    /// Gets the current file offset.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Kernel.File.Seek.Error` on failure.
    public static func tell(_ descriptor: Kernel.Descriptor) throws(Error) -> Int64 {
        try seek(descriptor, offset: 0, origin: .current)
    }
}

// MARK: - Origin Windows Conversion

extension Windows.Kernel.File.Seek.Origin {
    /// Converts the origin to Windows move method.
    @usableFromInline
    internal var windowsMoveMethod: DWORD {
        switch self {
        case .start:
            return DWORD(FILE_BEGIN)
        case .current:
            return DWORD(FILE_CURRENT)
        case .end:
            return DWORD(FILE_END)
        }
    }
}

// MARK: - Type Aliases

extension Windows.Kernel.File.Seek {
    public typealias Error = Kernel.File.Seek.Error
    public typealias Origin = Kernel.File.Seek.Origin
}

// MARK: - Error Construction

extension Kernel.File.Seek.Error {
    /// Creates an error from the current Win32 last error.
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(code: code)
        }

        switch win32Code {
        case Windows.Kernel.Error.Code.Handle.invalid:
            return .invalidDescriptor
        case Windows.Kernel.Error.Code.General.invalidParameter:
            return .negativeOffset
        case Windows.Kernel.Error.Code.IO.brokenPipe:
            return .notSeekable
        default:
            return .platform(code: code)
        }
    }
}

#endif
