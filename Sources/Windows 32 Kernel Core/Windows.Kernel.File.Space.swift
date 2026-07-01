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

extension Windows.`32`.Kernel.File {
    /// Phantom coordinate-space marker for the file position/size domain.
    ///
    /// Parameterizes the dimensional file quantities — `Offset`
    /// (`Coordinate.X<Space>.Value<Int64>`) and `Size`
    /// (`Magnitude<Space>.Value<Int64>`) — so file-domain values inhabit a
    /// distinct dimensional space and cannot be silently mixed with other
    /// coordinate spaces. A pure type-level tag; it is never instantiated.
    ///
    /// Declared in Kernel Core (unguarded, alongside the `File` namespace) so
    /// both `File.Offset` (Kernel Core) and `File.Size` (Kernel File) resolve
    /// the unqualified `Space` in their typealiases to this sibling member.
    /// Mirrors `ISO_9945.Kernel.File.Space`.
    public enum Space {}
}
