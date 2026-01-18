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

extension Windows.Kernel.IO.Write {
    #Tests
}

// MARK: - Namespace Tests

extension Windows.Kernel.IO.Write.Test.Unit {
    @Test("IO.Write namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.IO.Write.self
    }

    @Test("IO.Write.Error type alias exists")
    func errorTypeExists() {
        _ = Windows.Kernel.IO.Write.Error.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.IO.Write.Test.Unit {
    @Test("write with invalid descriptor throws handle error")
    func writeInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid
        let data: [UInt8] = [1, 2, 3, 4, 5]

        #expect(throws: Kernel.IO.Write.Error.self) {
            try data.withUnsafeBytes { bufferPtr in
                _ = try Windows.Kernel.IO.Write.write(invalid, from: bufferPtr)
            }
        }
    }

    @Test("pwrite with invalid descriptor throws handle error")
    func pwriteInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid
        let data: [UInt8] = [1, 2, 3, 4, 5]

        #expect(throws: Kernel.IO.Write.Error.self) {
            try data.withUnsafeBytes { bufferPtr in
                _ = try Windows.Kernel.IO.Write.pwrite(invalid, from: bufferPtr, at: Kernel.File.Offset(0))
            }
        }
    }
}

// MARK: - Empty Buffer Tests

extension Windows.Kernel.IO.Write.Test.Unit {
    @Test("write with empty buffer returns zero")
    func writeEmptyBufferReturnsZero() throws {
        // Create a temporary file
        let tempPath = "test_write_empty_\(GetCurrentProcessId()).tmp"
        defer { DeleteFileW(tempPath.withCString(encodedAs: UTF16.self) { $0 }) }

        var utf16Path = Array(tempPath.utf16) + [0]
        let handle = utf16Path.withUnsafeMutableBufferPointer { pathPtr in
            CreateFileW(
                pathPtr.baseAddress,
                DWORD(GENERIC_READ | GENERIC_WRITE),
                0,
                nil,
                DWORD(CREATE_ALWAYS),
                DWORD(FILE_ATTRIBUTE_NORMAL),
                nil
            )
        }
        guard handle != INVALID_HANDLE_VALUE else { return }
        defer { CloseHandle(handle) }

        let descriptor = Kernel.Descriptor.borrowing(handle: handle)

        // Write with empty buffer
        let emptyData: [UInt8] = []
        let bytesWritten = try emptyData.withUnsafeBytes { bufferPtr in
            try Windows.Kernel.IO.Write.write(descriptor, from: bufferPtr)
        }

        #expect(bytesWritten == 0)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.IO.Write.Test.EdgeCase {
    @Test("Error type is Kernel.IO.Write.Error")
    func errorTypeIsCorrect() {
        let _: Windows.Kernel.IO.Write.Error.Type = Kernel.IO.Write.Error.self
    }
}

#endif
