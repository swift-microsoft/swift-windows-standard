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
import Kernel_Primitives_Core
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Windows.Kernel.Directory.Working {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Directory.Working.Test.Unit {
    @Test
    func `Directory.Working namespace exists`() {
        _ = Windows.Kernel.Directory.Working.self
    }
}

// MARK: - Get Tests

extension Windows.Kernel.Directory.Working.Test.Unit {
    @Test
    func `get() returns non-empty path`() throws {
        let cwd = try Windows.Kernel.Directory.Working.get()
        #expect(!cwd.isEmpty)
    }

    @Test
    func `get(into:) works with buffer`() throws {
        var buffer = [UInt16](repeating: 0, count: 260)  // MAX_PATH
        let length = try buffer.withUnsafeMutableBufferPointer { bufferPtr in
            try Windows.Kernel.Directory.Working.get(into: bufferPtr)
        }
        #expect(length > 0)
    }

    @Test
    func `get() result matches GetCurrentDirectoryW`() throws {
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
    @Test
    func `get(into:) with small buffer throws`() {
        var buffer = [UInt16](repeating: 0, count: 1)  // Too small

        #expect(throws: Kernel.Directory.Working.Error.self) {
            try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                _ = try Windows.Kernel.Directory.Working.get(into: bufferPtr)
            }
        }
    }
}

#endif
