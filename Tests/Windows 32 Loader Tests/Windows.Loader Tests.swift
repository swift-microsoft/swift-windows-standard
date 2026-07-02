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
        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Library.open(path: "nonexistent_library_12345.dll")
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

        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Symbol.lookup(name: "NonexistentFunction12345", in: .handle(handle))
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

        #expect(throws: Loader.Error.self) {
            _ = try Windows.Loader.Symbol.lookup(name: "GetLastError", in: .next)
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


// MARK: - TEMPORARY crash probe
//
// The `open nonexistent library fails` test kills the process with no
// output (probe runs 28560007585 / 28560455342). This test replicates
// captureLastErrorMessage stepwise with flushed prints to locate the
// crashing statement. DELETE once the crash is fixed.

import String_Primitives

extension Windows.Loader.Test.Unit {
    @Test
    func `crashprobe stepwise error capture`() {
        func step(_ msg: Swift.String) {
            print(msg)
            fflush(nil)
        }
        step("s1: LoadLibraryW on nonexistent path")
        let h = "nonexistent_library_12345.dll".withCString(encodedAs: UTF16.self) { LoadLibraryW($0) }
        step("s2: handle = \(Swift.String(describing: h))")
        let code = GetLastError()
        step("s3: lastError = \(code)")

        var buffer: LPWSTR?
        let length = withUnsafeMutablePointer(to: &buffer) { slot in
            unsafe FormatMessageW(
                DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS),
                nil,
                code,
                0,
                unsafe unsafeBitCast(slot, to: LPWSTR.self),
                0,
                nil
            )
        }
        step("s4: FormatMessageW length = \(length), buffer = \(Swift.String(describing: buffer))")

        guard length > 0, let buffer else {
            step("s4a: empty message path")
            return
        }

        var count = Int(length)
        while count > 0, unsafe (buffer[count - 1] == 0x000D || buffer[count - 1] == 0x000A) {
            count -= 1
        }
        step("s5: trimmed count = \(count)")

        let view = unsafe String_Primitives.String.Borrowed(UnsafePointer(buffer), count: count)
        step("s6: Borrowed constructed")

        let message = unsafe Loader.Message(copying: view)
        step("s7: Message constructed")

        let error = Windows.Loader.Error.open(message)
        step("s8: Error constructed: \(error)")

        unsafe LocalFree(buffer)
        step("s9: LocalFree done")
    }
}

#endif
