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

extension Windows.Kernel.Memory.Map {
    #TestSuites
}

// MARK: - Namespace Tests

extension Windows.Kernel.Memory.Map.Test.Unit {
    @Test("Memory.Map namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.Memory.Map.self
    }

    @Test("Memory.Map.Protection type exists")
    func protectionTypeExists() {
        _ = Kernel.Memory.Map.Protection.self
    }

    @Test("Memory.Map.Flags type exists")
    func flagsTypeExists() {
        _ = Kernel.Memory.Map.Flags.self
    }
}

// MARK: - Protection Tests

extension Windows.Kernel.Memory.Map.Test.Unit {
    @Test("Protection.read exists")
    func protectionReadExists() {
        let prot = Kernel.Memory.Map.Protection.read
        #expect(prot.contains(.read))
    }

    @Test("Protection.write exists")
    func protectionWriteExists() {
        let prot = Kernel.Memory.Map.Protection.write
        #expect(prot.contains(.write))
    }

    @Test("Protection.execute exists")
    func protectionExecuteExists() {
        let prot = Kernel.Memory.Map.Protection.execute
        #expect(prot.contains(.execute))
    }

    @Test("Protection.readWrite exists")
    func protectionReadWriteExists() {
        let prot = Kernel.Memory.Map.Protection.readWrite
        #expect(prot.contains(.read))
        #expect(prot.contains(.write))
    }

    @Test("Protection.readExecute exists")
    func protectionReadExecuteExists() {
        let prot = Kernel.Memory.Map.Protection.readExecute
        #expect(prot.contains(.read))
        #expect(prot.contains(.execute))
    }
}

// MARK: - Windows Protection Conversion Tests

extension Windows.Kernel.Memory.Map.Test.Unit {
    @Test("Protection.read converts to PAGE_READONLY")
    func protectionReadConverts() {
        let prot = Kernel.Memory.Map.Protection.read
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_READONLY))
    }

    @Test("Protection.readWrite converts to PAGE_READWRITE")
    func protectionReadWriteConverts() {
        let prot = Kernel.Memory.Map.Protection.readWrite
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_READWRITE))
    }

    @Test("Protection.execute converts to PAGE_EXECUTE")
    func protectionExecuteConverts() {
        let prot = Kernel.Memory.Map.Protection.execute
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_EXECUTE))
    }

    @Test("Protection.readExecute converts to PAGE_EXECUTE_READ")
    func protectionReadExecuteConverts() {
        let prot = Kernel.Memory.Map.Protection.readExecute
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_EXECUTE_READ))
    }

    @Test("Empty protection converts to PAGE_NOACCESS")
    func emptyProtectionConverts() {
        let prot: Kernel.Memory.Map.Protection = []
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_NOACCESS))
    }
}

// MARK: - Anonymous Mapping Tests

extension Windows.Kernel.Memory.Map.Test.Unit {
    @Test("mapAnonymous with zero length throws")
    func mapAnonymousZeroLengthThrows() {
        #expect(throws: Kernel.Memory.Map.Error.self) {
            _ = try Windows.Kernel.Memory.Map.mapAnonymous(
                length: Kernel.File.Size(0),
                protection: .readWrite
            )
        }
    }

    @Test("mapAnonymous with valid length succeeds")
    func mapAnonymousValidLengthSucceeds() throws {
        let pageSize = Windows.Kernel.Memory.Allocation.systemPageSize()
        let addr = try Windows.Kernel.Memory.Map.mapAnonymous(
            length: Kernel.File.Size(Int64(pageSize)),
            protection: .readWrite
        )

        // Cleanup
        try Windows.Kernel.Memory.Map.unmap(
            addr: addr,
            length: Kernel.File.Size(Int64(pageSize)),
            isAnonymous: true
        )
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Memory.Map.Test.EdgeCase {
    @Test("Protection can be combined")
    func protectionCombination() {
        var prot = Kernel.Memory.Map.Protection.read
        prot.insert(.write)
        #expect(prot.contains(.read))
        #expect(prot.contains(.write))
    }

    @Test("map with zero length throws .invalid(.length)")
    func mapZeroLengthThrows() {
        let invalid = Kernel.Descriptor.invalid

        do {
            _ = try Windows.Kernel.Memory.Map.map(
                fd: invalid,
                length: Kernel.File.Size(0),
                protection: .read,
                flags: .shared
            )
            Issue.record("Expected error")
        } catch let error as Kernel.Memory.Map.Error {
            if case .invalid(.length) = error {
                // Expected
            } else {
                Issue.record("Expected .invalid(.length), got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}

#endif
