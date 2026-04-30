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
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Windows.Kernel.Environment {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Environment.Test.Unit {
    @Test
    func `Environment namespace exists`() {
        _ = Windows.Kernel.Environment.self
    }
}

// MARK: - Get Tests

extension Windows.Kernel.Environment.Test.Unit {
    @Test
    func `get PATH returns value`() {
        var name = Array("PATH".utf16) + [0]
        let result = name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return Windows.Kernel.Environment.get(name: wname)
        }

        #expect(result != nil)
        #expect(!result!.isEmpty)
    }

    @Test
    func `get nonexistent variable returns nil`() {
        var name = Array("NONEXISTENT_VAR_12345_\(GetCurrentProcessId())".utf16) + [0]
        let result = name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return Windows.Kernel.Environment.get(name: wname)
        }

        #expect(result == nil)
    }

    @Test
    func `get with buffer works`() throws {
        var name = Array("PATH".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 32768)  // MAX_ENV_VALUE

        let length = try name.withUnsafeBufferPointer { namePtr in
            try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                return try Windows.Kernel.Environment.get(name: wname, into: bufferPtr)
            }
        }

        #expect(length > 0)
    }
}

// MARK: - Set and Unset Tests

extension Windows.Kernel.Environment.Test.Unit {
    @Test
    func `set and get round-trip`() throws {
        let varName = "TEST_VAR_\(GetCurrentProcessId())"
        let varValue = "test_value_12345"

        var name = Array(varName.utf16) + [0]
        var value = Array(varValue.utf16) + [0]

        // Set
        try name.withUnsafeBufferPointer { namePtr in
            try value.withUnsafeBufferPointer { valuePtr in
                let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                let wvalue = UnsafeRawPointer(valuePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                try Windows.Kernel.Environment.set(name: wname, value: wvalue)
            }
        }

        // Get
        let result = name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return Windows.Kernel.Environment.get(name: wname)
        }

        #expect(result != nil)
        let resultString = String(decoding: result!, as: UTF16.self)
        #expect(resultString == varValue)

        // Clean up
        try name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            try Windows.Kernel.Environment.unset(name: wname)
        }
    }

    @Test
    func `unset removes variable`() throws {
        let varName = "TEST_UNSET_VAR_\(GetCurrentProcessId())"

        var name = Array(varName.utf16) + [0]
        var value = Array("value".utf16) + [0]

        // Set
        try name.withUnsafeBufferPointer { namePtr in
            try value.withUnsafeBufferPointer { valuePtr in
                let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                let wvalue = UnsafeRawPointer(valuePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                try Windows.Kernel.Environment.set(name: wname, value: wvalue)
            }
        }

        // Unset
        try name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            try Windows.Kernel.Environment.unset(name: wname)
        }

        // Verify gone
        let result = name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return Windows.Kernel.Environment.get(name: wname)
        }

        #expect(result == nil)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Environment.Test.EdgeCase {
    @Test
    func `unset nonexistent variable succeeds`() throws {
        let varName = "NONEXISTENT_UNSET_\(GetCurrentProcessId())"
        var name = Array(varName.utf16) + [0]

        // Should not throw - variable already doesn't exist
        try name.withUnsafeBufferPointer { namePtr in
            let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            try Windows.Kernel.Environment.unset(name: wname)
        }
    }

    @Test
    func `get with small buffer throws`() {
        var name = Array("PATH".utf16) + [0]
        var buffer = [UInt16](repeating: 0, count: 1)  // Too small

        #expect(throws: Kernel.Environment.Error.self) {
            try name.withUnsafeBufferPointer { namePtr in
                try buffer.withUnsafeMutableBufferPointer { bufferPtr in
                    let wname = UnsafeRawPointer(namePtr.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                    _ = try Windows.Kernel.Environment.get(name: wname, into: bufferPtr)
                }
            }
        }
    }
}

#endif
