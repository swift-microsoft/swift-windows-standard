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
import Kernel_Path_Primitives
import Kernel_IO_Primitives
import Kernel_Thread_Primitives
import Kernel_Clock_Primitives
import Kernel_Time_Primitives
import Kernel_Random_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_System_Primitives

extension Windows.Kernel.Link {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Namespace Tests

extension Windows.Kernel.Link.Test.Unit {
    @Test
    func `Link namespace exists`() {
        _ = Windows.Kernel.Link.self
    }
}

// MARK: - Error Mapping Tests

extension Windows.Kernel.Link.Test.Unit {
    @Test
    func `Error.notFound maps from FILE_NOT_FOUND`() {
        let error = Kernel.Link.Error.current(from: Error_Primitives.Error.Code.File.notFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.notFound maps from PATH_NOT_FOUND`() {
        let error = Kernel.Link.Error.current(from: Error_Primitives.Error.Code.File.pathNotFound)
        if case .notFound = error {
            // Expected
        } else {
            Issue.record("Expected .notFound, got \(error)")
        }
    }

    @Test
    func `Error.permission maps from ACCESS_DENIED`() {
        let error = Kernel.Link.Error.current(from: Error_Primitives.Error.Code.Access.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission, got \(error)")
        }
    }

    @Test
    func `Error.exists maps from FILE_EXISTS`() {
        let error = Kernel.Link.Error.current(from: Error_Primitives.Error.Code.File.exists)
        if case .exists = error {
            // Expected
        } else {
            Issue.record("Expected .exists, got \(error)")
        }
    }

    @Test
    func `Error.noSpace maps from DISK_FULL`() {
        let error = Kernel.Link.Error.current(from: Error_Primitives.Error.Code.Storage.diskFull)
        if case .noSpace = error {
            // Expected
        } else {
            Issue.record("Expected .noSpace, got \(error)")
        }
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Link.Test.EdgeCase {
    @Test
    func `link to nonexistent source throws notFound`() {
        let sourcePath = "C:\\nonexistent_source_\(GetCurrentProcessId()).tmp"
        let linkPath = "C:\\link_\(GetCurrentProcessId()).tmp"

        var source = Array(sourcePath.utf16) + [0]
        var link = Array(linkPath.utf16) + [0]

        #expect(throws: Kernel.Link.Error.self) {
            try source.withUnsafeBufferPointer { sourcePtr in
                try link.withUnsafeBufferPointer { linkPtr in
                    let wsource = UnsafeRawPointer(sourcePtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    let wlink = UnsafeRawPointer(linkPtr.baseAddress!).assumingMemoryBound(to: UInt16.self)
                    try Windows.Kernel.Link.link(source: wsource, link: wlink)
                }
            }
        }
    }
}

#endif
