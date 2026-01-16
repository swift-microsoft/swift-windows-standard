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

extension Windows.Kernel.Path.Canonical {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Path.Canonical.Test.Unit {
    @Test("Path.Canonical namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Path.Canonical.self
    }
}

// MARK: - Resolve Tests

extension Windows.Kernel.Path.Canonical.Test.Unit {
    @Test("resolve current directory succeeds")
    func resolveCurrentDirectorySucceeds() throws {
        var path = Array(".".utf16) + [0]
        let result = try path.withUnsafeBufferPointer { pathPtr in
            let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
            return try Windows.Kernel.Path.Canonical.resolve(unsafePath: wpath)
        }

        #expect(!result.isEmpty)
    }

    @Test("resolve with buffer succeeds")
    func resolveWithBufferSucceeds() throws {
        var path = Array(".".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 260)

        let length = try path.withUnsafeBufferPointer { pathPtr in
            try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                return try Windows.Kernel.Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
            }
        }

        #expect(length > 0)
    }

    @Test("resolve absolute path returns same path")
    func resolveAbsolutePathReturnsSame() throws {
        var path = Array("C:\\Windows".utf16) + [0]
        let result = try path.withUnsafeBufferPointer { pathPtr in
            let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
            return try Windows.Kernel.Path.Canonical.resolve(unsafePath: wpath)
        }

        let resultString = String(decoding: result, as: UTF16.self)
        #expect(resultString.uppercased().hasPrefix("C:\\WINDOWS"))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Path.Canonical.Test.EdgeCase {
    @Test("resolve with small buffer throws")
    func resolveSmallBufferThrows() {
        var path = Array("C:\\Windows\\System32".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 5)  // Too small

        #expect(throws: Kernel.Path.Canonical.Error.self) {
            try path.withUnsafeBufferPointer { pathPtr in
                try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                    let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    _ = try Windows.Kernel.Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
                }
            }
        }
    }
}

#endif
