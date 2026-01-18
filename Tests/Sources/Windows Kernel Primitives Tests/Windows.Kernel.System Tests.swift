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
import Testing

@testable import Windows_Kernel_Primitives
import Kernel_Primitives

extension Windows.Kernel.System {
    #Tests
}

// MARK: - Namespace Tests

extension Windows.Kernel.System.Test.Unit {
    @Test("System namespace exists")
    func namespaceExists() {
        _ = Windows.Kernel.System.self
    }
}

// MARK: - Path Max Tests

extension Windows.Kernel.System.Test.Unit {
    @Test("pathMax returns MAX_PATH")
    func pathMaxReturnsMaxPath() {
        let pathMax = Windows.Kernel.System.pathMax
        #expect(pathMax.rawValue == 260)  // MAX_PATH
    }
}

// MARK: - Page Size Tests

extension Windows.Kernel.System.Test.Unit {
    @Test("pageSize returns positive value")
    func pageSizeReturnsPositive() {
        let pageSize = Windows.Kernel.System.pageSize
        #expect(pageSize.rawValue > 0)
    }

    @Test("pageSize is typically 4096")
    func pageSizeTypically4096() {
        let pageSize = Windows.Kernel.System.pageSize
        // Common values are 4096 or higher
        #expect(pageSize.rawValue >= 4096)
        #expect(pageSize.rawValue <= 65536)
    }

    @Test("pageSize is power of 2")
    func pageSizeIsPowerOf2() {
        let pageSize = Windows.Kernel.System.pageSize
        let value = pageSize.rawValue
        #expect(value > 0 && (value & (value - 1)) == 0)
    }
}

// MARK: - Processor Count Tests

extension Windows.Kernel.System.Test.Unit {
    @Test("processorCount returns positive value")
    func processorCountReturnsPositive() {
        let count = Windows.Kernel.System.processorCount
        #expect(count.rawValue > 0)
    }

    @Test("processorCount is reasonable")
    func processorCountReasonable() {
        let count = Windows.Kernel.System.processorCount
        // Modern systems have at least 1, rarely more than 256
        #expect(count.rawValue >= 1)
        #expect(count.rawValue <= 1024)
    }

    @Test("processorCount matches GetSystemInfo")
    func processorCountMatchesWin32() {
        var sysInfo = SYSTEM_INFO()
        GetSystemInfo(&sysInfo)

        let count = Windows.Kernel.System.processorCount
        #expect(count.rawValue == Int(sysInfo.dwNumberOfProcessors))
    }
}

// MARK: - Sleep Tests

extension Windows.Kernel.System.Test.Unit {
    @Test("sleep nanoseconds completes")
    func sleepNanosecondsCompletes() {
        let start = GetTickCount64()
        Windows.Kernel.System.sleep(nanoseconds: 10_000_000)  // 10ms
        let elapsed = GetTickCount64() - start
        // Should have slept at least ~9ms (allowing for timing)
        #expect(elapsed >= 9)
    }

    @Test("sleep zero nanoseconds completes immediately")
    func sleepZeroNanoseconds() {
        let start = GetTickCount64()
        Windows.Kernel.System.sleep(nanoseconds: 0)
        let elapsed = GetTickCount64() - start
        // Should complete quickly (< 100ms)
        #expect(elapsed < 100)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.System.Test.EdgeCase {
    @Test("pageSize is consistent")
    func pageSizeConsistent() {
        let size1 = Windows.Kernel.System.pageSize
        let size2 = Windows.Kernel.System.pageSize
        #expect(size1.rawValue == size2.rawValue)
    }

    @Test("processorCount is consistent")
    func processorCountConsistent() {
        let count1 = Windows.Kernel.System.processorCount
        let count2 = Windows.Kernel.System.processorCount
        #expect(count1.rawValue == count2.rawValue)
    }
}

#endif
