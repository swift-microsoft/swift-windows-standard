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
import Error_Primitives
import Path_Primitives

extension Windows.Kernel.File.Open {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test
    func `File.Open namespace exists`() {
        _ = Windows.Kernel.File.Open.self
    }

    @Test
    func `File.Open.Mode type exists`() {
        _ = Kernel.File.Open.Mode.self
    }

    @Test
    func `File.Open.Options type exists`() {
        _ = Kernel.File.Open.Options.self
    }

    @Test
    func `File.Open.Error type exists`() {
        _ = Kernel.File.Open.Error.self
    }
}

// MARK: - Mode Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test
    func `Mode.read exists`() {
        let mode = Kernel.File.Open.Mode.read
        #expect(mode.contains(.read))
        #expect(!mode.contains(.write))
    }

    @Test
    func `Mode.write exists`() {
        let mode = Kernel.File.Open.Mode.write
        #expect(mode.contains(.write))
        #expect(!mode.contains(.read))
    }

    @Test
    func `Mode.readWrite exists`() {
        let mode = Kernel.File.Open.Mode.readWrite
        #expect(mode.contains(.read))
        #expect(mode.contains(.write))
    }
}

// MARK: - Options Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test
    func `Options.create exists`() {
        let options = Kernel.File.Open.Options.create
        #expect(options.contains(.create))
    }

    @Test
    func `Options.truncate exists`() {
        let options = Kernel.File.Open.Options.truncate
        #expect(options.contains(.truncate))
    }

    @Test
    func `Options.exclusive exists`() {
        let options = Kernel.File.Open.Options.exclusive
        #expect(options.contains(.exclusive))
    }

    @Test
    func `Options.direct exists`() {
        let options = Kernel.File.Open.Options.direct
        #expect(options.contains(.direct))
    }

    @Test
    func `Options.noFollow exists`() {
        let options = Kernel.File.Open.Options.noFollow
        #expect(options.contains(.noFollow))
    }

    @Test
    func `Options.overlapped exists (Windows-specific)`() {
        let options = Kernel.File.Open.Options.overlapped
        #expect(options.contains(.overlapped))
    }

    @Test
    func `Options.backupSemantics exists (Windows-specific)`() {
        let options = Kernel.File.Open.Options.backupSemantics
        #expect(options.contains(.backupSemantics))
    }

    @Test
    func `Options.deleteOnClose exists (Windows-specific)`() {
        let options = Kernel.File.Open.Options.deleteOnClose
        #expect(options.contains(.deleteOnClose))
    }
}

// MARK: - Windows Conversion Tests

extension Windows.Kernel.File.Open.Test.Unit {
    @Test
    func `Mode.read converts to GENERIC_READ`() {
        let mode = Kernel.File.Open.Mode.read
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_READ) != 0)
        #expect(access & DWORD(GENERIC_WRITE) == 0)
    }

    @Test
    func `Mode.write converts to GENERIC_WRITE`() {
        let mode = Kernel.File.Open.Mode.write
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_WRITE) != 0)
        #expect(access & DWORD(GENERIC_READ) == 0)
    }

    @Test
    func `Mode.readWrite converts to both`() {
        let mode = Kernel.File.Open.Mode.readWrite
        let access = mode.windowsDesiredAccess
        #expect(access & DWORD(GENERIC_READ) != 0)
        #expect(access & DWORD(GENERIC_WRITE) != 0)
    }

    @Test
    func `Options.create + exclusive converts to CREATE_NEW`() {
        let options: Kernel.File.Open.Options = [.create, .exclusive]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(CREATE_NEW))
    }

    @Test
    func `Options.create + truncate converts to CREATE_ALWAYS`() {
        let options: Kernel.File.Open.Options = [.create, .truncate]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(CREATE_ALWAYS))
    }

    @Test
    func `Options.create alone converts to OPEN_ALWAYS`() {
        let options: Kernel.File.Open.Options = [.create]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(OPEN_ALWAYS))
    }

    @Test
    func `Options.truncate alone converts to TRUNCATE_EXISTING`() {
        let options: Kernel.File.Open.Options = [.truncate]
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(TRUNCATE_EXISTING))
    }

    @Test
    func `Empty options converts to OPEN_EXISTING`() {
        let options: Kernel.File.Open.Options = []
        let disposition = options.windowsCreationDisposition
        #expect(disposition == DWORD(OPEN_EXISTING))
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.File.Open.Test.EdgeCase {
    @Test
    func `Mode can be combined`() {
        var mode = Kernel.File.Open.Mode.read
        mode.insert(.write)
        #expect(mode.contains(.read))
        #expect(mode.contains(.write))
    }

    @Test
    func `Options can be combined`() {
        var options: Kernel.File.Open.Options = [.create]
        options.insert(.truncate)
        options.insert(.overlapped)
        #expect(options.contains(.create))
        #expect(options.contains(.truncate))
        #expect(options.contains(.overlapped))
    }
}

#endif
