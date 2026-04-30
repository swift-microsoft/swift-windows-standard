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
@_spi(Syscall) import Windows_32_Kernel_Core
public import WinSDK

// MARK: - Windows DuplicateHandle syscall (raw @_spi(Syscall))

extension Windows.Kernel.Descriptor.Duplicate {
    /// Duplicates a HANDLE bit pattern.
    ///
    /// Spec-literal raw `DuplicateHandle`. The typed L2 convenience
    /// (`duplicate(_:)` taking `Windows.Kernel.Descriptor`) delegates to this
    /// raw SPI internally via `descriptor._rawValue` after a fast-fail
    /// validity check.
    ///
    /// Creates a duplicate of the specified handle with the same access
    /// rights. The new handle refers to the same underlying kernel object.
    ///
    /// - Parameter handle: HANDLE bit pattern to duplicate.
    /// - Returns: The duplicated HANDLE bit pattern.
    /// - Throws: `Windows.Kernel.Descriptor.Duplicate.Error` on failure.
    @_spi(Syscall)
    public static func duplicate(_ handle: UInt) throws(Error) -> UInt {
        let currentProcess = GetCurrentProcess()
        var newHandle: HANDLE? = nil

        let success = DuplicateHandle(
            currentProcess,
            UnsafeMutableRawPointer(bitPattern: handle)!,
            currentProcess,
            &newHandle,
            0,
            false,
            DWORD(DUPLICATE_SAME_ACCESS)
        )

        guard success, let newHandle else {
            throw .current()
        }

        return UInt(bitPattern: newHandle)
    }
}

// MARK: - Typed Convenience

extension Windows.Kernel.Descriptor.Duplicate {
    /// Duplicates a handle.
    ///
    /// Typed L2 form. Delegates to the raw `duplicate(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// - Parameter descriptor: The handle to duplicate.
    /// - Returns: The duplicated handle.
    /// - Throws: `Windows.Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(_ descriptor: borrowing Windows.Kernel.Descriptor) throws(Error) -> Windows.Kernel.Descriptor {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let newHandle = try duplicate(descriptor._rawValue)
        return Windows.Kernel.Descriptor(_rawValue: newHandle)
    }
}

// MARK: - Error Construction

extension Windows.Kernel.Descriptor.Duplicate.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.captureLastError()
        if let e = Windows.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(e)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}

#endif
