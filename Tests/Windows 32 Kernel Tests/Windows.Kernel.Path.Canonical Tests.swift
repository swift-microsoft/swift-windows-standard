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

extension Path.Canonical {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Path.Canonical.Test.Unit {
    @Test
    func `Path.Canonical namespace exists`() {
        _ = Path.Canonical.self
    }
}

// MARK: - Resolve Tests

extension Path.Canonical.Test.Unit {
    @Test
    func `resolve current directory succeeds`() throws {
        var path = Array(".".utf16) + [0]
        let result = try path.withUnsafeBufferPointer { pathPtr in
            let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
            return try Path.Canonical.resolve(unsafePath: wpath)
        }

        #expect(!result.isEmpty)
    }

    @Test
    func `resolve with buffer succeeds`() throws {
        var path = Array(".".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 260)

        let length = try path.withUnsafeBufferPointer { pathPtr in
            try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                return try Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
            }
        }

        #expect(length > 0)
    }

    @Test
    func `resolve absolute path returns same path`() throws {
        var path = Array("C:\\Windows".utf16) + [0]
        let result = try path.withUnsafeBufferPointer { pathPtr in
            let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
            return try Path.Canonical.resolve(unsafePath: wpath)
        }

        let resultString = String(decoding: result, as: UTF16.self)
        #expect(resultString.uppercased().hasPrefix("C:\\WINDOWS"))
    }
}

// MARK: - Edge Cases

extension Path.Canonical.Test.EdgeCase {
    @Test
    func `resolve with small buffer throws`() {
        var path = Array("C:\\Windows\\System32".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 5)  // Too small

        #expect(throws: Path.Canonical.Error.self) {
            try path.withUnsafeBufferPointer { pathPtr in
                try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                    let wpath = UnsafeRawPointer(pathPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    _ = try Path.Canonical.resolve(unsafePath: wpath, into: bufferPtr)
                }
            }
        }
    }
}

#endif
