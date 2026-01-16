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

extension Windows.Kernel.Process {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test("Process namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Process.self
    }

    @Test("Process.Error type exists")
    func errorTypeExists() {
        _ = Windows.Kernel.Process.Error.self
    }

    @Test("Process.Info type exists")
    func infoTypeExists() {
        _ = Windows.Kernel.Process.Info.self
    }
}

// MARK: - Current Process Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test("getCurrentId returns non-zero")
    func getCurrentIdReturnsNonZero() {
        let pid = Windows.Kernel.Process.getCurrentId()
        #expect(pid > 0)
    }

    @Test("getCurrentId matches GetCurrentProcessId")
    func getCurrentIdMatchesWin32() {
        let pid = Windows.Kernel.Process.getCurrentId()
        let win32Pid = GetCurrentProcessId()
        #expect(pid == win32Pid)
    }

    @Test("getCurrentHandle returns non-nil")
    func getCurrentHandleReturnsNonNil() {
        let handle = Windows.Kernel.Process.getCurrentHandle()
        #expect(handle != nil)
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test("Error.create exists")
    func errorCreateExists() {
        let error = Windows.Kernel.Process.Error.create(.win32(0))
        if case .create = error {
            // Expected
        } else {
            Issue.record("Expected .create, got \(error)")
        }
    }

    @Test("Error.wait exists")
    func errorWaitExists() {
        let error = Windows.Kernel.Process.Error.wait(.win32(0))
        if case .wait = error {
            // Expected
        } else {
            Issue.record("Expected .wait, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Process.Test.EdgeCase {
    @Test("getCurrentId is consistent")
    func getCurrentIdConsistent() {
        let pid1 = Windows.Kernel.Process.getCurrentId()
        let pid2 = Windows.Kernel.Process.getCurrentId()
        #expect(pid1 == pid2)
    }

    @Test("Info has expected properties")
    func infoProperties() {
        // Type check only
        _ = \Windows.Kernel.Process.Info.processHandle
        _ = \Windows.Kernel.Process.Info.threadHandle
        _ = \Windows.Kernel.Process.Info.processId
        _ = \Windows.Kernel.Process.Info.threadId
    }
}

#endif
