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
import Test_Primitives
import Testing_Extras

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Directory {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Directory.Test.Unit {
    @Test("Directory namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Directory.self
    }

    @Test("Directory.Iterator type exists")
    func iteratorTypeExists() {
        _ = Windows.Kernel.Directory.Iterator.self
    }
}

// MARK: - Iterator Tests

extension Windows.Kernel.Directory.Test.Unit {
    @Test("Iterator has handle property")
    func iteratorHasHandle() {
        // Type check only - can't create iterator without real directory
        _ = \Windows.Kernel.Directory.Iterator.handle
    }

    @Test("Iterator has findData property")
    func iteratorHasFindData() {
        _ = \Windows.Kernel.Directory.Iterator.findData
    }

    @Test("Iterator has firstEntry property")
    func iteratorHasFirstEntry() {
        _ = \Windows.Kernel.Directory.Iterator.firstEntry
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Directory.Test.Unit {
    @Test("Error.notFound maps from FILE_NOT_FOUND")
    func errorNotFoundMapsFromFileNotFound() {
        let error = Kernel.Directory.Error(_windowsError: Windows.Kernel.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.notFound maps from PATH_NOT_FOUND")
    func errorNotFoundMapsFromPathNotFound() {
        let error = Kernel.Directory.Error(_windowsError: Windows.Kernel.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test("Error.permission maps from ACCESS_DENIED")
    func errorPermissionMapsFromAccessDenied() {
        let error = Kernel.Directory.Error(_windowsError: Windows.Kernel.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Directory.Test.EdgeCase {
    @Test("Entry type has name, inode, type")
    func entryTypeStructure() {
        // Check Kernel.Directory.Entry exists with expected properties
        let nameChars: [UInt16] = [0x74, 0x65, 0x73, 0x74]  // "test"
        let entry = Kernel.Directory.Entry(rawName: nameChars, inode: nil, type: .regular)
        #expect(entry.type == .regular)
    }

    @Test("Entry.isDotOrDotDot detects dot entries")
    func entryDotDetection() {
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
