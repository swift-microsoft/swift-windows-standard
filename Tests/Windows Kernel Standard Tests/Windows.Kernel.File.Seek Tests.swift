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
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_IO_Primitives

extension Windows.Kernel.Seek {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Seek.Test.Unit {
    @Test("Seek namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Seek.self
    }

    @Test("Seek.Error type alias exists")
    func errorTypeExists() {
        _ = Windows.Kernel.Seek.Error.self
    }

    @Test("Seek.Origin type alias exists")
    func originTypeExists() {
        _ = Windows.Kernel.Seek.Origin.self
    }
}

// MARK: - Origin Tests

extension Windows.Kernel.Seek.Test.Unit {
    @Test("Origin.start exists")
    func originStartExists() {
        let origin = Kernel.Seek.Origin.start
        #expect(origin == .start)
    }

    @Test("Origin.current exists")
    func originCurrentExists() {
        let origin = Kernel.Seek.Origin.current
        #expect(origin == .current)
    }

    @Test("Origin.end exists")
    func originEndExists() {
        let origin = Kernel.Seek.Origin.end
        #expect(origin == .end)
    }
}

// MARK: - Windows Conversion Tests

extension Windows.Kernel.Seek.Test.Unit {
    @Test("Origin.start converts to FILE_BEGIN")
    func originStartConverts() {
        let origin = Kernel.Seek.Origin.start
        #expect(origin.windowsMoveMethod == DWORD(FILE_BEGIN))
    }

    @Test("Origin.current converts to FILE_CURRENT")
    func originCurrentConverts() {
        let origin = Kernel.Seek.Origin.current
        #expect(origin.windowsMoveMethod == DWORD(FILE_CURRENT))
    }

    @Test("Origin.end converts to FILE_END")
    func originEndConverts() {
        let origin = Kernel.Seek.Origin.end
        #expect(origin.windowsMoveMethod == DWORD(FILE_END))
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Seek.Test.Unit {
    @Test("seek with invalid descriptor throws")
    func seekInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Seek.Error.self) {
            _ = try Windows.Kernel.Seek.seek(invalid, offset: 0, origin: .start)
        }
    }

    @Test("tell with invalid descriptor throws")
    func tellInvalidDescriptorThrows() {
        let invalid = Kernel.Descriptor.invalid

        #expect(throws: Kernel.Seek.Error.self) {
            _ = try Windows.Kernel.Seek.tell(invalid)
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Seek.Test.EdgeCase {
    @Test("Error.invalidDescriptor exists")
    func errorInvalidDescriptorExists() {
        let error = Kernel.Seek.Error.invalidDescriptor
        #expect(error == .invalidDescriptor)
    }

    @Test("Error.negativeOffset exists")
    func errorNegativeOffsetExists() {
        let error = Kernel.Seek.Error.negativeOffset
        #expect(error == .negativeOffset)
    }

    @Test("Error.notSeekable exists")
    func errorNotSeekableExists() {
        let error = Kernel.Seek.Error.notSeekable
        #expect(error == .notSeekable)
    }
}

#endif
