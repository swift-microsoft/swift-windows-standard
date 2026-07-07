// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

    // MARK: - Windows error number type
    //
    // `Error_Primitives.Error.Number` is the Win32-shaped (UInt32) tagged wrapper.
    // The POSIX (Int32) counterpart is declared by `swift-iso-9945`. Each
    // platform package contributes the typealias that is correct for its
    // platform per [PLAT-ARCH-008c]; consumers see a single unified name via
    // the re-export chain exposed by `import Kernel`.

    extension Error_Primitives.Error {
        /// Platform error number (Win32 GetLastError).
        ///
        /// A type-safe wrapper for Windows error codes.
        public typealias Number = Tagged<Error_Primitives.Error, UInt32>
    }
#endif
