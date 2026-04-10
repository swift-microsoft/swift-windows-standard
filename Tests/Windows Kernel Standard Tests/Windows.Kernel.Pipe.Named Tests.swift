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
import Kernel_Error_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Kernel_Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

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
    @Test("Pipe.Named namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Pipe.Named.self
    }

    @Test("Pipe.Named.OpenMode type exists")
    func openModeTypeExists() {
        _ = Windows.Kernel.Pipe.Named.OpenMode.self
    }

    @Test("Pipe.Named.PipeMode type exists")
    func pipeModeTypeExists() {
        _ = Windows.Kernel.Pipe.Named.PipeMode.self
    }
}

// MARK: - OpenMode Tests

extension Windows.Kernel.Pipe.Named.Test.Unit {
    @Test("OpenMode.accessDuplex exists")
    func openModeAccessDuplexExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessDuplex
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_DUPLEX))
    }

    @Test("OpenMode.accessInbound exists")
    func openModeAccessInboundExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessInbound
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_INBOUND))
    }

    @Test("OpenMode.accessOutbound exists")
    func openModeAccessOutboundExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.accessOutbound
        #expect(mode.rawValue == DWORD(PIPE_ACCESS_OUTBOUND))
    }

    @Test("OpenMode.overlapped exists")
    func openModeOverlappedExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.overlapped
        #expect(mode.rawValue == DWORD(FILE_FLAG_OVERLAPPED))
    }

    @Test("OpenMode.writeThrough exists")
    func openModeWriteThroughExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.writeThrough
        #expect(mode.rawValue == DWORD(FILE_FLAG_WRITE_THROUGH))
    }

    @Test("OpenMode.firstPipeInstance exists")
    func openModeFirstPipeInstanceExists() {
        let mode = Windows.Kernel.Pipe.Named.OpenMode.firstPipeInstance
        #expect(mode.rawValue == DWORD(FILE_FLAG_FIRST_PIPE_INSTANCE))
    }
}

// MARK: - PipeMode Tests

extension Windows.Kernel.Pipe.Named.Test.Unit {
    @Test("PipeMode.typeByte exists")
    func pipeModeTypeByteExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.typeByte
        #expect(mode.rawValue == DWORD(PIPE_TYPE_BYTE))
    }

    @Test("PipeMode.typeMessage exists")
    func pipeModeTypeMessageExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.typeMessage
        #expect(mode.rawValue == DWORD(PIPE_TYPE_MESSAGE))
    }

    @Test("PipeMode.readModeByte exists")
    func pipeModeReadModeByteExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.readModeByte
        #expect(mode.rawValue == DWORD(PIPE_READMODE_BYTE))
    }

    @Test("PipeMode.readModeMessage exists")
    func pipeModeReadModeMessageExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.readModeMessage
        #expect(mode.rawValue == DWORD(PIPE_READMODE_MESSAGE))
    }

    @Test("PipeMode.wait exists")
    func pipeModeWaitExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.wait
        #expect(mode.rawValue == DWORD(PIPE_WAIT))
    }

    @Test("PipeMode.noWait exists")
    func pipeModeNoWaitExists() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.noWait
        #expect(mode.rawValue == DWORD(PIPE_NOWAIT))
    }

    @Test("PipeMode.defaultByte is combination")
    func pipeModeDefaultByteIsCombination() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.defaultByte
        #expect(mode.contains(.typeByte))
        #expect(mode.contains(.readModeByte))
        #expect(mode.contains(.wait))
    }

    @Test("PipeMode.defaultMessage is combination")
    func pipeModeDefaultMessageIsCombination() {
        let mode = Windows.Kernel.Pipe.Named.PipeMode.defaultMessage
        #expect(mode.contains(.typeMessage))
        #expect(mode.contains(.readModeMessage))
        #expect(mode.contains(.wait))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Pipe.Named.Test.EdgeCase {
    @Test("OpenMode can be combined")
    func openModeCombination() {
        var mode = Windows.Kernel.Pipe.Named.OpenMode.accessDuplex
        mode.insert(.overlapped)
        #expect(mode.contains(.accessDuplex))
        #expect(mode.contains(.overlapped))
    }

    @Test("PipeMode can be combined")
    func pipeModeCombination() {
        var mode = Windows.Kernel.Pipe.Named.PipeMode.typeByte
        mode.insert(.wait)
        #expect(mode.contains(.typeByte))
        #expect(mode.contains(.wait))
    }
}

#endif
