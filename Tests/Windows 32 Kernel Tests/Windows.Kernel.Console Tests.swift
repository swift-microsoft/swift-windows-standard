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

    extension Windows.`32`.Kernel.Console {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Namespace Tests

    extension Windows.`32`.Kernel.Console.Test.Unit {
        @Test
        func `Console namespace exists`() {
            _ = Windows.`32`.Kernel.Console.self
        }

        @Test
        func `Console.InputMode type exists`() {
            _ = Windows.`32`.Kernel.Console.InputMode.self
        }

        @Test
        func `Console.OutputMode type exists`() {
            _ = Windows.`32`.Kernel.Console.OutputMode.self
        }

        @Test
        func `Console.ScreenBufferInfo type exists`() {
            _ = Windows.`32`.Kernel.Console.ScreenBufferInfo.self
        }
    }

    // MARK: - Standard Handle Tests

    extension Windows.`32`.Kernel.Console.Test.Unit {
        @Test
        func `standardInput returns handle`() {
            // May be nil if not running in console
            _ = Windows.`32`.Kernel.Console.standardInput()
        }

        @Test
        func `standardOutput returns handle`() {
            _ = Windows.`32`.Kernel.Console.standardOutput()
        }

        @Test
        func `standardError returns handle`() {
            _ = Windows.`32`.Kernel.Console.standardError()
        }
    }

    // MARK: - Input Mode Tests

    extension Windows.`32`.Kernel.Console.Test.Unit {
        @Test
        func `InputMode.enableLineInput exists`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.enableLineInput
            #expect(mode.rawValue == DWORD(ENABLE_LINE_INPUT))
        }

        @Test
        func `InputMode.enableEchoInput exists`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.enableEchoInput
            #expect(mode.rawValue == DWORD(ENABLE_ECHO_INPUT))
        }

        @Test
        func `InputMode.enableProcessedInput exists`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.enableProcessedInput
            #expect(mode.rawValue == DWORD(ENABLE_PROCESSED_INPUT))
        }

        @Test
        func `InputMode.enableVirtualTerminalInput exists`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.enableVirtualTerminalInput
            #expect(mode.rawValue == DWORD(ENABLE_VIRTUAL_TERMINAL_INPUT))
        }

        @Test
        func `InputMode.default is combination`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.default
            #expect(mode.contains(.enableLineInput))
            #expect(mode.contains(.enableEchoInput))
            #expect(mode.contains(.enableProcessedInput))
        }

        @Test
        func `InputMode.raw is empty`() {
            let mode = Windows.`32`.Kernel.Console.InputMode.raw
            #expect(mode.rawValue == 0)
        }
    }

    // MARK: - Output Mode Tests

    extension Windows.`32`.Kernel.Console.Test.Unit {
        @Test
        func `OutputMode.enableProcessedOutput exists`() {
            let mode = Windows.`32`.Kernel.Console.OutputMode.enableProcessedOutput
            #expect(mode.rawValue == DWORD(ENABLE_PROCESSED_OUTPUT))
        }

        @Test
        func `OutputMode.enableWrapAtEolOutput exists`() {
            let mode = Windows.`32`.Kernel.Console.OutputMode.enableWrapAtEolOutput
            #expect(mode.rawValue == DWORD(ENABLE_WRAP_AT_EOL_OUTPUT))
        }

        @Test
        func `OutputMode.enableVirtualTerminalProcessing exists`() {
            let mode = Windows.`32`.Kernel.Console.OutputMode.enableVirtualTerminalProcessing
            #expect(mode.rawValue == DWORD(ENABLE_VIRTUAL_TERMINAL_PROCESSING))
        }

        @Test
        func `OutputMode.default is combination`() {
            let mode = Windows.`32`.Kernel.Console.OutputMode.default
            #expect(mode.contains(.enableProcessedOutput))
            #expect(mode.contains(.enableWrapAtEolOutput))
        }

        @Test
        func `OutputMode.ansi includes VT processing`() {
            let mode = Windows.`32`.Kernel.Console.OutputMode.ansi
            #expect(mode.contains(.enableVirtualTerminalProcessing))
        }
    }

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.Console.Test.EdgeCase {
        @Test
        func `InputMode can be combined`() {
            var mode = Windows.`32`.Kernel.Console.InputMode.enableLineInput
            mode.insert(.enableEchoInput)
            #expect(mode.contains(.enableLineInput))
            #expect(mode.contains(.enableEchoInput))
        }

        @Test
        func `OutputMode can be combined`() {
            var mode = Windows.`32`.Kernel.Console.OutputMode.enableProcessedOutput
            mode.insert(.enableVirtualTerminalProcessing)
            #expect(mode.contains(.enableProcessedOutput))
            #expect(mode.contains(.enableVirtualTerminalProcessing))
        }

        @Test
        func `isConsole returns bool for invalid handle`() {
            let result = Windows.`32`.Kernel.Console.isConsole(INVALID_HANDLE_VALUE)
            #expect(!result)
        }
    }

#endif
