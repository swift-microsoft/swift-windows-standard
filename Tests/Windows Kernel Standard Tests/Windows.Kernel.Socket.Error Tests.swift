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
import Kernel_Error_Primitives
import Kernel_Socket_Primitives

extension Windows.Kernel.Socket.Error {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Case Existence Tests

extension Windows.Kernel.Socket.Error.Test.Unit {
    @Test("startup case exists")
    func startupCase() {
        let code = Kernel.Error.Code.win32(1)
        let error = Windows.Kernel.Socket.Error.startup(code)
        if case .startup(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .startup case")
        }
    }

    @Test("create case exists")
    func createCase() {
        let code = Kernel.Error.Code.win32(2)
        let error = Windows.Kernel.Socket.Error.create(code)
        if case .create(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .create case")
        }
    }

    @Test("close case exists")
    func closeCase() {
        let code = Kernel.Error.Code.win32(3)
        let error = Windows.Kernel.Socket.Error.close(code)
        if case .close(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .close case")
        }
    }

    @Test("bind case exists")
    func bindCase() {
        let code = Kernel.Error.Code.win32(4)
        let error = Windows.Kernel.Socket.Error.bind(code)
        if case .bind(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .bind case")
        }
    }

    @Test("listen case exists")
    func listenCase() {
        let code = Kernel.Error.Code.win32(5)
        let error = Windows.Kernel.Socket.Error.listen(code)
        if case .listen(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .listen case")
        }
    }

    @Test("accept case exists")
    func acceptCase() {
        let code = Kernel.Error.Code.win32(6)
        let error = Windows.Kernel.Socket.Error.accept(code)
        if case .accept(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .accept case")
        }
    }

    @Test("connect case exists")
    func connectCase() {
        let code = Kernel.Error.Code.win32(7)
        let error = Windows.Kernel.Socket.Error.connect(code)
        if case .connect(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .connect case")
        }
    }

    @Test("send case exists")
    func sendCase() {
        let code = Kernel.Error.Code.win32(8)
        let error = Windows.Kernel.Socket.Error.send(code)
        if case .send(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .send case")
        }
    }

    @Test("receive case exists")
    func receiveCase() {
        let code = Kernel.Error.Code.win32(9)
        let error = Windows.Kernel.Socket.Error.receive(code)
        if case .receive(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .receive case")
        }
    }

    @Test("shutdown case exists")
    func shutdownCase() {
        let code = Kernel.Error.Code.win32(10)
        let error = Windows.Kernel.Socket.Error.shutdown(code)
        if case .shutdown(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .shutdown case")
        }
    }

    @Test("getOption case exists")
    func getOptionCase() {
        let code = Kernel.Error.Code.win32(11)
        let error = Windows.Kernel.Socket.Error.getOption(code)
        if case .getOption(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .getOption case")
        }
    }

    @Test("setOption case exists")
    func setOptionCase() {
        let code = Kernel.Error.Code.win32(12)
        let error = Windows.Kernel.Socket.Error.setOption(code)
        if case .setOption(let c) = error {
            #expect(c == code)
        } else {
            Issue.record("Expected .setOption case")
        }
    }
}

// MARK: - Conformance Tests

extension Windows.Kernel.Socket.Error.Test.Unit {
    @Test("Error conforms to Swift.Error")
    func isSwiftError() {
        let error: any Swift.Error = Windows.Kernel.Socket.Error.create(.win32(1))
        #expect(error is Windows.Kernel.Socket.Error)
    }

    @Test("Error is Sendable")
    func isSendable() {
        let value: any Sendable = Windows.Kernel.Socket.Error.create(.win32(1))
        #expect(value is Windows.Kernel.Socket.Error)
    }

    @Test("Error is Equatable")
    func isEquatable() {
        let a = Windows.Kernel.Socket.Error.create(.win32(1))
        let b = Windows.Kernel.Socket.Error.create(.win32(1))
        let c = Windows.Kernel.Socket.Error.bind(.win32(1))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Windows.Kernel.Socket.Error.Test.Unit {
    @Test("startup description contains WSAStartup")
    func startupDescription() {
        let error = Windows.Kernel.Socket.Error.startup(.win32(5))
        #expect(error.description.contains("WSAStartup"))
    }

    @Test("create description contains socket")
    func createDescription() {
        let error = Windows.Kernel.Socket.Error.create(.win32(5))
        #expect(error.description.contains("socket"))
    }

    @Test("close description contains closesocket")
    func closeDescription() {
        let error = Windows.Kernel.Socket.Error.close(.win32(5))
        #expect(error.description.contains("closesocket"))
    }

    @Test("bind description contains bind")
    func bindDescription() {
        let error = Windows.Kernel.Socket.Error.bind(.win32(5))
        #expect(error.description.contains("bind"))
    }

    @Test("listen description contains listen")
    func listenDescription() {
        let error = Windows.Kernel.Socket.Error.listen(.win32(5))
        #expect(error.description.contains("listen"))
    }

    @Test("accept description contains accept")
    func acceptDescription() {
        let error = Windows.Kernel.Socket.Error.accept(.win32(5))
        #expect(error.description.contains("accept"))
    }

    @Test("connect description contains connect")
    func connectDescription() {
        let error = Windows.Kernel.Socket.Error.connect(.win32(5))
        #expect(error.description.contains("connect"))
    }

    @Test("send description contains send")
    func sendDescription() {
        let error = Windows.Kernel.Socket.Error.send(.win32(5))
        #expect(error.description.contains("send"))
    }

    @Test("receive description contains recv")
    func receiveDescription() {
        let error = Windows.Kernel.Socket.Error.receive(.win32(5))
        #expect(error.description.contains("recv"))
    }

    @Test("shutdown description contains shutdown")
    func shutdownDescription() {
        let error = Windows.Kernel.Socket.Error.shutdown(.win32(5))
        #expect(error.description.contains("shutdown"))
    }
}

// MARK: - Error Code Constants Tests

extension Windows.Kernel.Socket.Error.Test.Unit {
    @Test("Code.Connection.refused exists")
    func connectionRefusedExists() {
        let code = Windows.Kernel.Socket.Error.Code.Connection.refused
        #expect(code == WSAECONNREFUSED)
    }

    @Test("Code.Connection.reset exists")
    func connectionResetExists() {
        let code = Windows.Kernel.Socket.Error.Code.Connection.reset
        #expect(code == WSAECONNRESET)
    }

    @Test("Code.Connection.timedOut exists")
    func connectionTimedOutExists() {
        let code = Windows.Kernel.Socket.Error.Code.Connection.timedOut
        #expect(code == WSAETIMEDOUT)
    }

    @Test("Code.Address.inUse exists")
    func addressInUseExists() {
        let code = Windows.Kernel.Socket.Error.Code.Address.inUse
        #expect(code == WSAEADDRINUSE)
    }

    @Test("Code.Operation.wouldBlock exists")
    func operationWouldBlockExists() {
        let code = Windows.Kernel.Socket.Error.Code.Operation.wouldBlock
        #expect(code == WSAEWOULDBLOCK)
    }

    @Test("Code.State.notSocket exists")
    func stateNotSocketExists() {
        let code = Windows.Kernel.Socket.Error.Code.State.notSocket
        #expect(code == WSAENOTSOCK)
    }

    @Test("Code.Buffer.messageTooLong exists")
    func bufferMessageTooLongExists() {
        let code = Windows.Kernel.Socket.Error.Code.Buffer.messageTooLong
        #expect(code == WSAEMSGSIZE)
    }

    @Test("Code.Startup.notInitialized exists")
    func startupNotInitializedExists() {
        let code = Windows.Kernel.Socket.Error.Code.Startup.notInitialized
        #expect(code == WSANOTINITIALISED)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Socket.Error.Test.EdgeCase {
    @Test("Same case same code are equal")
    func sameCaseSameCodeEqual() {
        let code = Kernel.Error.Code.win32(42)
        #expect(Windows.Kernel.Socket.Error.create(code) == Windows.Kernel.Socket.Error.create(code))
        #expect(Windows.Kernel.Socket.Error.bind(code) == Windows.Kernel.Socket.Error.bind(code))
    }

    @Test("Different cases same code are not equal")
    func differentCasesSameCodeNotEqual() {
        let code = Kernel.Error.Code.win32(42)
        #expect(Windows.Kernel.Socket.Error.create(code) != Windows.Kernel.Socket.Error.bind(code))
        #expect(Windows.Kernel.Socket.Error.send(code) != Windows.Kernel.Socket.Error.receive(code))
    }
}

#endif
