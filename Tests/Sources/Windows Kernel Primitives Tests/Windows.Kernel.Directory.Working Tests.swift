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
import Testing

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Directory.Working {
    #Tests
}

// MARK: - Namespace Tests

extension Windows.Kernel.Directory.Working.Test.Unit {
    @Test("Directory.Working namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Directory.Working.self
    }
}

// MARK: - Get Tests

extension Windows.Kernel.Directory.Working.Test.Unit {
    @Test("get() returns non-empty path")
    func getReturnsNonEmpty() throws {
        let cwd = try Windows.Kernel.Directory.Working.get()
        #expect(!cwd.isEmpty)
    }

    @Test("get(into:) works with buffer")
    func getIntoBufferWorks() throws {
        var buffer = [UInt16](repeating: 0, count: 260)  // MAX_PATH
        let length = try buffer.withUnsafeMutableBufferPointer { bufferPtr in
            try Windows.Kernel.Directory.Working.get(into: bufferPtr)
        }
        #expect(length > 0)
    }

    @Test("get() result matches GetCurrentDirectoryW")
    func getMatchesWin32() throws {
        let cwd = try Windows.Kernel.Directory.Working.get()

        // Get via Win32 API directly
        var buffer = [WCHAR](repeating: 0, count: 260)
        let length = GetCurrentDirectoryW(DWORD(buffer.count), &buffer)

        #expect(length > 0)
        #expect(cwd.count == Int(length))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Directory.Working.Test.EdgeCase {
    @Test("get(into:) with small buffer throws")
    func getSmallBufferThrows() {
        var buffer = [UInt16](repeating: 0, count: 1)  // Too small

        #expect(throws: Kernel.Directory.Working.Error.self) {
            try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                _ = try Windows.Kernel.Directory.Working.get(into: bufferPtr)
            }
        }
    }
}

#endif
