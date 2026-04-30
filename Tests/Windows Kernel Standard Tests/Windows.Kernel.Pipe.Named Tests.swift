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

extension Windows.Kernel.Pipe.Named {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Pipe.Named.Test.Unit {
    @Test
    func `Pipe.Named namespace exists`() {
        _ = Windows.Kernel.Pipe.Named.self
    }

    @Test
    func `Pipe.Named.OpenMode type exists`() {
        _ = Windows.Kernel.Pipe.Named.OpenMode.self
    }

    @Test
    func `Pipe.Named.PipeMode type exists`() {
        _ = Windows.Kernel.Pipe.Named.PipeMode.self
    }
}

// MARK: - OpenMode Tests

extension Windows.Kernel.Pipe.Named.Test.Unit {
    @Test
    func `OpenMode.accessDuplex exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessDuplex
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_DUPLEX))
    }

    @Test
    func `OpenMode.accessInbound exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessInbound
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_INBOUND))
    }

    @Test
    func `OpenMode.accessOutbound exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessOutbound
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_OUTBOUND))
    }

    @Test
    func `OpenMode.overlapped exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.overlapped
        #expect(mode.rawValue == DWORD(FILE_FLAG_OVERLAPPED))
    }

    @Test
    func `OpenMode.writeThrough exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.writeThrough
        #expect(mode.rawValue == DWORD(FILE_FLAG_WRITE_THROUGH))
    }

    @Test
    func `OpenMode.firstPipeInstance exists`() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.firstPipeInstance
        #expect(mode.rawValue == DWORD(FILE_FLAG_FIRST_PIPE_INSTANCE))
    }
}

// MARK: - PipeMode Tests

extension Windows.Kernel.Pipe.Named.Test.Unit {
    @Test
    func `PipeMode.typeByte exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.typeByte
        #expect(mode.rawValue == DWORD(PIPE_TYPE_BYTE))
    }

    @Test
    func `PipeMode.typeMessage exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.typeMessage
        #expect(mode.rawValue == DWORD(PIPE_TYPE_MESSAGE))
    }

    @Test
    func `PipeMode.readModeByte exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.readModeByte
        #expect(mode.rawValue == DWORD(PIPE_READMODE_BYTE))
    }

    @Test
    func `PipeMode.readModeMessage exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.readModeMessage
        #expect(mode.rawValue == DWORD(PIPE_READMODE_MESSAGE))
    }

    @Test
    func `PipeMode.wait exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.wait
        #expect(mode.rawValue == DWORD(PIPE_WAIT))
    }

    @Test
    func `PipeMode.noWait exists`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.noWait
        #expect(mode.rawValue == DWORD(PIPE_NOWAIT))
    }

    @Test
    func `PipeMode.defaultByte is combination`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.defaultByte
        #expect(mode.contains(.typeByte))
        #expect(mode.contains(.readModeByte))
        #expect(mode.contains(.wait))
    }

    @Test
    func `PipeMode.defaultMessage is combination`() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.defaultMessage
        #expect(mode.contains(.typeMessage))
        #expect(mode.contains(.readModeMessage))
        #expect(mode.contains(.wait))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Pipe.Named.Test.EdgeCase {
    @Test
    func `OpenMode can be combined`() {
        var mode = Windows.Kernel.Pipe.Named.OpenMode.accessDuplex
        mode.insert(.overlapped)
        #expect(mode.contains(.accessDuplex))
        #expect(mode.contains(.overlapped))
    }

    @Test
    func `PipeMode can be combined`() {
        var mode = Windows.Kernel.Pipe.Named.PipeMode.typeByte
        mode.insert(.wait)
        #expect(mode.contains(.typeByte))
        #expect(mode.contains(.wait))
    }
}

#endif
