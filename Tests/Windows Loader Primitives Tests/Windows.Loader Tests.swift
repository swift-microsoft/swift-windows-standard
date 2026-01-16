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

@testable import Windows_Loader_Primitives
import Loader_Primitives

extension Windows.Loader {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Loader.Test.Unit {
    @Test("Loader namespace exists")
    func namespaceExists() {
        _ = Windows.Loader.self
    }

    @Test("Loader.Library namespace exists")
    func libraryNamespaceExists() {
        _ = Windows.Loader.Library.self
    }

    @Test("Loader.Symbol namespace exists")
    func symbolNamespaceExists() {
        _ = Windows.Loader.Symbol.self
    }
}

// MARK: - Library Loading Tests

extension Windows.Loader.Test.Unit {
    @Test("open kernel32.dll succeeds")
    func openKernel32Succeeds() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        try Windows.Loader.Library.close(handle)
    }

    @Test("open user32.dll succeeds")
    func openUser32Succeeds() throws {
        let handle = try Windows.Loader.Library.open(path: "user32.dll")
        try Windows.Loader.Library.close(handle)
    }

    @Test("open nonexistent library fails")
    func openNonexistentFails() {
        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Library.open(path: "nonexistent_library_12345.dll")
        }
    }

    @Test("getHandle for kernel32 succeeds")
    func getHandleKernel32Succeeds() throws {
        // kernel32 is always loaded
        let handle = Windows.Loader.Library.getHandle(moduleName: "kernel32.dll")
        #expect(handle != nil)
    }

    @Test("getHandle for main executable succeeds")
    func getHandleMainExeSucceeds() {
        let handle = Windows.Loader.Library.getHandle(moduleName: nil)
        #expect(handle != nil)
    }

    @Test("getHandle for nonexistent module returns nil")
    func getHandleNonexistentReturnsNil() {
        let handle = Windows.Loader.Library.getHandle(moduleName: "nonexistent_module_12345.dll")
        #expect(handle == nil)
    }

    @Test("open and close multiple times")
    func openCloseMultipleTimes() throws {
        for _ in 0..<10 {
            let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
            try Windows.Loader.Library.close(handle)
        }
    }
}

// MARK: - Symbol Lookup Tests

extension Windows.Loader.Test.Unit {
    @Test("lookup GetLastError in kernel32 succeeds")
    func lookupGetLastErrorSucceeds() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))
        #expect(symbol != nil)
    }

    @Test("lookup GetCurrentProcessId in kernel32 succeeds")
    func lookupGetCurrentProcessIdSucceeds() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol = try Windows.Loader.Symbol.lookup(name: "GetCurrentProcessId", in: .handle(handle))
        #expect(symbol != nil)
    }

    @Test("lookup nonexistent symbol fails")
    func lookupNonexistentFails() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Symbol.lookup(name: "NonexistentFunction12345", in: .handle(handle))
        }
    }

    @Test("lookup with default scope")
    func lookupWithDefaultScope() throws {
        // This may or may not succeed depending on what's in the main exe
        // Just test that it doesn't crash
        do {
            _ = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .default)
        } catch {
            // Expected if not found in main executable
        }
    }

    @Test("lookup with next scope throws on Windows")
    func lookupWithNextScopeThrows() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .next)
        }
    }
}

// MARK: - Loading Flags Tests

extension Windows.Loader.Test.Unit {
    @Test("Flags.dontResolveDllReferences exists")
    func flagsDontResolveDllReferencesExists() {
        let flags = Windows.Loader.Library.Flags.dontResolveDllReferences
        #expect(flags.rawValue == DWORD(DONT_RESOLVE_DLL_REFERENCES))
    }

    @Test("Flags.loadLibraryAsDatafile exists")
    func flagsLoadLibraryAsDatafileExists() {
        let flags = Windows.Loader.Library.Flags.loadLibraryAsDatafile
        #expect(flags.rawValue == DWORD(LOAD_LIBRARY_AS_DATAFILE))
    }

    @Test("Flags.loadWithAlteredSearchPath exists")
    func flagsLoadWithAlteredSearchPathExists() {
        let flags = Windows.Loader.Library.Flags.loadWithAlteredSearchPath
        #expect(flags.rawValue == DWORD(LOAD_WITH_ALTERED_SEARCH_PATH))
    }
}

// MARK: - Handle Tests

extension Windows.Loader.Test.Unit {
    @Test("Handle is Equatable")
    func handleIsEquatable() throws {
        let handle1 = try Windows.Loader.Library.open(path: "kernel32.dll")
        let handle2 = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer {
            try? Windows.Loader.Library.close(handle1)
            try? Windows.Loader.Library.close(handle2)
        }

        // Both should be equal since kernel32 is already loaded
        #expect(handle1 == handle2)
    }

    @Test("Handle rawValue is accessible")
    func handleRawValueAccessible() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        #expect(handle.rawValue != nil)
    }
}

// MARK: - Error Code Tests

extension Windows.Loader.Test.Unit {
    @Test("ErrorCode.moduleNotFound exists")
    func errorCodeModuleNotFoundExists() {
        let code = Windows.Loader.ErrorCode.moduleNotFound
        #expect(code == DWORD(ERROR_MOD_NOT_FOUND))
    }

    @Test("ErrorCode.procNotFound exists")
    func errorCodeProcNotFoundExists() {
        let code = Windows.Loader.ErrorCode.procNotFound
        #expect(code == DWORD(ERROR_PROC_NOT_FOUND))
    }

    @Test("ErrorCode.badExeFormat exists")
    func errorCodeBadExeFormatExists() {
        let code = Windows.Loader.ErrorCode.badExeFormat
        #expect(code == DWORD(ERROR_BAD_EXE_FORMAT))
    }

    @Test("ErrorCode.accessDenied exists")
    func errorCodeAccessDeniedExists() {
        let code = Windows.Loader.ErrorCode.accessDenied
        #expect(code == DWORD(ERROR_ACCESS_DENIED))
    }

    @Test("ErrorCode.fileNotFound exists")
    func errorCodeFileNotFoundExists() {
        let code = Windows.Loader.ErrorCode.fileNotFound
        #expect(code == DWORD(ERROR_FILE_NOT_FOUND))
    }
}

// MARK: - Edge Cases

extension Windows.Loader.Test.EdgeCase {
    @Test("open same library multiple times returns same handle")
    func openSameLibraryMultipleTimes() throws {
        let handle1 = try Windows.Loader.Library.open(path: "kernel32.dll")
        let handle2 = try Windows.Loader.Library.open(path: "kernel32.dll")

        // Windows uses reference counting, same HMODULE returned
        #expect(handle1 == handle2)

        // Need to close both
        try Windows.Loader.Library.close(handle1)
        try Windows.Loader.Library.close(handle2)
    }

    @Test("lookup same symbol multiple times")
    func lookupSameSymbolMultipleTimes() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol1 = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))
        let symbol2 = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))

        #expect(symbol1 == symbol2)
    }
}

#endif
