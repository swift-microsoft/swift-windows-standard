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
import Kernel_Descriptor_Primitives
import Kernel_Error_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives

extension Windows.Kernel.IO.Read {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.IO.Read.Test.Unit {
    @Test("IO.Read namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.IO.Read.self
    }

    @Test("IO.Read.Error type alias exists")
    func errorTypeExists() {
        _ = Windows.Kernel.IO.Read.Error.self
    }
}

// MARK: - Error Tests

extension Windows.Kernel.IO.Read.Test.Unit {
    @Test("read with invalid descriptor throws handle error")
    func readInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid
        var buffer = [UInt8](repeating: 0, count: 100)

        #expect(throws: Kernel.IO.Read.Error.self) {
            try buffer.withUnsafeMutableBytes { bufferPtr in
                _ = try Windows.Kernel.IO.Read.read(invalid, into: bufferPtr)
            }
        }
    }

    @Test("pread with invalid descriptor throws handle error")
    func preadInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid
        var buffer = [UInt8](repeating: 0, count: 100)

        #expect(throws: Kernel.IO.Read.Error.self) {
            try buffer.withUnsafeMutableBytes { bufferPtr in
                _ = try Windows.Kernel.IO.Read.pread(invalid, into: bufferPtr, at: Kernel.File.Offset(0))
            }
        }
    }
}

// MARK: - Empty Buffer Tests

extension Windows.Kernel.IO.Read.Test.Unit {
    @Test("read with empty buffer returns zero")
    func readEmptyBufferReturnsZero() throws {
        // Create a temporary file
        let tempPath = "test_read_empty_\(GetCurrentProcessId()).tmp"
        defer { DeleteFileW(tempPath.withCString(encodedAs: UTF16.self) { $0 }) }

        // Create and write some data
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

        // Read with empty buffer
        var emptyBuffer: [UInt8] = []
        let bytesRead = try emptyBuffer.withUnsafeMutableBytes { bufferPtr in
            try Windows.Kernel.IO.Read.read(descriptor, into: bufferPtr)
        }

        #expect(bytesRead == 0)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.IO.Read.Test.EdgeCase {
    @Test("Kernel.Descriptor.invalid is invalid")
    func invalidDescriptorIsInvalid() {
        let invalid = Kernel.Descriptor.invalid
        #expect(!invalid.isValid)
    }
}

#endif
