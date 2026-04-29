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
public import WinSDK

// MARK: - Windows DuplicateHandle syscall (raw @_spi(Syscall))

extension Windows.Kernel.Descriptor.Duplicate {
    /// Duplicates a HANDLE bit pattern.
    ///
    /// Spec-literal raw `DuplicateHandle`. The typed L2 convenience
    /// (`duplicate(_:)` taking `Kernel.Descriptor`) delegates to this raw
    /// SPI internally via `descriptor._rawValue` after a fast-fail validity
    /// check.
    ///
    /// Creates a duplicate of the specified handle with the same access
    /// rights. The new handle refers to the same underlying kernel object.
    ///
    /// - Parameter handle: HANDLE bit pattern to duplicate.
    /// - Returns: The duplicated HANDLE bit pattern.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    @_spi(Syscall)
    public static func duplicate(_ handle: UInt) throws(Kernel.Descriptor.Duplicate.Error) -> UInt {
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
    /// Creates a duplicate of the specified handle with the same access
    /// rights. The new handle refers to the same underlying kernel object.
    ///
    /// - Parameter descriptor: The handle to duplicate.
    /// - Returns: The duplicated handle.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(_ descriptor: Kernel.Descriptor) throws(Kernel.Descriptor.Duplicate.Error) -> Kernel.Descriptor {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        let newHandle = try duplicate(descriptor._rawValue)
        return Kernel.Descriptor.borrowing(handle: HANDLE(bitPattern: newHandle)!)
    }

    /// Duplicates a handle to a specific target handle value.
    ///
    /// Typed L2 form. Delegates to the raw `duplicate(_:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check. On Windows,
    /// this closes the target handle first if it's valid, then duplicates
    /// the source to it.
    ///
    /// - Parameters:
    ///   - descriptor: The source handle to duplicate.
    ///   - target: The target handle (will be closed and replaced).
    /// - Returns: The new handle (same as target).
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(
        _ descriptor: Kernel.Descriptor,
        to target: Kernel.Descriptor
    ) throws(Kernel.Descriptor.Duplicate.Error) -> Kernel.Descriptor {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        // Close target if valid (raw form via target._rawValue)
        if target.isValid {
            _ = Kernel.Close.close(target._rawValue)
        }

        return try duplicate(descriptor)
    }
}

// MARK: - Error Construction

extension Kernel.Descriptor.Duplicate.Error {
    /// Creates an error from the current Win32 last error.
    @usableFromInline
    internal static func current() -> Self {
        let code = Windows.Kernel.Error.captureLastError()
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(e)
        }
        return .platform(Kernel.Error(code: code))
    }
}

#endif
