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
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Error_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import System_Primitives

extension Windows.Kernel.Process {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test
    func `Process namespace exists`() {
        _ = Windows.Kernel.Process.self
    }

    @Test
    func `Process.Error type exists`() {
        _ = Windows.Kernel.Process.Error.self
    }

    @Test
    func `Process.Info type exists`() {
        _ = Windows.Kernel.Process.Info.self
    }
}

// MARK: - Current Process Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test
    func `getCurrentId returns non-zero`() {
        let pid = Windows.Kernel.Process.getCurrentId()
        #expect(pid > 0)
    }

    @Test
    func `getCurrentId matches GetCurrentProcessId`() {
        let pid = Windows.Kernel.Process.getCurrentId()
        let win32Pid = GetCurrentProcessId()
        #expect(pid == win32Pid)
    }

    @Test
    func `getCurrentHandle returns non-nil`() {
        let handle = Windows.Kernel.Process.getCurrentHandle()
        #expect(handle != nil)
    }
}

// MARK: - Error Tests

extension Windows.Kernel.Process.Test.Unit {
    @Test
    func `Error.create exists`() {
        let error = Windows.Kernel.Process.Error.create(.win32(0))
        if case .create = error {
            // Expected
        } else {
            Issue.record("Expected .create, got \(error)")
        }
    }

    @Test
    func `Error.wait exists`() {
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
    @Test
    func `getCurrentId is consistent`() {
        let pid1 = Windows.Kernel.Process.getCurrentId()
        let pid2 = Windows.Kernel.Process.getCurrentId()
        #expect(pid1 == pid2)
    }

    @Test
    func `Info has expected properties`() {
        // Type check only
        _ = \Windows.Kernel.Process.Info.processHandle
        _ = \Windows.Kernel.Process.Info.threadHandle
        _ = \Windows.Kernel.Process.Info.processId
        _ = \Windows.Kernel.Process.Info.threadId
    }
}

#endif
