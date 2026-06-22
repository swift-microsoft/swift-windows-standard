// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

// MARK: - Windows Decomposition Conformance

// Windows path separators: primary `\` (0x5C), alt `/` (0x2F).
//
// Both separators count for decomposition per Win32 convention — any of
// `C:\Users\foo`, `C:/Users/foo`, `C:\Users/foo` decomposes to the same
// component sequence. `Path.Scan.lastSeparatorIndex` accepts a primary +
// alt byte for exactly this case.
//
// Drive-letter canonicalization (e.g., `C:\foo` → parent `C:\`) is L3
// policy per `Path.Scan` documentation — this L2 conformance does the
// byte scan only. See `Path.Borrowed+Path.Modification.swift`
// for the appending half of the split.

extension Path.Borrowed: @retroactive Path.Decomposition {
    public typealias Char = Path.Char

    @inlinable
    @_lifetime(copy view)
    public static func parent(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char>? {
        guard let lastSep = Path.Scan.lastSeparatorIndex(
            in: view.span,
            primary: 0x5C,
            alt: 0x2F
        ) else { return nil }
        // Root-only separator — no parent exists.
        if lastSep == 0 && view.count == 1 { return nil }
        // Separator at index 0 with content after → parent is the root
        // separator byte alone (1 byte).
        let parentCount = lastSep == 0 ? 1 : lastSep
        return unsafe _overrideLifetime(
            Span(_unsafeStart: view.pointer, count: parentCount),
            copying: view
        )
    }

    @inlinable
    @_lifetime(copy view)
    public static func component(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char> {
        guard let lastSep = Path.Scan.lastSeparatorIndex(
            in: view.span,
            primary: 0x5C,
            alt: 0x2F
        ) else {
            // No separator → full view is the component.
            return unsafe _overrideLifetime(
                Span(_unsafeStart: view.pointer, count: view.count),
                copying: view
            )
        }
        let offset = lastSep + 1
        return unsafe _overrideLifetime(
            Span(_unsafeStart: view.pointer + offset, count: view.count - offset),
            copying: view
        )
    }
}

#endif
