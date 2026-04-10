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

extension Windows.Kernel.Pipe {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Pipe.Test.Unit {
    @Test("Pipe namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Pipe.self
    }

    @Test("Pipe.Pair type exists")
    func pairTypeExists() {
        _ = Windows.Kernel.Pipe.Pair.self
    }
}

// MARK: - Pipe Creation Tests

extension Windows.Kernel.Pipe.Test.Unit {
    @Test("create returns valid pair")
    func createReturnsValidPair() throws {
        let pair = try Windows.Kernel.Pipe.create()

        #expect(pair.read.isValid)
        #expect(pair.write.isValid)
        #expect(pair.read.rawValue != pair.write.rawValue)

        // Clean up
        try? Kernel.Close.close(pair.read)
        try? Kernel.Close.close(pair.write)
    }

    @Test("create with buffer size")
    func createWithBufferSize() throws {
        let pair = try Windows.Kernel.Pipe.create(bufferSize: 4096)

        #expect(pair.read.isValid)
        #expect(pair.write.isValid)

        // Clean up
        try? Kernel.Close.close(pair.read)
        try? Kernel.Close.close(pair.write)
    }

    @Test("create with inheritance flags")
    func createWithInheritance() throws {
        let pair = try Windows.Kernel.Pipe.create(
            bufferSize: 0,
            inheritRead: true,
            inheritWrite: false
        )

        #expect(pair.read.isValid)
        #expect(pair.write.isValid)

        // Clean up
        try? Kernel.Close.close(pair.read)
        try? Kernel.Close.close(pair.write)
    }

    @Test("create multiple pipes are independent")
    func createMultiplePipes() throws {
        let pair1 = try Windows.Kernel.Pipe.create()
        let pair2 = try Windows.Kernel.Pipe.create()

        #expect(pair1.read.rawValue != pair2.read.rawValue)
        #expect(pair1.write.rawValue != pair2.write.rawValue)

        // Clean up
        try? Kernel.Close.close(pair1.read)
        try? Kernel.Close.close(pair1.write)
        try? Kernel.Close.close(pair2.read)
        try? Kernel.Close.close(pair2.write)
    }
}

// MARK: - Pair Properties Tests

extension Windows.Kernel.Pipe.Test.Unit {
    @Test("Pair.read is accessible")
    func pairReadAccessible() throws {
        let pair = try Windows.Kernel.Pipe.create()
        defer {
            try? Kernel.Close.close(pair.read)
            try? Kernel.Close.close(pair.write)
        }

        #expect(pair.read.isValid)
    }

    @Test("Pair.write is accessible")
    func pairWriteAccessible() throws {
        let pair = try Windows.Kernel.Pipe.create()
        defer {
            try? Kernel.Close.close(pair.read)
            try? Kernel.Close.close(pair.write)
        }

        #expect(pair.write.isValid)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Pipe.Test.EdgeCase {
    @Test("create and close many pipes")
    func createAndCloseManyPipes() throws {
        for _ in 0..<100 {
            let pair = try Windows.Kernel.Pipe.create()
            try? Kernel.Close.close(pair.read)
            try? Kernel.Close.close(pair.write)
        }
    }
}

#endif
