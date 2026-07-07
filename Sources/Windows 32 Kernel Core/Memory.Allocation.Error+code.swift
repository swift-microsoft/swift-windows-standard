// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Windows-only: `.Windows` error-code constants and `.win32` cases exist
// in Error_Primitives only on Windows.
#if os(Windows)

    public import Error_Primitives
    public import Memory_Allocation_Primitives

    // MARK: - Win32 Error Code Mapping

    // Mirrors `ISO 9945.Memory.Allocation.Error+code.swift` (POSIX maps ENOMEM);
    // consumed by swift-kernel's `Kernel.Failure.init?(_:)` domain cascade.

    extension Memory.Allocation.Error {
        /// Creates an allocation error from a Win32 error code, if applicable.
        ///
        /// Returns `nil` if the code does not map to a memory allocation failure.
        ///
        /// - Parameter code: The platform error code.
        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            switch code {
            case .Windows.ERROR_NOT_ENOUGH_MEMORY,
                .win32(14):  // ERROR_OUTOFMEMORY (no named constant yet)
                self = .exhausted
            default:
                return nil
            }
        }
    }

#endif
