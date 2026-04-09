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

@testable import Windows_Kernel_Primitives
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

// MARK: - Fill Tests

extension Windows.Kernel.Random.Test.Unit {
    @Test("fill buffer succeeds")
    func fillBufferSucceeds() {
        var buffer = [UInt8](repeating: 0, count: 32)
        let success = buffer.withUnsafeMutableBytes { bufferPtr in
            Windows.Kernel.Random.fill(bufferPtr)
        }
        #expect(success)
    }

    @Test("fill produces non-zero data")
    func fillProducesNonZero() {
        var buffer = [UInt8](repeating: 0, count: 32)
        _ = buffer.withUnsafeMutableBytes { bufferPtr in
            Windows.Kernel.Random.fill(bufferPtr)
        }
        // Very unlikely all 32 bytes are zero
        let allZero = buffer.allSatisfy { $0 == 0 }
        #expect(!allZero)
    }

    @Test("fill empty buffer succeeds")
    func fillEmptyBufferSucceeds() {
        var buffer: [UInt8] = []
        let success = buffer.withUnsafeMutableBytes { bufferPtr in
            Windows.Kernel.Random.fill(bufferPtr)
        }
        #expect(success)
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
    @Test("fill large buffer succeeds")
    func fillLargeBufferSucceeds() {
        var buffer = [UInt8](repeating: 0, count: 1024 * 1024)  // 1MB
        let success = buffer.withUnsafeMutableBytes { bufferPtr in
            Windows.Kernel.Random.fill(bufferPtr)
        }
        #expect(success)
    }

    @Test("multiple fills produce different data")
    func multipleFillsDifferent() {
        var buffer1 = [UInt8](repeating: 0, count: 32)
        var buffer2 = [UInt8](repeating: 0, count: 32)

        _ = buffer1.withUnsafeMutableBytes { Windows.Kernel.Random.fill($0) }
        _ = buffer2.withUnsafeMutableBytes { Windows.Kernel.Random.fill($0) }

        #expect(buffer1 != buffer2)
    }
}

#endif
