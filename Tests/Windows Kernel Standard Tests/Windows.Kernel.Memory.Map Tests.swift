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
import Kernel_File_Primitives
import Memory_Primitives

extension Memory.Map {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Memory.Map.Test.Unit {
    @Test
    func `Memory.Map namespace exists`() {
        _ = Memory.Map.self
    }

    @Test
    func `Memory.Map.Protection type exists`() {
        _ = Memory.Map.Protection.self
    }

    @Test
    func `Memory.Map.Flags type exists`() {
        _ = Memory.Map.Flags.self
    }
}

// MARK: - Protection Tests

extension Memory.Map.Test.Unit {
    @Test
    func `Protection.read exists`() {
        let prot = Memory.Map.Protection.read
        #expect(prot.contains(.read))
    }

    @Test
    func `Protection.write exists`() {
        let prot = Memory.Map.Protection.write
        #expect(prot.contains(.write))
    }

    @Test
    func `Protection.execute exists`() {
        let prot = Memory.Map.Protection.execute
        #expect(prot.contains(.execute))
    }

    @Test
    func `Protection.readWrite exists`() {
        let prot = Memory.Map.Protection.readWrite
        #expect(prot.contains(.read))
        #expect(prot.contains(.write))
    }

    @Test
    func `Protection.readExecute exists`() {
        let prot = Memory.Map.Protection.readExecute
        #expect(prot.contains(.read))
        #expect(prot.contains(.execute))
    }
}

// MARK: - Windows Protection Conversion Tests

extension Memory.Map.Test.Unit {
    @Test
    func `Protection.read converts to PAGE_READONLY`() {
        let prot = Memory.Map.Protection.read
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_READONLY))
    }

    @Test
    func `Protection.readWrite converts to PAGE_READWRITE`() {
        let prot = Memory.Map.Protection.readWrite
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_READWRITE))
    }

    @Test
    func `Protection.execute converts to PAGE_EXECUTE`() {
        let prot = Memory.Map.Protection.execute
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_EXECUTE))
    }

    @Test
    func `Protection.readExecute converts to PAGE_EXECUTE_READ`() {
        let prot = Memory.Map.Protection.readExecute
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_EXECUTE_READ))
    }

    @Test
    func `Empty protection converts to PAGE_NOACCESS`() {
        let prot: Memory.Map.Protection = []
        #expect(prot.windowsVirtualProtect == DWORD(PAGE_NOACCESS))
    }
}

// MARK: - Anonymous Mapping Tests

extension Memory.Map.Test.Unit {
    @Test
    func `mapAnonymous with zero length throws`() {
        #expect(throws: Memory.Map.Error.self) {
            _ = try Memory.Map.mapAnonymous(
                length: Kernel.File.Size(0),
                protection: .readWrite
            )
        }
    }

    @Test
    func `mapAnonymous with valid length succeeds`() throws {
        let pageSize = Memory.Allocation.systemPageSize()
        let addr = try Memory.Map.mapAnonymous(
            length: Kernel.File.Size(Int64(pageSize)),
            protection: .readWrite
        )

        // Cleanup
        try Memory.Map.unmap(
            addr: addr,
            length: Kernel.File.Size(Int64(pageSize)),
            isAnonymous: true
        )
    }
}

// MARK: - Edge Cases

extension Memory.Map.Test.EdgeCase {
    @Test
    func `Protection can be combined`() {
        var prot = Memory.Map.Protection.read
        prot.insert(.write)
        #expect(prot.contains(.read))
        #expect(prot.contains(.write))
    }

    @Test
    func `map with zero length throws .invalid(.length)`() {
        let invalid = Kernel.Descriptor.invalid

        do {
            _ = try Memory.Map.map(
                fd: invalid,
                length: Kernel.File.Size(0),
                protection: .read,
                flags: .shared
            )
            Issue.record("Expected error")
        } catch let error as Memory.Map.Error {
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
