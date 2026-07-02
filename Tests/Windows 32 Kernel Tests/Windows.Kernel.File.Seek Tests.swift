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

extension Windows.`32`.Kernel.File.Seek {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.File.Seek.Test.Unit {
    @Test
    func `Seek namespace exists`() {
        _ = Windows.`32`.Kernel.File.Seek.self
    }

    @Test
    func `Seek.Error type alias exists`() {
        _ = Windows.`32`.Kernel.File.Seek.Error.self
    }

    @Test
    func `Seek.Origin type alias exists`() {
        _ = Windows.`32`.Kernel.File.Seek.Origin.self
    }
}

// MARK: - Origin Tests

extension Windows.`32`.Kernel.File.Seek.Test.Unit {
    @Test
    func `Origin.start exists`() {
        let origin = Kernel.File.Seek.Origin.start
        #expect(origin == .start)
    }

    @Test
    func `Origin.current exists`() {
        let origin = Kernel.File.Seek.Origin.current
        #expect(origin == .current)
    }

    @Test
    func `Origin.end exists`() {
        let origin = Kernel.File.Seek.Origin.end
        #expect(origin == .end)
    }
}

// MARK: - Windows Conversion Tests

extension Windows.`32`.Kernel.File.Seek.Test.Unit {
    @Test
    func `Origin.start converts to FILE_BEGIN`() {
        let origin = Kernel.File.Seek.Origin.start
        #expect(origin.windowsMoveMethod == DWORD(FILE_BEGIN))
    }

    @Test
    func `Origin.current converts to FILE_CURRENT`() {
        let origin = Kernel.File.Seek.Origin.current
        #expect(origin.windowsMoveMethod == DWORD(FILE_CURRENT))
    }

    @Test
    func `Origin.end converts to FILE_END`() {
        let origin = Kernel.File.Seek.Origin.end
        #expect(origin.windowsMoveMethod == DWORD(FILE_END))
    }
}

// MARK: - Error Tests

extension Windows.`32`.Kernel.File.Seek.Test.Unit {
    @Test
    func `seek with invalid descriptor throws`() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.File.Seek.Error.self) {
            _ = try Windows.`32`.Kernel.File.Seek.seek(invalid, offset: 0, origin: .start)
        }
    }

    @Test
    func `tell with invalid descriptor throws`() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.File.Seek.Error.self) {
            _ = try Windows.`32`.Kernel.File.Seek.tell(invalid)
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.File.Seek.Test.EdgeCase {
    @Test
    func `Error.invalidDescriptor exists`() {
        let error = Kernel.File.Seek.Error.invalidDescriptor
        #expect(error == .invalidDescriptor)
    }

    @Test
    func `Error.negativeOffset exists`() {
        let error = Kernel.File.Seek.Error.negativeOffset
        #expect(error == .negativeOffset)
    }

    @Test
    func `Error.notSeekable exists`() {
        let error = Kernel.File.Seek.Error.notSeekable
        #expect(error == .notSeekable)
    }
}

#endif
