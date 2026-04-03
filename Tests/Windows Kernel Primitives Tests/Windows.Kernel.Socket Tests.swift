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

@testable import Windows_Kernel_Primitives
@_spi(Syscall) import Kernel_Primitives

extension Windows.Kernel.Socket {
    enum Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Winsock Initialization Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("startup succeeds")
    func startupSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        #expect(Windows.Kernel.Socket.cleanup())
    }

    @Test("startup and cleanup can be called multiple times")
    func startupCleanupMultiple() throws {
        // Winsock uses reference counting
        try Windows.Kernel.Socket.startup()
        try Windows.Kernel.Socket.startup()
        #expect(Windows.Kernel.Socket.cleanup())
        #expect(Windows.Kernel.Socket.cleanup())
    }
}

// MARK: - Socket Creation Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("create TCP socket")
    func createTCPSocket() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream, protocol: .tcp)

        #expect(sock.isValid)
    }

    @Test("create UDP socket")
    func createUDPSocket() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .datagram, protocol: .udp)

        #expect(sock.isValid)
    }

    @Test("create IPv6 socket")
    func createIPv6Socket() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet6, type: .stream, protocol: .tcp)

        #expect(sock.isValid)
    }

    @Test("close socket succeeds")
    func closeSocketSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)
        Windows.Kernel.Socket.close(sock)
        // No throw means success
    }

    @Test("create multiple sockets are independent")
    func createMultipleSockets() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock1 = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        let sock2 = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        #expect(sock1._rawValue != sock2._rawValue)
    }
}

// MARK: - Family Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("Family.inet exists")
    func familyInetExists() {
        let family = Windows.Kernel.Socket.Family.inet
        #expect(family.rawValue == AF_INET)
    }

    @Test("Family.inet6 exists")
    func familyInet6Exists() {
        let family = Windows.Kernel.Socket.Family.inet6
        #expect(family.rawValue == AF_INET6)
    }

    @Test("Family.unspec exists")
    func familyUnspecExists() {
        let family = Windows.Kernel.Socket.Family.unspec
        #expect(family.rawValue == AF_UNSPEC)
    }
}

// MARK: - SocketType Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("SocketType.stream exists")
    func socketTypeStreamExists() {
        let type = Windows.Kernel.Socket.SocketType.stream
        #expect(type.rawValue == SOCK_STREAM)
    }

    @Test("SocketType.datagram exists")
    func socketTypeDatagramExists() {
        let type = Windows.Kernel.Socket.SocketType.datagram
        #expect(type.rawValue == SOCK_DGRAM)
    }

    @Test("SocketType.raw exists")
    func socketTypeRawExists() {
        let type = Windows.Kernel.Socket.SocketType.raw
        #expect(type.rawValue == SOCK_RAW)
    }
}

// MARK: - Protocol Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("Protocol.tcp exists")
    func protocolTCPExists() {
        let proto = Windows.Kernel.Socket.Protocol.tcp
        #expect(proto.rawValue == IPPROTO_TCP)
    }

    @Test("Protocol.udp exists")
    func protocolUDPExists() {
        let proto = Windows.Kernel.Socket.Protocol.udp
        #expect(proto.rawValue == IPPROTO_UDP)
    }

    @Test("Protocol.default exists")
    func protocolDefaultExists() {
        let proto = Windows.Kernel.Socket.Protocol.default
        #expect(proto.rawValue == 0)
    }
}

// MARK: - Byte Order Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("htons converts port correctly")
    func htonsConverts() {
        let port: UInt16 = 8080
        let networkOrder = Windows.Kernel.Socket.htons(port)
        let hostOrder = Windows.Kernel.Socket.ntohs(networkOrder)
        #expect(hostOrder == port)
    }

    @Test("htonl converts value correctly")
    func htonlConverts() {
        let value: UInt32 = 0x12345678
        let networkOrder = Windows.Kernel.Socket.htonl(value)
        let hostOrder = Windows.Kernel.Socket.ntohl(networkOrder)
        #expect(hostOrder == value)
    }
}

// MARK: - Socket Options Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("setReuseAddress succeeds")
    func setReuseAddressSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setReuseAddress(sock, enabled: true)
    }

    @Test("setNoDelay succeeds on TCP socket")
    func setNoDelaySucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream, protocol: .tcp)

        try Windows.Kernel.Socket.setNoDelay(sock, enabled: true)
    }

    @Test("setKeepAlive succeeds")
    func setKeepAliveSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setKeepAlive(sock, enabled: true)
    }

    @Test("setReceiveBuffer succeeds")
    func setReceiveBufferSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setReceiveBuffer(sock, size: 65536)
    }

    @Test("setSendBuffer succeeds")
    func setSendBufferSucceeds() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setSendBuffer(sock, size: 65536)
    }

    @Test("getError returns zero for new socket")
    func getErrorReturnsZero() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        let error = try Windows.Kernel.Socket.getError(sock)
        #expect(error == 0)
    }
}

// MARK: - Option Level Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("OptionLevel.socket exists")
    func optionLevelSocketExists() {
        let level = Windows.Kernel.Socket.OptionLevel.socket
        #expect(level.rawValue == SOL_SOCKET)
    }

    @Test("OptionLevel.tcp exists")
    func optionLevelTCPExists() {
        let level = Windows.Kernel.Socket.OptionLevel.tcp
        #expect(level.rawValue == IPPROTO_TCP)
    }

    @Test("OptionLevel.ipv4 exists")
    func optionLevelIPv4Exists() {
        let level = Windows.Kernel.Socket.OptionLevel.ipv4
        #expect(level.rawValue == IPPROTO_IP)
    }

    @Test("OptionLevel.ipv6 exists")
    func optionLevelIPv6Exists() {
        let level = Windows.Kernel.Socket.OptionLevel.ipv6
        #expect(level.rawValue == IPPROTO_IPV6)
    }
}

// MARK: - Option Name Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("OptionName.reuseAddr exists")
    func optionNameReuseAddrExists() {
        let name = Windows.Kernel.Socket.OptionName.reuseAddr
        #expect(name.rawValue == SO_REUSEADDR)
    }

    @Test("OptionName.keepAlive exists")
    func optionNameKeepAliveExists() {
        let name = Windows.Kernel.Socket.OptionName.keepAlive
        #expect(name.rawValue == SO_KEEPALIVE)
    }

    @Test("OptionName.tcpNoDelay exists")
    func optionNameTcpNoDelayExists() {
        let name = Windows.Kernel.Socket.OptionName.tcpNoDelay
        #expect(name.rawValue == TCP_NODELAY)
    }
}

// MARK: - Backlog Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("Backlog.default exists")
    func backlogDefaultExists() {
        let backlog = Kernel.Socket.Backlog.default
        #expect(backlog.rawValue == 128)
    }

    @Test("Backlog.small exists")
    func backlogSmallExists() {
        let backlog = Kernel.Socket.Backlog.small
        #expect(backlog.rawValue == 16)
    }

    @Test("Backlog.large exists")
    func backlogLargeExists() {
        let backlog = Kernel.Socket.Backlog.large
        #expect(backlog.rawValue == 4096)
    }

    @Test("Backlog.max exists")
    func backlogMaxExists() {
        let backlog = Kernel.Socket.Backlog.max
        #expect(backlog.rawValue == SOMAXCONN)
    }
}

// MARK: - Shutdown Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("Shutdown.How.sdReceive exists")
    func shutdownSdReceiveExists() {
        let how = Kernel.Socket.Shutdown.How.sdReceive
        #expect(how == SD_RECEIVE)
    }

    @Test("Shutdown.How.sdSend exists")
    func shutdownSdSendExists() {
        let how = Kernel.Socket.Shutdown.How.sdSend
        #expect(how == SD_SEND)
    }

    @Test("Shutdown.How.sdBoth exists")
    func shutdownSdBothExists() {
        let how = Kernel.Socket.Shutdown.How.sdBoth
        #expect(how == SD_BOTH)
    }
}

// MARK: - Send/Receive Flags Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test("SendFlags.none exists")
    func sendFlagsNoneExists() {
        let flags = Windows.Kernel.Socket.SendFlags.none
        #expect(flags.rawValue == 0)
    }

    @Test("SendFlags.outOfBand exists")
    func sendFlagsOOBExists() {
        let flags = Windows.Kernel.Socket.SendFlags.outOfBand
        #expect(flags.rawValue == MSG_OOB)
    }

    @Test("ReceiveFlags.none exists")
    func receiveFlagsNoneExists() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.none
        #expect(flags.rawValue == 0)
    }

    @Test("ReceiveFlags.peek exists")
    func receiveFlagsPeekExists() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.peek
        #expect(flags.rawValue == MSG_PEEK)
    }

    @Test("ReceiveFlags.waitAll exists")
    func receiveFlagsWaitAllExists() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.waitAll
        #expect(flags.rawValue == MSG_WAITALL)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Socket.Test.EdgeCase {
    @Test("create and immediately close many sockets")
    func createAndCloseManySockets() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        for _ in 0..<100 {
            let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)
            Windows.Kernel.Socket.close(sock)
        }
    }

    @Test("invalid socket descriptor")
    func invalidSocketDescriptor() {
        let invalid = Kernel.Socket.Descriptor.invalid
        #expect(!invalid.isValid)
        #expect(invalid._rawValue == UInt.max)
    }
}

#endif
