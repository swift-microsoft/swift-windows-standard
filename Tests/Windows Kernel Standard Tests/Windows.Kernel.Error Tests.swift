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
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import System_Primitives

extension Error_Primitives.Error {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Error_Primitives.Error.Test.Unit {
    @Test
    func `Error_Primitives.Error namespace exists`() {
        _ = Error_Primitives.Error.self
    }

    @Test
    func `Error_Primitives.Error.Code type exists`() {
        _ = Error_Primitives.Error.Code.self
    }
}

// MARK: - Capture Tests

extension Error_Primitives.Error.Test.Unit {
    @Test
    func `captureLastError returns Code`() {
        // Set a known error
        SetLastError(DWORD(ERROR_FILE_NOT_FOUND))

        let code = Error_Primitives.Error.captureLastError()
        #expect(code.win32 == Error_Primitives.Error.Code.File.notFound)
    }

    @Test
    func `captureLastError with no error returns success`() {
        SetLastError(0)  // ERROR_SUCCESS

        let code = Error_Primitives.Error.captureLastError()
        #expect(code.win32 == 0)
    }
}

// MARK: - Error Code Constants Tests

extension Error_Primitives.Error.Test.Unit {
    @Test
    func `Code.File.notFound exists`() {
        let code = Error_Primitives.Error.Code.File.notFound
        #expect(code == DWORD(ERROR_FILE_NOT_FOUND))
    }

    @Test
    func `Code.File.pathNotFound exists`() {
        let code = Error_Primitives.Error.Code.File.pathNotFound
        #expect(code == DWORD(ERROR_PATH_NOT_FOUND))
    }

    @Test
    func `Code.Access.denied exists`() {
        let code = Error_Primitives.Error.Code.Access.denied
        #expect(code == DWORD(ERROR_ACCESS_DENIED))
    }

    @Test
    func `Code.Handle.invalid exists`() {
        let code = Error_Primitives.Error.Code.Handle.invalid
        #expect(code == DWORD(ERROR_INVALID_HANDLE))
    }
}

// MARK: - Error Code Conversion Tests

extension Error_Primitives.Error.Test.Unit {
    @Test
    func `Code.win32 creates correct code`() {
        let code = Error_Primitives.Error.Code.win32(DWORD(ERROR_FILE_NOT_FOUND))
        #expect(code.win32 == DWORD(ERROR_FILE_NOT_FOUND))
    }
}

// MARK: - Edge Cases

extension Error_Primitives.Error.Test.EdgeCase {
    @Test
    func `captureLastError is non-destructive`() {
        SetLastError(DWORD(ERROR_ACCESS_DENIED))

        let code1 = Error_Primitives.Error.captureLastError()
        let code2 = GetLastError()

        // GetLastError should still return the same value
        // (captureLastError doesn't reset it)
        #expect(code1.win32 == code2)
    }
}

#endif
