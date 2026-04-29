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
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

extension Windows.Kernel.System {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.System.Test.Unit {
    @Test
    func `System namespace exists`() {
        _ = Windows.Kernel.System.self
    }
}

// MARK: - Path Max Tests

extension Windows.Kernel.System.Test.Unit {
    @Test
    func `pathMax returns MAX_PATH`() {
        let pathMax = Windows.Kernel.System.pathMax
        #expect(pathMax.rawValue == 260)  // MAX_PATH
    }
}

// MARK: - Page Size Tests

extension Windows.Kernel.System.Test.Unit {
    @Test
    func `pageSize returns positive value`() {
        let pageSize = Windows.Kernel.System.pageSize
        #expect(pageSize.rawValue > 0)
    }

    @Test
    func `pageSize is typically 4096`() {
        let pageSize = Windows.Kernel.System.pageSize
        // Common values are 4096 or higher
        #expect(pageSize.rawValue >= 4096)
        #expect(pageSize.rawValue <= 65536)
    }

    @Test
    func `pageSize is power of 2`() {
        let pageSize = Windows.Kernel.System.pageSize
        let value = pageSize.rawValue
        #expect(value > 0 && (value & (value - 1)) == 0)
    }
}

// MARK: - Processor Count Tests

extension Windows.Kernel.System.Test.Unit {
    @Test
    func `processorCount returns positive value`() {
        let count = Windows.Kernel.System.processorCount
        #expect(count.rawValue > 0)
    }

    @Test
    func `processorCount is reasonable`() {
        let count = Windows.Kernel.System.processorCount
        // Modern systems have at least 1, rarely more than 256
        #expect(count.rawValue >= 1)
        #expect(count.rawValue <= 1024)
    }

    @Test
    func `processorCount matches GetSystemInfo`() {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)

        let count = Windows.Kernel.System.processorCount
        #expect(count.rawValue == Int(sysInfo.dwNumberOfProcessors))
    }
}

// MARK: - Sleep Tests

extension Windows.Kernel.System.Test.Unit {
    @Test
    func `sleep completes`() {
        let start = GetTickCount64()
        Windows.Kernel.System.sleep(.milliseconds(10))
        let elapsed = GetTickCount64() - start
        // Should have slept at least ~9ms (allowing for timing)
        #expect(elapsed >= 9)
    }

    @Test
    func `sleep zero completes immediately`() {
        let start = GetTickCount64()
        Windows.Kernel.System.sleep(.zero)
        let elapsed = GetTickCount64() - start
        // Should complete quickly (< 100ms)
        #expect(elapsed < 100)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.System.Test.EdgeCase {
    @Test
    func `pageSize is consistent`() {
        let size1 = Windows.Kernel.System.pageSize
        let size2 = Windows.Kernel.System.pageSize
        #expect(size1.rawValue == size2.rawValue)
    }

    @Test
    func `processorCount is consistent`() {
        let count1 = Windows.Kernel.System.processorCount
        let count2 = Windows.Kernel.System.processorCount
        #expect(count1.rawValue == count2.rawValue)
    }
}

#endif
