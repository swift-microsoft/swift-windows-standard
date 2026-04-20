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
import Kernel_Descriptor_Primitives
import Kernel_Error_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Kernel_Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

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
    @Test("Random namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Random.self
    }
}

// MARK: - BCryptGenRandom Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test
    func `bCryptGenRandom fills buffer without throwing`() throws {
        var buffer = [UInt8](repeating: 0, count: 32)
        try buffer.withUnsafeMutableBytes { bufferPtr throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(bufferPtr)
        }
    }

    @Test
    func `bCryptGenRandom produces non-zero bytes`() throws {
        var buffer = [UInt8](repeating: 0, count: 32)
        try buffer.withUnsafeMutableBytes { bufferPtr throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(bufferPtr)
        }
        // Very unlikely all 32 bytes are zero
        let allZero = buffer.allSatisfy { $0 == 0 }
        #expect(!allZero)
    }

    @Test
    func `bCryptGenRandom with empty buffer is a no-op`() throws {
        var buffer: [UInt8] = []
        try buffer.withUnsafeMutableBytes { bufferPtr throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(bufferPtr)
        }
    }
}

// MARK: - Random Value Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test("uint64 returns value")
    func uint64ReturnsValue() {
        let value = Windows.Kernel.Random.uint64()
        #expect(value != nil)
    }

    @Test("uint32 returns value")
    func uint32ReturnsValue() {
        let value = Windows.Kernel.Random.uint32()
        #expect(value != nil)
    }

    @Test("uint64 produces different values")
    func uint64ProducesDifferent() {
        var values: Set<UInt64> = []
        for _ in 0..<10 {
            if let v = Windows.Kernel.Random.uint64() {
                values.insert(v)
            }
        }
        // Should have at least 9 unique values (statistically near-certain)
        #expect(values.count >= 9)
    }

    @Test("uint32 produces different values")
    func uint32ProducesDifferent() {
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
    func `bCryptGenRandom fills a one-megabyte buffer`() throws {
        var buffer = [UInt8](repeating: 0, count: 1024 * 1024)  // 1MB
        try buffer.withUnsafeMutableBytes { bufferPtr throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(bufferPtr)
        }
    }

    @Test
    func `successive bCryptGenRandom calls produce different bytes`() throws {
        var buffer1 = [UInt8](repeating: 0, count: 32)
        var buffer2 = [UInt8](repeating: 0, count: 32)

        try buffer1.withUnsafeMutableBytes { buffer throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(buffer)
        }
        try buffer2.withUnsafeMutableBytes { buffer throws(Kernel.Random.Error) in
            try Windows.Kernel.Random.bCryptGenRandom(buffer)
        }

        #expect(buffer1 != buffer2)
    }
}

#endif
