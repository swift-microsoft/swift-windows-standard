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
    import Kernel_Descriptor_Primitives
    import Kernel_Error_Primitives
    import Kernel_IO_Primitives
    import Kernel_File_Primitives

    extension Kernel.IO.Completion.Port.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Case Existence Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test
        func `create case exists`() {
            let code = Kernel.Error.Code.win32(1)
            let error = Kernel.IO.Completion.Port.Error.create(code)
            if case .create(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .create case")
            }
        }

        @Test
        func `associate case exists`() {
            let code = Kernel.Error.Code.win32(2)
            let error = Kernel.IO.Completion.Port.Error.associate(code)
            if case .associate(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .associate case")
            }
        }

        @Test
        func `dequeue case exists`() {
            let code = Kernel.Error.Code.win32(3)
            let error = Kernel.IO.Completion.Port.Error.dequeue(code)
            if case .dequeue(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .dequeue case")
            }
        }

        @Test
        func `post case exists`() {
            let code = Kernel.Error.Code.win32(4)
            let error = Kernel.IO.Completion.Port.Error.post(code)
            if case .post(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .post case")
            }
        }

        @Test
        func `read case exists`() {
            let code = Kernel.Error.Code.win32(5)
            let error = Kernel.IO.Completion.Port.Error.read(code)
            if case .read(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .read case")
            }
        }

        @Test
        func `write case exists`() {
            let code = Kernel.Error.Code.win32(6)
            let error = Kernel.IO.Completion.Port.Error.write(code)
            if case .write(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .write case")
            }
        }

        @Test
        func `result case exists`() {
            let code = Kernel.Error.Code.win32(7)
            let error = Kernel.IO.Completion.Port.Error.result(code)
            if case .result(let c) = error {
                #expect(c == code)
            } else {
                Issue.record("Expected .result case")
            }
        }

        @Test
        func `timeout case exists`() {
            let error = Kernel.IO.Completion.Port.Error.timeout
            if case .timeout = error {
                // Expected
            } else {
                Issue.record("Expected .timeout case")
            }
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test
        func `Error conforms to Swift.Error`() {
            let error: any Swift.Error = Kernel.IO.Completion.Port.Error.timeout
            #expect(error is Kernel.IO.Completion.Port.Error)
        }

        @Test
        func `Error is Sendable`() {
            let value: any Sendable = Kernel.IO.Completion.Port.Error.timeout
            #expect(value is Kernel.IO.Completion.Port.Error)
        }

        @Test
        func `Error is Equatable`() {
            let a = Kernel.IO.Completion.Port.Error.timeout
            let b = Kernel.IO.Completion.Port.Error.timeout
            let c = Kernel.IO.Completion.Port.Error.create(.win32(1))
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Error is Hashable`() {
            var set = Set<Kernel.IO.Completion.Port.Error>()
            set.insert(.timeout)
            set.insert(.create(.win32(1)))
            set.insert(.timeout)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Description Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test
        func `create description contains CreateIoCompletionPort`() {
            let error = Kernel.IO.Completion.Port.Error.create(.win32(5))
            #expect(error.description.contains("CreateIoCompletionPort"))
        }

        @Test
        func `associate description contains associate`() {
            let error = Kernel.IO.Completion.Port.Error.associate(.win32(5))
            #expect(error.description.contains("associate"))
        }

        @Test
        func `dequeue description contains GetQueuedCompletionStatus`() {
            let error = Kernel.IO.Completion.Port.Error.dequeue(.win32(5))
            #expect(error.description.contains("GetQueuedCompletionStatus"))
        }

        @Test
        func `post description contains PostQueuedCompletionStatus`() {
            let error = Kernel.IO.Completion.Port.Error.post(.win32(5))
            #expect(error.description.contains("PostQueuedCompletionStatus"))
        }

        @Test
        func `read description contains ReadFile`() {
            let error = Kernel.IO.Completion.Port.Error.read(.win32(5))
            #expect(error.description.contains("ReadFile"))
        }

        @Test
        func `write description contains WriteFile`() {
            let error = Kernel.IO.Completion.Port.Error.write(.win32(5))
            #expect(error.description.contains("WriteFile"))
        }

        @Test
        func `result description contains GetOverlappedResult`() {
            let error = Kernel.IO.Completion.Port.Error.result(.win32(5))
            #expect(error.description.contains("GetOverlappedResult"))
        }

        @Test
        func `timeout description contains timed out`() {
            let error = Kernel.IO.Completion.Port.Error.timeout
            #expect(error.description.contains("timed out"))
        }
    }

    // MARK: - last() Helper Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test
        func `last returns UInt32`() {
            let lastError = Kernel.IO.Completion.Port.Error.last()
            #expect(lastError is UInt32)
        }
    }

    // MARK: - Code Constants Tests

    extension Kernel.IO.Completion.Port.Error.Test.Unit {
        @Test
        func `Code.IO.pending exists`() {
            let pending = Kernel.IO.Completion.Port.Error.Code.IO.pending
            #expect(pending is UInt32)
        }

        @Test
        func `Code.Operation.aborted exists`() {
            let aborted = Kernel.IO.Completion.Port.Error.Code.Operation.aborted
            #expect(aborted is UInt32)
        }

        @Test
        func `Code.Lookup.notFound exists`() {
            let notFound = Kernel.IO.Completion.Port.Error.Code.Lookup.notFound
            #expect(notFound is UInt32)
        }

        @Test
        func `Code.Wait.timeout exists`() {
            let timeout = Kernel.IO.Completion.Port.Error.Code.Wait.timeout
            #expect(timeout is UInt32)
        }

        @Test
        func `Code.Wait.infinite exists`() {
            let infinite = Kernel.IO.Completion.Port.Error.Code.Wait.infinite
            #expect(infinite is UInt32)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.IO.Completion.Port.Error.Test.EdgeCase {
        @Test
        func `All cases with same code are equal`() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IO.Completion.Port.Error.create(code) == Kernel.IO.Completion.Port.Error.create(code))
            #expect(Kernel.IO.Completion.Port.Error.read(code) == Kernel.IO.Completion.Port.Error.read(code))
        }

        @Test
        func `Different cases with same code are not equal`() {
            let code = Kernel.Error.Code.win32(42)
            #expect(Kernel.IO.Completion.Port.Error.create(code) != Kernel.IO.Completion.Port.Error.read(code))
            #expect(Kernel.IO.Completion.Port.Error.write(code) != Kernel.IO.Completion.Port.Error.result(code))
        }
    }

#endif
