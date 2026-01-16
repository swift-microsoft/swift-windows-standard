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
import Testing_Extras

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Error {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Error.Test.Unit {
    @Test("Kernel.Error namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Error.self
    }

    @Test("Kernel.Error.Code type exists")
    func codeTypeExists() {
        _ = Kernel.Error.Code.self
    }
}

// MARK: - Capture Tests

extension Windows.Kernel.Error.Test.Unit {
    @Test("captureLastError returns Code")
    func captureLastErrorReturnsCode() {
        // Set a known error
        SetLastError(DWORD(ERROR_FILE_NOT_FOUND))

        let code = Windows.Kernel.Error.captureLastError()
        #expect(code.win32 == Windows.Kernel.Error.Code.File.notFound)
    }

    @Test("captureLastError with no error returns success")
    func captureLastErrorNoErrorReturnsSuccess() {
        SetLastError(0)  // ERROR_SUCCESS

        let code = Windows.Kernel.Error.captureLastError()
        #expect(code.win32 == 0)
    }
}

// MARK: - Error Code Constants Tests

extension Windows.Kernel.Error.Test.Unit {
    @Test("Code.File.notFound exists")
    func codeFileNotFoundExists() {
        let code = Windows.Kernel.Error.Code.File.notFound
        #expect(code == DWORD(ERROR_FILE_NOT_FOUND))
    }

    @Test("Code.File.pathNotFound exists")
    func codePathNotFoundExists() {
        let code = Windows.Kernel.Error.Code.File.pathNotFound
        #expect(code == DWORD(ERROR_PATH_NOT_FOUND))
    }

    @Test("Code.Access.denied exists")
    func codeAccessDeniedExists() {
        let code = Windows.Kernel.Error.Code.Access.denied
        #expect(code == DWORD(ERROR_ACCESS_DENIED))
    }

    @Test("Code.Handle.invalid exists")
    func codeHandleInvalidExists() {
        let code = Windows.Kernel.Error.Code.Handle.invalid
        #expect(code == DWORD(ERROR_INVALID_HANDLE))
    }
}

// MARK: - Error Code Conversion Tests

extension Windows.Kernel.Error.Test.Unit {
    @Test("Code.win32 creates correct code")
    func codeWin32CreatesCorrectCode() {
        let code = Kernel.Error.Code.win32(DWORD(ERROR_FILE_NOT_FOUND))
        #expect(code.win32 == DWORD(ERROR_FILE_NOT_FOUND))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Error.Test.EdgeCase {
    @Test("captureLastError is non-destructive")
    func captureLastErrorNonDestructive() {
        SetLastError(DWORD(ERROR_ACCESS_DENIED))

        let code1 = Windows.Kernel.Error.captureLastError()
        let code2 = GetLastError()

        // GetLastError should still return the same value
        // (captureLastError doesn't reset it)
        #expect(code1.win32 == code2)
    }
}

#endif
