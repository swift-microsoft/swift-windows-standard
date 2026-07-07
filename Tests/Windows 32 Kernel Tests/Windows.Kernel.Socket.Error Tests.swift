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

    @testable import Windows_32_Kernel
    import Error_Primitives

    extension Windows.`32`.Kernel.Socket.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
        }
    }

    // MARK: - Case Existence Tests

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `Error type exists`() {
            let _: Windows.`32`.Kernel.Socket.Error.Type = Windows.`32`.Kernel.Socket.Error.self
        }

        @Test
        func `platform case exists`() {
            let platformError = Error_Primitives.Error(code: .win32(999))
            let error = Windows.`32`.Kernel.Socket.Error.platform(platformError)
            if case .platform(let e) = error {
                #expect(e == platformError)
            } else {
                Issue.record("Expected .platform case")
            }
        }
    }

    // MARK: - Conformance Tests

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `Error conforms to Swift.Error`() {
            let error: any Swift.Error = Windows.`32`.Kernel.Socket.Error.platform(
                Error_Primitives.Error(code: .win32(1))
            )
            #expect(error is Windows.`32`.Kernel.Socket.Error)
        }

        @Test
        func `Error is Sendable`() {
            let value: any Sendable = Windows.`32`.Kernel.Socket.Error.platform(
                Error_Primitives.Error(code: .win32(1))
            )
            #expect(value is Windows.`32`.Kernel.Socket.Error)
        }

        @Test
        func `Error is Equatable`() {
            let a = Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .win32(1)))
            let b = Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .win32(1)))
            let c = Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .win32(2)))
            #expect(a == b)
            #expect(a != c)
        }
    }

    // MARK: - Description Tests

    extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
        @Test
        func `platform error description is non-empty`() {
            let error = Windows.`32`.Kernel.Socket.Error.platform(
                Error_Primitives.Error(code: .win32(42))
            )
            #expect(!error.description.isEmpty)
        }
    }

    // MARK: - Edge Cases

    extension Windows.`32`.Kernel.Socket.Error.Test.EdgeCase {
        @Test
        func `Same code platform errors are equal`() {
            let code = Error_Primitives.Error.Code.win32(42)
            #expect(
                Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: code))
                    == Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: code))
            )
        }

        @Test
        func `Different code platform errors are not equal`() {
            #expect(
                Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .win32(1)))
                    != Windows.`32`.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .win32(2)))
            )
        }
    }

#endif
