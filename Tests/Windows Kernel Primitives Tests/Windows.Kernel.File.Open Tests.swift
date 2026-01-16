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

extension Windows.Kernel.File.Open {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test("File.Open namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.File.Open.self
    }

    @Test("File.Open.Mode type exists")
    func modeTypeExists() {
        _ = Kernel.File.Open.Mode.self
    }

    @Test("File.Open.Options type exists")
    func optionsTypeExists() {
        _ = Kernel.File.Open.Options.self
    }

    @Test("File.Open.Error type exists")
    func errorTypeExists() {
        _ = Kernel.File.Open.Error.self
    }
}

// MARK: - Mode Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test("Mode.read exists")
    func modeReadExists() {
        let mode = Kernel.File.Open.Mode.read
        #expect(mode.contains(.read))
        #expect(!mode.contains(.write))
    }

    @Test("Mode.write exists")
    func modeWriteExists() {
        let mode = Kernel.File.Open.Mode.write
        #expect(mode.contains(.write))
        #expect(!mode.contains(.read))
    }

    @Test("Mode.readWrite exists")
    func modeReadWriteExists() {
        let mode = Kernel.File.Open.Mode.readWrite
        #expect(mode.contains(.read))
        #expect(mode.contains(.write))
    }
}

// MARK: - Options Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test("Options.create exists")
    func optionsCreateExists() {
        let options = Kernel.File.Open.Options.create
        #expect(options.contains(.create))
    }

    @Test("Options.truncate exists")
    func optionsTruncateExists() {
        let options = Kernel.File.Open.Options.truncate
        #expect(options.contains(.truncate))
    }

    @Test("Options.exclusive exists")
    func optionsExclusiveExists() {
        let options = Kernel.File.Open.Options.exclusive
        #expect(options.contains(.exclusive))
    }

    @Test("Options.direct exists")
    func optionsDirectExists() {
        let options = Kernel.File.Open.Options.direct
        #expect(options.contains(.direct))
    }

    @Test("Options.noFollow exists")
    func optionsNoFollowExists() {
        let options = Kernel.File.Open.Options.noFollow
        #expect(options.contains(.noFollow))
    }

    @Test("Options.overlapped exists (Windows-specific)")
    func optionsOverlappedExists() {
        let options = Kernel.File.Open.Options.overlapped
        #expect(options.contains(.overlapped))
    }

    @Test("Options.backupSemantics exists (Windows-specific)")
    func optionsBackupSemanticsExists() {
        let options = Kernel.File.Open.Options.backupSemantics
        #expect(options.contains(.backupSemantics))
    }

    @Test("Options.deleteOnClose exists (Windows-specific)")
    func optionsDeleteOnCloseExists() {
        let options = Kernel.File.Open.Options.deleteOnClose
        #expect(options.contains(.deleteOnClose))
    }
}

// MARK: - Windows Conversion Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test("Mode.read converts to GENERIC_READ")
    func modeReadConvertsToGenericRead() {
        let mode = Kernel.File.Open.Mode.read
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_READ) != 0)
        #expect(access & DWORD(GENERIC_WRITE) == 0)
    }

    @Test("Mode.write converts to GENERIC_WRITE")
    func modeWriteConvertsToGenericWrite() {
        let mode = Kernel.File.Open.Mode.write
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_WRITE) != 0)
        #expect(access & DWORD(GENERIC_READ) == 0)
    }

    @Test("Mode.readWrite converts to both")
    func modeReadWriteConvertsToBoth() {
        let mode = Kernel.File.Open.Mode.readWrite
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_READ) != 0)
        #expect(access & DWORD(GENERIC_WRITE) != 0)
    }

    @Test("Options.create + exclusive converts to CREATE_NEW")
    func optionsCreateExclusiveConverts() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(CREATE_NEW))
    }

    @Test("Options.create + truncate converts to CREATE_ALWAYS")
    func optionsCreateTruncateConverts() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(CREATE_ALWAYS))
    }

    @Test("Options.create alone converts to OPEN_ALWAYS")
    func optionsCreateConverts() {
        let options: Kernel.File.Open.Options = [.create]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(OPEN_ALWAYS))
    }

    @Test("Options.truncate alone converts to TRUNCATE_EXISTING")
    func optionsTruncateConverts() {
        let options: Kernel.File.Open.Options = [.truncate]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(TRUNCATE_EXISTING))
    }

    @Test("Empty options converts to OPEN_EXISTING")
    func optionsEmptyConverts() {
        let options: Kernel.File.Open.Options = []
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(OPEN_EXISTING))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.File.Open.Test.EdgeCase {
    @Test("Mode can be combined")
    func modeCombination() {
        var mode = Kernel.File.Open.Mode.read
        mode.insert(.write)
        #expect(mode.contains(.read))
        #expect(mode.contains(.write))
    }

    @Test("Options can be combined")
    func optionsCombination() {
        var options: Kernel.File.Open.Options = [.create]
        options.insert(.truncate)
        options.insert(.overlapped)
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
        #expect(options.contains(.overlapped))
    }
}

#endif
