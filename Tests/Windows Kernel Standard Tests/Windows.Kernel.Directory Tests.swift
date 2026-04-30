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

@testable import Windows_Kernel_Standard
import Error_Primitives
import Path_Primitives
import Clock_Primitives
import Random_Primitives
import System_Primitives

extension Windows.Kernel.Directory {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Directory.Test.Unit {
    @Test
    func `Directory namespace exists`() {
        _ = Windows.Kernel.Directory.self
    }

    @Test
    func `Directory.Iterator type exists`() {
        _ = Windows.Kernel.Directory.Iterator.self
    }
}

// MARK: - Iterator Tests

extension Windows.Kernel.Directory.Test.Unit {
    @Test
    func `Iterator has handle property`() {
        // Type check only - can't create iterator without real directory
        _ = \Windows.Kernel.Directory.Iterator.handle
    }

    @Test
    func `Iterator has findData property`() {
        _ = \Windows.Kernel.Directory.Iterator.findData
    }

    @Test
    func `Iterator has firstEntry property`() {
        _ = \Windows.Kernel.Directory.Iterator.firstEntry
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Directory.Test.Unit {
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

extension Windows.Kernel.Directory.Test.EdgeCase {
    @Test
    func `Entry type has name, inode, type`() {
        // Check Kernel.Directory.Entry exists with expected properties
        let nameChars: [UInt16] = [0x74, 0x65, 0x73, 0x74]  // "test"
        let entry = Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: .regular)
        #expect(entry.type == .regular)
    }

    @Test
    func `Entry.isDotOrDotDot detects dot entries`() {
        let dotName: [UInt16] = [0x2E]  // "."
        let dotEntry = Kernel.Directory.Entry(rawName: dotName, inode: nil, type: .directory)
        #expect(dotEntry.isDotOrDotDot)

        let dotDotName: [UInt16] = [0x2E, 0x2E]  // ".."
        let dotDotEntry = Kernel.Directory.Entry(rawName: dotDotName, inode: nil, type: .directory)
        #expect(dotDotEntry.isDotOrDotDot)

        let normalName: [UInt16] = [0x74, 0x65, 0x73, 0x74]  // "test"
        let normalEntry = Kernel.Directory.Entry(rawName: normalName, inode: nil, type: .regular)
        #expect(!normalEntry.isDotOrDotDot)
    }
}

#endif
