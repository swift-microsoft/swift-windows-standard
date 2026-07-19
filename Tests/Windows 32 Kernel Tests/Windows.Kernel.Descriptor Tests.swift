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
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives

    extension Windows.`32`.Kernel.Descriptor {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - owning(handle:) Tests (F-005 regression)
    //
    // `Descriptor` is `~Copyable` with a `deinit` that unconditionally
    // closes a valid wrapped `HANDLE` via `CloseHandle`. The factory used to
    // be spelled `borrowing(handle:)`, implying the caller keeps ownership
    // — but the returned value closes the handle on drop exactly like every
    // other `Descriptor`, same as if the caller had transferred ownership.
    // A caller who took the "borrowing" name at face value (e.g. wrapping a
    // HANDLE they don't own, just to pass it through a `Descriptor`-typed
    // API) would have their handle silently closed out from under them.
    // Renaming to `owning(handle:)` makes the unconditional close visible
    // at the call site; there is no non-owning variant of this type.

    extension Windows.`32`.Kernel.Descriptor.Test.Unit {
        @Test
        func `owning(handle:) exists and constructs a descriptor from a raw HANDLE`() {
            // Compiles only post-fix: pre-fix, this factory was named
            // `borrowing(handle:)`, not `owning(handle:)`.
            let descriptor = Windows.`32`.Kernel.Descriptor.owning(handle: INVALID_HANDLE_VALUE)
            #expect(!descriptor.isValid)
        }

        @Test
        func `owning(handle:) round-trips the same raw HANDLE bit pattern`() {
            let invalid = Kernel.Descriptor.invalid
            let originalHandle = invalid.handle

            let descriptor = Windows.`32`.Kernel.Descriptor.owning(handle: originalHandle)
            #expect(descriptor.handle == originalHandle)
            #expect(descriptor._rawValue == invalid._rawValue)
        }
    }

#endif
