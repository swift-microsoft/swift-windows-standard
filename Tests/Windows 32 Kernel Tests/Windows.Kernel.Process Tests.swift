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
import Clock_Primitives
import Random_Primitives
import System_Primitives

extension Windows.`32`.Kernel.Process {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.`32`.Kernel.Process.Test.Unit {
    @Test
    func `Process namespace exists`() {
        _ = Windows.`32`.Kernel.Process.self
    }

    @Test
    func `Process.Error type exists`() {
        _ = Windows.`32`.Kernel.Process.Error.self
    }

    @Test
    func `Process.Info type exists`() {
        _ = Windows.`32`.Kernel.Process.Info.self
    }
}

// MARK: - Current Process Tests

extension Windows.`32`.Kernel.Process.Test.Unit {
    @Test
    func `getCurrentId returns non-zero`() {
        let pid = Windows.`32`.Kernel.Process.getCurrentId()
        #expect(pid > 0)
    }

    @Test
    func `getCurrentId matches GetCurrentProcessId`() {
        let pid = Windows.`32`.Kernel.Process.getCurrentId()
        let win32Pid = GetCurrentProcessId()
        #expect(pid == win32Pid)
    }

    @Test
    func `getCurrentHandle returns non-nil`() {
        let handle = Windows.`32`.Kernel.Process.getCurrentHandle()
        #expect(handle != nil)
    }
}

// MARK: - Error Tests

extension Windows.`32`.Kernel.Process.Test.Unit {
    @Test
    func `Error.create exists`() {
        let error = Windows.`32`.Kernel.Process.Error.create(.win32(0))
        if case .create = error {
            // Expected
        } else {
            Issue.record("Expected .create, got \(error)")
        }
    }

    @Test
    func `Error.wait exists`() {
        let error = Windows.`32`.Kernel.Process.Error.wait(.win32(0))
        if case .wait = error {
            // Expected
        } else {
            Issue.record("Expected .wait, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.Process.Test.EdgeCase {
    @Test
    func `getCurrentId is consistent`() {
        let pid1 = Windows.`32`.Kernel.Process.getCurrentId()
        let pid2 = Windows.`32`.Kernel.Process.getCurrentId()
        #expect(pid1 == pid2)
    }

    @Test
    func `Info has expected properties`() {
        // Type check only
        _ = \Windows.`32`.Kernel.Process.Info.processHandle
        _ = \Windows.`32`.Kernel.Process.Info.threadHandle
        _ = \Windows.`32`.Kernel.Process.Info.processId
        _ = \Windows.`32`.Kernel.Process.Info.threadId
    }
}

#endif
