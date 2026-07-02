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

@testable import Windows_32_Loader
import Loader_Primitives

extension Windows.Loader {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `Loader namespace exists`() {
        _ = Windows.Loader.self
    }

    @Test
    func `Loader.Library namespace exists`() {
        _ = Windows.Loader.Library.self
    }

    @Test
    func `Loader.Symbol namespace exists`() {
        _ = Windows.Loader.Symbol.self
    }
}

// MARK: - Library Loading Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `open kernel32.dll succeeds`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        try Windows.Loader.Library.close(handle)
    }

    @Test
    func `open user32.dll succeeds`() throws {
        let handle = try Windows.Loader.Library.open(path: "user32.dll")
        try Windows.Loader.Library.close(handle)
    }

    @Test
    func `open nonexistent library fails`() {
        // do/catch, not #expect(throws:): swift-testing's throws-matcher
        // crashes the process on Windows when the thrown Loader.Error
        // (Ownership.Shared<String> payload) passes through it — probe runs
        // 28561512482/28561881582 isolate the crash to the #expect wrapper
        // while the identical do/catch path passes.
        do {
            _ = try Windows.Loader.Library.open(path: "nonexistent_library_12345.dll")
            Issue.record("Expected Loader.Error")
        } catch is Loader.Error {
            // Expected
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test
    func `getHandle for kernel32 succeeds`() throws {
        // kernel32 is always loaded
        let handle = Windows.Loader.Library.getHandle(moduleName: "kernel32.dll")
        #expect(handle != nil)
    }

    @Test
    func `getHandle for main executable succeeds`() {
        let handle = Windows.Loader.Library.getHandle(moduleName: nil)
        #expect(handle != nil)
    }

    @Test
    func `getHandle for nonexistent module returns nil`() {
        let handle = Windows.Loader.Library.getHandle(moduleName: "nonexistent_module_12345.dll")
        #expect(handle == nil)
    }

    @Test
    func `open and close multiple times`() throws {
        for _ in 0..<10 {
            let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
            try Windows.Loader.Library.close(handle)
        }
    }
}

// MARK: - Symbol Lookup Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `lookup GetLastError in kernel32 succeeds`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))
        #expect(symbol != nil)
    }

    @Test
    func `lookup GetCurrentProcessId in kernel32 succeeds`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol = try Windows.Loader.Symbol.lookup(name: "GetCurrentProcessId", in: .handle(handle))
        #expect(symbol != nil)
    }

    @Test
    func `lookup nonexistent symbol fails`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        do {
            _ = try Windows.Loader.Symbol.lookup(name: "NonexistentFunction12345", in: .handle(handle))
            Issue.record("Expected Loader.Error")
        } catch is Loader.Error {
            // Expected (do/catch: see `open nonexistent library fails`)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test
    func `lookup with default scope`() throws {
        // This may or may not succeed depending on what's in the main exe
        // Just test that it doesn't crash
        do {
            _ = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .default)
        } catch {
            // Expected if not found in main executable
        }
    }

    @Test
    func `lookup with next scope throws on Windows`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        do {
            _ = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .next)
            Issue.record("Expected Loader.Error")
        } catch is Loader.Error {
            // Expected (do/catch: see `open nonexistent library fails`)
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}

// MARK: - Loading Flags Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `Flags.dontResolveDllReferences exists`() {
        let flags = Windows.Loader.Library.Flags.dontResolveDllReferences
        #expect(flags.rawValue == DWORD(DONT_RESOLVE_DLL_REFERENCES))
    }

    @Test
    func `Flags.loadLibraryAsDatafile exists`() {
        let flags = Windows.Loader.Library.Flags.loadLibraryAsDatafile
        #expect(flags.rawValue == DWORD(LOAD_LIBRARY_AS_DATAFILE))
    }

    @Test
    func `Flags.loadWithAlteredSearchPath exists`() {
        let flags = Windows.Loader.Library.Flags.loadWithAlteredSearchPath
        #expect(flags.rawValue == DWORD(LOAD_WITH_ALTERED_SEARCH_PATH))
    }
}

// MARK: - Handle Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `Handle is Equatable`() throws {
        let handle1 = try Windows.Loader.Library.open(path: "kernel32.dll")
        let handle2 = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer {
            try? Windows.Loader.Library.close(handle1)
            try? Windows.Loader.Library.close(handle2)
        }

        // Both should be equal since kernel32 is already loaded
        #expect(handle1 == handle2)
    }

    @Test
    func `Handle rawValue is accessible`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        #expect(handle.rawValue != nil)
    }
}

// MARK: - Error Code Tests

extension Windows.Loader.Test.Unit {
    @Test
    func `ErrorCode.moduleNotFound exists`() {
        let code = Windows.Loader.ErrorCode.moduleNotFound
        #expect(code == DWORD(ERROR_MOD_NOT_FOUND))
    }

    @Test
    func `ErrorCode.procNotFound exists`() {
        let code = Windows.Loader.ErrorCode.procNotFound
        #expect(code == DWORD(ERROR_PROC_NOT_FOUND))
    }

    @Test
    func `ErrorCode.badExeFormat exists`() {
        let code = Windows.Loader.ErrorCode.badExeFormat
        #expect(code == DWORD(ERROR_BAD_EXE_FORMAT))
    }

    @Test
    func `ErrorCode.accessDenied exists`() {
        let code = Windows.Loader.ErrorCode.accessDenied
        #expect(code == DWORD(ERROR_ACCESS_DENIED))
    }

    @Test
    func `ErrorCode.fileNotFound exists`() {
        let code = Windows.Loader.ErrorCode.fileNotFound
        #expect(code == DWORD(ERROR_FILE_NOT_FOUND))
    }
}

// MARK: - Edge Cases

extension Windows.Loader.Test.EdgeCase {
    @Test
    func `open same library multiple times returns same handle`() throws {
        let handle1 = try Windows.Loader.Library.open(path: "kernel32.dll")
        let handle2 = try Windows.Loader.Library.open(path: "kernel32.dll")

        // Windows uses reference counting, same HMODULE returned
        #expect(handle1 == handle2)

        // Need to close both
        try Windows.Loader.Library.close(handle1)
        try Windows.Loader.Library.close(handle2)
    }

    @Test
    func `lookup same symbol multiple times`() throws {
        let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
        defer { try? Windows.Loader.Library.close(handle) }

        let symbol1 = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))
        let symbol2 = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .handle(handle))

        #expect(symbol1 == symbol2)
    }
}


#endif
