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
    import WinSDK
    import Testing

    @testable import Windows_32_Kernel
    import Error_Primitives
    import Path_Primitives
    import Clock_Primitives
    import Random_Primitives
    import System_Primitives

    extension Windows.`32`.Kernel.Directory {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Directory namespace exists`() {
            _ = Windows.`32`.Kernel.Directory.self
        }

        @Test
        func `Directory.Iterator type exists`() {
            _ = Windows.`32`.Kernel.Directory.Iterator.self
        }
    }

    // MARK: - Iterator Tests

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Iterator type exists`() {
            // Type check only — Iterator is ~Copyable (key paths are
            // unsupported) and cannot be created without a real directory.
            _ = Windows.`32`.Kernel.Directory.Iterator.self
        }
    }

    // MARK: - Error Mapping Tests

    extension Windows.`32`.Kernel.Directory.Test.Unit {
        @Test
        func `Error.notFound maps from FILE_NOT_FOUND`() {
            let error = Kernel.Directory.Error(_windowsError: Error_Primitives.Error.Code.File.notFound)
            if case .notFound = error {
                // Expected
            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.notFound maps from PATH_NOT_FOUND`() {
            let error = Kernel.Directory.Error(_windowsError: Error_Primitives.Error.Code.File.pathNotFound)
            if case .notFound = error {
                // Expected
            } else {
                Issue.record("Expected .notFound, got \(error)")
            }
        }

        @Test
        func `Error.permission maps from ACCESS_DENIED`() {
            let error = Kernel.Directory.Error(_windowsError: Error_Primitives.Error.Code.Access.denied)
            if case .permission = error {
                // Expected
            } else {
                Issue.record("Expected .permission, got \(error)")
            }
        }
    }

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.Directory.Test.EdgeCase {
        @Test
        func `Entry type has name, inode, type`() {
            // Check Kernel.Directory.Entry exists with expected properties
            let nameChars: [UInt16] = [0x74, 0x65, 0x73, 0x74, 0x0000]  // "test" (null-terminated)
            let entry = Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: .regular)
            #expect(entry.type == .regular)
        }

        @Test
        func `Entry.isDotOrDotDot detects dot entries`() {
            // rawName is null-terminated (mirrors ISO_9945.Kernel.Directory.Entry)
            let dotName: [UInt16] = [0x2E, 0x0000]  // "."
            let dotEntry = Kernel.Directory.Entry(rawName: dotName, inode: nil, type: .directory)
            #expect(dotEntry.isDotOrDotDot)

            let dotDotName: [UInt16] = [0x2E, 0x2E, 0x0000]  // ".."
            let dotDotEntry = Kernel.Directory.Entry(rawName: dotDotName, inode: nil, type: .directory)
            #expect(dotDotEntry.isDotOrDotDot)

            let normalName: [UInt16] = [0x74, 0x65, 0x73, 0x74, 0x0000]  // "test"
            let normalEntry = Kernel.Directory.Entry(rawName: normalName, inode: nil, type: .regular)
            #expect(!normalEntry.isDotOrDotDot)
        }
    }

#endif
