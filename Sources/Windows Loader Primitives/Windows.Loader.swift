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

public import Windows_Primitives_Core
public import Loader_Primitives

extension Windows_Primitives_Core.Windows {
    /// Windows dynamic loader mechanisms.
    ///
    /// This is a typealias to `Loader_Primitives.Loader`, allowing Windows-specific
    /// extensions to be added to the shared Loader type.
    ///
    /// Windows loader wrappers for:
    /// - Library loading (LoadLibraryW, FreeLibrary)
    /// - Symbol lookup (GetProcAddress)
    public typealias Loader = Loader_Primitives.Loader
}
