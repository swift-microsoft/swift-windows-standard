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
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Case Existence Tests

extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
    @Test
    func `startup case exists`() {
        let code = Error_Primitives.Error.Code.win32(1)
        let error = Windows.`32`.Kernel.Socket.Error.startup(code)
        if case .startup(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .startup case")
        }
    }

    @Test
    func `create case exists`() {
        let code = Error_Primitives.Error.Code.win32(2)
        let error = Windows.`32`.Kernel.Socket.Error.create(code)
        if case .create(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .create case")
        }
    }

    @Test
    func `close case exists`() {
        let code = Error_Primitives.Error.Code.win32(3)
        let error = Windows.`32`.Kernel.Socket.Error.close(code)
        if case .close(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .close case")
        }
    }

    @Test
    func `bind case exists`() {
        let code = Error_Primitives.Error.Code.win32(4)
        let error = Windows.`32`.Kernel.Socket.Error.bind(code)
        if case .bind(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .bind case")
        }
    }

    @Test
    func `listen case exists`() {
        let code = Error_Primitives.Error.Code.win32(5)
        let error = Windows.`32`.Kernel.Socket.Error.listen(code)
        if case .listen(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .listen case")
        }
    }

    @Test
    func `accept case exists`() {
        let code = Error_Primitives.Error.Code.win32(6)
        let error = Windows.`32`.Kernel.Socket.Error.accept(code)
        if case .accept(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .accept case")
        }
    }

    @Test
    func `connect case exists`() {
        let code = Error_Primitives.Error.Code.win32(7)
        let error = Windows.`32`.Kernel.Socket.Error.connect(code)
        if case .connect(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .connect case")
        }
    }

    @Test
    func `send case exists`() {
        let code = Error_Primitives.Error.Code.win32(8)
        let error = Windows.`32`.Kernel.Socket.Error.send(code)
        if case .send(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .send case")
        }
    }

    @Test
    func `receive case exists`() {
        let code = Error_Primitives.Error.Code.win32(9)
        let error = Windows.`32`.Kernel.Socket.Error.receive(code)
        if case .receive(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .receive case")
        }
    }

    @Test
    func `shutdown case exists`() {
        let code = Error_Primitives.Error.Code.win32(10)
        let error = Windows.`32`.Kernel.Socket.Error.shutdown(code)
        if case .shutdown(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .shutdown case")
        }
    }

    @Test
    func `getOption case exists`() {
        let code = Error_Primitives.Error.Code.win32(11)
        let error = Windows.`32`.Kernel.Socket.Error.getOption(code)
        if case .getOption(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .getOption case")
        }
    }

    @Test
    func `setOption case exists`() {
        let code = Error_Primitives.Error.Code.win32(12)
        let error = Windows.`32`.Kernel.Socket.Error.setOption(code)
        if case .setOption(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .setOption case")
        }
    }
}

// MARK: - Conformance Tests

extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Windows.`32`.Kernel.Socket.Error.create(.win32(1))
        #expect(error is Windows.`32`.Kernel.Socket.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = Windows.`32`.Kernel.Socket.Error.create(.win32(1))
        #expect(value is Windows.`32`.Kernel.Socket.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Windows.`32`.Kernel.Socket.Error.create(.win32(1))
        let b = Windows.`32`.Kernel.Socket.Error.create(.win32(1))
        let c = Windows.`32`.Kernel.Socket.Error.bind(.win32(1))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
    @Test
    func `startup description contains WSAStartup`() {
        let error = Windows.`32`.Kernel.Socket.Error.startup(.win32(5))
        #expect(error.description.contains("WSAStartup"))
    }

    @Test
    func `create description contains socket`() {
        let error = Windows.`32`.Kernel.Socket.Error.create(.win32(5))
        #expect(error.description.contains("socket"))
    }

    @Test
    func `close description contains closesocket`() {
        let error = Windows.`32`.Kernel.Socket.Error.close(.win32(5))
        #expect(error.description.contains("closesocket"))
    }

    @Test
    func `bind description contains bind`() {
        let error = Windows.`32`.Kernel.Socket.Error.bind(.win32(5))
        #expect(error.description.contains("bind"))
    }

    @Test
    func `listen description contains listen`() {
        let error = Windows.`32`.Kernel.Socket.Error.listen(.win32(5))
        #expect(error.description.contains("listen"))
    }

    @Test
    func `accept description contains accept`() {
        let error = Windows.`32`.Kernel.Socket.Error.accept(.win32(5))
        #expect(error.description.contains("accept"))
    }

    @Test
    func `connect description contains connect`() {
        let error = Windows.`32`.Kernel.Socket.Error.connect(.win32(5))
        #expect(error.description.contains("connect"))
    }

    @Test
    func `send description contains send`() {
        let error = Windows.`32`.Kernel.Socket.Error.send(.win32(5))
        #expect(error.description.contains("send"))
    }

    @Test
    func `receive description contains recv`() {
        let error = Windows.`32`.Kernel.Socket.Error.receive(.win32(5))
        #expect(error.description.contains("recv"))
    }

    @Test
    func `shutdown description contains shutdown`() {
        let error = Windows.`32`.Kernel.Socket.Error.shutdown(.win32(5))
        #expect(error.description.contains("shutdown"))
    }
}

// MARK: - Error Code Constants Tests

extension Windows.`32`.Kernel.Socket.Error.Test.Unit {
    @Test
    func `Code.Connection.refused exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Connection.refused
        #expect(code == WSAECONNREFUSED)
    }

    @Test
    func `Code.Connection.reset exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Connection.reset
        #expect(code == WSAECONNRESET)
    }

    @Test
    func `Code.Connection.timedOut exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Connection.timedOut
        #expect(code == WSAETIMEDOUT)
    }

    @Test
    func `Code.Address.inUse exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Address.inUse
        #expect(code == WSAEADDRINUSE)
    }

    @Test
    func `Code.Operation.wouldBlock exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Operation.wouldBlock
        #expect(code == WSAEWOULDBLOCK)
    }

    @Test
    func `Code.State.notSocket exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.State.notSocket
        #expect(code == WSAENOTSOCK)
    }

    @Test
    func `Code.Buffer.messageTooLong exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Buffer.messageTooLong
        #expect(code == WSAEMSGSIZE)
    }

    @Test
    func `Code.Startup.notInitialized exists`() {
        let code = Windows.`32`.Kernel.Socket.Error.Code.Startup.notInitialized
        #expect(code == WSANOTINITIALISED)
    }
}

// MARK: - Edge Cases

extension Windows.`32`.Kernel.Socket.Error.Test.EdgeCase {
    @Test
    func `Same case same code are equal`() {
        let code = Error_Primitives.Error.Code.win32(42)
        #expect(Windows.`32`.Kernel.Socket.Error.create(code) == Windows.`32`.Kernel.Socket.Error.create(code))
        #expect(Windows.`32`.Kernel.Socket.Error.bind(code) == Windows.`32`.Kernel.Socket.Error.bind(code))
    }

    @Test
    func `Different cases same code are not equal`() {
        let code = Error_Primitives.Error.Code.win32(42)
        #expect(Windows.`32`.Kernel.Socket.Error.create(code) != Windows.`32`.Kernel.Socket.Error.bind(code))
        #expect(Windows.`32`.Kernel.Socket.Error.send(code) != Windows.`32`.Kernel.Socket.Error.receive(code))
    }
}

#endif
