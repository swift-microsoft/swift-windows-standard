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

    extension Windows.`32`.Kernel.IO.Read {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Windows.`32`.Kernel.IO.Read.Test.Unit {
        @Test
        func `IO.Read namespace exists`() {
            _ = Windows.`32`.Kernel.IO.Read.self
        }

        @Test
        func `IO.Read.Error type alias exists`() {
            _ = Windows.`32`.Kernel.IO.Read.Error.self
        }
    }

    // MARK: - Error Tests

    extension Windows.`32`.Kernel.IO.Read.Test.Unit {
        @Test
        func `read with invalid descriptor throws handle error`() {
            let invalid = Kernel.Descriptor.invalid
            var buffer = [UInt8](repeating: 0, count: 100)

            #expect(throws: Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { bufferPtr in
                    _ = try Windows.`32`.Kernel.IO.Read.read(invalid, into: bufferPtr)
                }
            }
        }

        @Test
        func `pread with invalid descriptor throws handle error`() {
            let invalid = Kernel.Descriptor.invalid
            var buffer = [UInt8](repeating: 0, count: 100)

            #expect(throws: Kernel.IO.Read.Error.self) {
                try buffer.withUnsafeMutableBytes { bufferPtr in
                    _ = try Windows.`32`.Kernel.IO.Read.pread(invalid, into: bufferPtr, at: Kernel.File.Offset(0))
                }
            }
        }
    }

    // MARK: - Empty Buffer Tests

    extension Windows.`32`.Kernel.IO.Read.Test.Unit {
        @Test
        func `read with empty buffer returns zero`() throws {
            // Create a temporary file
            let tempPath = "test_read_empty_\(GetCurrentProcessId()).tmp"
            defer { DeleteFileW(tempPath.withCString(encodedAs: UTF16.self) { $0 }) }

            // Create and write some data
            var utf16Path = Array(tempPath.utf16) + [0]
            let handle = utf16Path.withUnsafeMutableBufferPointer { pathPtr in
                CreateFileW(
                    pathPtr.baseAddress,
                    DWORD(GENERIC_READ) | DWORD(GENERIC_WRITE),
                    0,
                    nil,
                    DWORD(CREATE_ALWAYS),
                    DWORD(FILE_ATTRIBUTE_NORMAL),
                    nil
                )
            }
            guard let handle, handle != INVALID_HANDLE_VALUE else { return }

            // The Descriptor owns the handle; its deinit closes it.
            let descriptor = Kernel.Descriptor(_raw: UInt(bitPattern: handle))

            // Read with empty buffer
            var emptyBuffer: [UInt8] = []
            let bytesRead = try emptyBuffer.withUnsafeMutableBytes { bufferPtr in
                try Windows.`32`.Kernel.IO.Read.read(descriptor, into: bufferPtr)
            }

            #expect(bytesRead == 0)
        }
    }

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.IO.Read.Test.EdgeCase {
        @Test
        func `Kernel.Descriptor.invalid is invalid`() {
            let invalid = Kernel.Descriptor.invalid
            let invalidIsValid = invalid.isValid
            #expect(!invalidIsValid)
        }
    }

#endif
