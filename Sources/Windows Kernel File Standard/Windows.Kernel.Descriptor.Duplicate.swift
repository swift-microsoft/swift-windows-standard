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

// MARK: - Windows DuplicateHandle syscall

extension Windows.Kernel.Descriptor.Duplicate {
    /// Duplicates a handle.
    ///
    /// Creates a duplicate of the specified handle with the same access rights.
    /// The new handle refers to the same underlying kernel object.
    ///
    /// - Parameter descriptor: The handle to duplicate.
    /// - Returns: The duplicated handle.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(_ descriptor: Kernel.Descriptor) throws(Kernel.Descriptor.Duplicate.Error) -> Kernel.Descriptor {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        let currentProcess = GetCurrentProcess()
        var newHandle: HANDLE? = nil

        let success = DuplicateHandle(
            currentProcess,
            descriptor.handle,
            currentProcess,
            &newHandle,
            0,
            false,
            DWORD(DUPLICATE_SAME_ACCESS)
        )

        guard success, let handle = newHandle else {
            throw .current()
        }

        return Kernel.Descriptor.borrowing(handle: handle)
    }

    /// Duplicates a handle to a specific target handle value.
    ///
    /// On Windows, this closes the target handle first if it's valid,
    /// then duplicates the source to it.
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

        // Close target if valid
        if target.isValid {
            _ = CloseHandle(target.handle)
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
