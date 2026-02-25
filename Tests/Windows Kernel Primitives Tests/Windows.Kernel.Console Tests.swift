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

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.Console {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Console.Test.Unit {
    @Test("Console namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Console.self
    }

    @Test("Console.InputMode type exists")
    func inputModeTypeExists() {
        _ = Windows.Kernel.Console.InputMode.self
    }

    @Test("Console.OutputMode type exists")
    func outputModeTypeExists() {
        _ = Windows.Kernel.Console.OutputMode.self
    }

    @Test("Console.ScreenBufferInfo type exists")
    func screenBufferInfoTypeExists() {
        _ = Windows.Kernel.Console.ScreenBufferInfo.self
    }
}

// MARK: - Standard Handle Tests

extension Windows.Kernel.Console.Test.Unit {
    @Test("standardInput returns handle")
    func standardInputReturnsHandle() {
        // May be nil if not running in console
        _ = Windows.Kernel.Console.standardInput()
    }

    @Test("standardOutput returns handle")
    func standardOutputReturnsHandle() {
        _ = Windows.Kernel.Console.standardOutput()
    }

    @Test("standardError returns handle")
    func standardErrorReturnsHandle() {
        _ = Windows.Kernel.Console.standardError()
    }
}

// MARK: - Input Mode Tests

extension Windows.Kernel.Console.Test.Unit {
    @Test("InputMode.enableLineInput exists")
    func inputModeLineInputExists() {
        let mode = Windows.Kernel.Console.InputMode.enableLineInput
        #expect(mode.rawValue == DWORD(ENABLE_LINE_INPUT))
    }

    @Test("InputMode.enableEchoInput exists")
    func inputModeEchoInputExists() {
        let mode = Windows.Kernel.Console.InputMode.enableEchoInput
        #expect(mode.rawValue == DWORD(ENABLE_ECHO_INPUT))
    }

    @Test("InputMode.enableProcessedInput exists")
    func inputModeProcessedInputExists() {
        let mode = Windows.Kernel.Console.InputMode.enableProcessedInput
        #expect(mode.rawValue == DWORD(ENABLE_PROCESSED_INPUT))
    }

    @Test("InputMode.enableVirtualTerminalInput exists")
    func inputModeVirtualTerminalExists() {
        let mode = Windows.Kernel.Console.InputMode.enableVirtualTerminalInput
        #expect(mode.rawValue == DWORD(ENABLE_VIRTUAL_TERMINAL_INPUT))
    }

    @Test("InputMode.default is combination")
    func inputModeDefaultIsCombination() {
        let mode = Windows.Kernel.Console.InputMode.default
        #expect(mode.contains(.enableLineInput))
        #expect(mode.contains(.enableEchoInput))
        #expect(mode.contains(.enableProcessedInput))
    }

    @Test("InputMode.raw is empty")
    func inputModeRawIsEmpty() {
        let mode = Windows.Kernel.Console.InputMode.raw
        #expect(mode.rawValue == 0)
    }
}

// MARK: - Output Mode Tests

extension Windows.Kernel.Console.Test.Unit {
    @Test("OutputMode.enableProcessedOutput exists")
    func outputModeProcessedOutputExists() {
        let mode = Windows.Kernel.Console.OutputMode.enableProcessedOutput
        #expect(mode.rawValue == DWORD(ENABLE_PROCESSED_OUTPUT))
    }

    @Test("OutputMode.enableWrapAtEolOutput exists")
    func outputModeWrapAtEolExists() {
        let mode = Windows.Kernel.Console.OutputMode.enableWrapAtEolOutput
        #expect(mode.rawValue == DWORD(ENABLE_WRAP_AT_EOL_OUTPUT))
    }

    @Test("OutputMode.enableVirtualTerminalProcessing exists")
    func outputModeVirtualTerminalExists() {
        let mode = Windows.Kernel.Console.OutputMode.enableVirtualTerminalProcessing
        #expect(mode.rawValue == DWORD(ENABLE_VIRTUAL_TERMINAL_PROCESSING))
    }

    @Test("OutputMode.default is combination")
    func outputModeDefaultIsCombination() {
        let mode = Windows.Kernel.Console.OutputMode.default
        #expect(mode.contains(.enableProcessedOutput))
        #expect(mode.contains(.enableWrapAtEolOutput))
    }

    @Test("OutputMode.ansi includes VT processing")
    func outputModeAnsiIncludesVT() {
        let mode = Windows.Kernel.Console.OutputMode.ansi
        #expect(mode.contains(.enableVirtualTerminalProcessing))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Console.Test.EdgeCase {
    @Test("InputMode can be combined")
    func inputModeCombination() {
        var mode = Windows.Kernel.Console.InputMode.enableLineInput
        mode.insert(.enableEchoInput)
        #expect(mode.contains(.enableLineInput))
        #expect(mode.contains(.enableEchoInput))
    }

    @Test("OutputMode can be combined")
    func outputModeCombination() {
        var mode = Windows.Kernel.Console.OutputMode.enableProcessedOutput
        mode.insert(.enableVirtualTerminalProcessing)
        #expect(mode.contains(.enableProcessedOutput))
        #expect(mode.contains(.enableVirtualTerminalProcessing))
    }

    @Test("isConsole returns bool for invalid handle")
    func isConsoleInvalidHandle() {
        let result = Windows.Kernel.Console.isConsole(INVALID_HANDLE_VALUE)
        #expect(!result)
    }
}

#endif
