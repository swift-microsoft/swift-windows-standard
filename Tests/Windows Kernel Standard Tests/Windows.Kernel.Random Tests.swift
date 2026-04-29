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
import Standard_Library_Extensions

@testable import Windows_Kernel_Standard
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import System_Primitives

extension Windows.Kernel.Random {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test
    func `Random namespace exists`() {
        _ = Windows.Kernel.Random.self
    }
}

// MARK: - BCryptGenRandom Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test
    func `bCryptGenRandom fills buffer without throwing`() throws(Random.Error) {
        var buffer: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)  // 32 bytes
        try withUnsafeMutableBytes(of: &buffer) { raw throws(Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(raw)
        }
    }

    @Test
    func `bCryptGenRandom produces non-zero bytes`() throws(Random.Error) {
        var buffer: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)  // 32 bytes
        try withUnsafeMutableBytes(of: &buffer) { raw throws(Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(raw)
        }
        // Very unlikely all 32 bytes are zero
        #expect(buffer != (0, 0, 0, 0))
    }

    @Test
    func `bCryptGenRandom with empty buffer is a no-op`() throws(Random.Error) {
        let buffer = UnsafeMutableRawBufferPointer(start: nil, count: 0)
        try Windows.Kernel.Random.bCryptGenRandom(buffer)
    }
}

// MARK: - Random Value Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test
    func `uint64 returns value`() {
        let value = Windows.Kernel.Random.uint64()
        #expect(value != nil)
    }

    @Test
    func `uint32 returns value`() {
        let value = Windows.Kernel.Random.uint32()
        #expect(value != nil)
    }

    @Test
    func `uint64 produces different values`() {
        var values: Set<UInt64> = []
        for _ in 0..<10 {
            if let v = Windows.Kernel.Random.uint64() {
                values.insert(v)
            }
        }
        // Should have at least 9 unique values (statistically near-certain)
        #expect(values.count >= 9)
    }

    @Test
    func `uint32 produces different values`() {
        var values: Set<UInt32> = []
        for _ in 0..<10 {
            if let v = Windows.Kernel.Random.uint32() {
                values.insert(v)
            }
        }
        #expect(values.count >= 9)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Random.Test.EdgeCase {
    @Test
    func `bCryptGenRandom fills a one-megabyte buffer`() throws(Random.Error) {
        let buffer = UnsafeMutableRawBufferPointer.allocate(byteCount: 1024 * 1024, alignment: 1)
        defer { buffer.deallocate() }
        buffer.initializeMemory(as: UInt8.self, repeating: 0)
        try Windows.Kernel.Random.bCryptGenRandom(buffer)
    }

    @Test
    func `successive bCryptGenRandom calls produce different bytes`() throws(Random.Error) {
        var first: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)
        var second: (UInt64, UInt64, UInt64, UInt64) = (0, 0, 0, 0)

        try withUnsafeMutableBytes(of: &first) { raw throws(Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(raw)
        }
        try withUnsafeMutableBytes(of: &second) { raw throws(Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(raw)
        }

        #expect(first != second)
    }
}

#endif
