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

// MARK: - Windows SetFilePointerEx syscall (raw @_spi(Syscall))

extension Windows.Kernel.File.Seek {
    /// Repositions the file offset of a HANDLE bit pattern.
    ///
    /// Spec-literal raw `SetFilePointerEx`. The typed L2 convenience
    /// (`seek(_:offset:origin:)` taking `Windows.Kernel.Descriptor`) delegates to
    /// this raw SPI internally via `descriptor._rawValue` after a fast-fail
    /// validity check.
    ///
    /// - Parameters:
    ///   - handle: HANDLE bit pattern.
    ///   - offset: The offset value.
    ///   - origin: The reference point for the offset.
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: `Windows.Kernel.File.Seek.Error` on failure.
    @_spi(Syscall)
    @discardableResult
    public static func seek(
        _ handle: UInt,
        offset: Int64,
        origin: Origin
    ) throws(Error) -> Int64 {
        var distance: LARGE_INTEGER = LARGE_INTEGER()
        distance.QuadPart = offset

        var newPosition: LARGE_INTEGER = LARGE_INTEGER()
        let success = SetFilePointerEx(
            UnsafeMutableRawPointer(bitPattern: handle)!,
            distance,
            &newPosition,
            origin.windowsMoveMethod
        )

        guard success else {
            throw Error.current()
        }

        return newPosition.QuadPart
    }

    /// Gets the current file offset for a HANDLE bit pattern.
    ///
    /// Composes raw `seek(_:offset:origin:)` with `offset: 0, origin: .current`.
    /// The typed L2 convenience (`tell(_:)` taking `Windows.Kernel.Descriptor`)
    /// delegates to this raw SPI internally via `descriptor._rawValue`.
    ///
    /// - Parameter handle: HANDLE bit pattern.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Windows.Kernel.File.Seek.Error` on failure.
    @_spi(Syscall)
    public static func tell(_ handle: UInt) throws(Error) -> Int64 {
        try seek(handle, offset: 0, origin: .current)
    }
}

// MARK: - Typed Convenience

extension Windows.Kernel.File.Seek {
    /// Repositions the file offset of a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `seek(_:offset:origin:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - offset: The offset value.
    ///   - origin: The reference point for the offset.
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: `Windows.Kernel.File.Seek.Error` on failure.
    @discardableResult
    public static func seek(
        _ descriptor: Windows.Kernel.Descriptor,
        offset: Int64,
        origin: Origin
    ) throws(Error) -> Int64 {
        guard descriptor.isValid else {
            throw .invalidDescriptor
        }
        return try seek(descriptor._rawValue, offset: offset, origin: origin)
    }

    /// Gets the current file offset.
    ///
    /// Typed L2 form. Delegates to the raw `tell(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// - Parameter descriptor: The file descriptor.
    /// - Returns: The current offset from the beginning of the file.
    /// - Throws: `Windows.Kernel.File.Seek.Error` on failure.
    public static func tell(_ descriptor: Windows.Kernel.Descriptor) throws(Error) -> Int64 {
        guard descriptor.isValid else {
            throw .invalidDescriptor
        }
        return try tell(descriptor._rawValue)
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
    public typealias Error = Windows.Kernel.File.Seek.Error
    public typealias Origin = Windows.Kernel.File.Seek.Origin
}

// MARK: - Error Construction

extension Windows.Kernel.File.Seek.Error {
    /// Creates an error from the current Win32 last error.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        guard let win32Code = code.win32 else {
            return .platform(code: code)
        }

        switch win32Code {
        case Error_Primitives.Error.Code.Handle.invalid:
            return .invalidDescriptor
        case Error_Primitives.Error.Code.General.invalidParameter:
            return .negativeOffset
        case Error_Primitives.Error.Code.IO.brokenPipe:
            return .notSeekable
        default:
            return .platform(code: code)
        }
    }
}

#endif
