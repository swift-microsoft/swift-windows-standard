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
@_spi(Syscall) import Error_Primitives

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
    @Test
    func `startup succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        #expect(Windows.Kernel.Socket.cleanup())
    }

    @Test
    func `startup and cleanup can be called multiple times`() throws {
        // Winsock uses reference counting
        try Windows.Kernel.Socket.startup()
        try Windows.Kernel.Socket.startup()
        #expect(Windows.Kernel.Socket.cleanup())
        #expect(Windows.Kernel.Socket.cleanup())
    }
}

// MARK: - Socket Creation Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `create TCP socket`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream, protocol: .tcp)

        #expect(sock.isValid)
    }

    @Test
    func `create UDP socket`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .datagram, protocol: .udp)

        #expect(sock.isValid)
    }

    @Test
    func `create IPv6 socket`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet6, type: .stream, protocol: .tcp)

        #expect(sock.isValid)
    }

    @Test
    func `close socket succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)
        Windows.Kernel.Socket.close(sock)
        // No throw means success
    }

    @Test
    func `create multiple sockets are independent`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock1 = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        let sock2 = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        #expect(sock1._rawValue != sock2._rawValue)
    }
}

// MARK: - Family Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `Family.inet exists`() {
        let family = Windows.Kernel.Socket.Family.inet
        #expect(family.rawValue == AF_INET)
    }

    @Test
    func `Family.inet6 exists`() {
        let family = Windows.Kernel.Socket.Family.inet6
        #expect(family.rawValue == AF_INET6)
    }

    @Test
    func `Family.unspec exists`() {
        let family = Windows.Kernel.Socket.Family.unspec
        #expect(family.rawValue == AF_UNSPEC)
    }
}

// MARK: - SocketType Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `SocketType.stream exists`() {
        let type = Windows.Kernel.Socket.SocketType.stream
        #expect(type.rawValue == SOCK_STREAM)
    }

    @Test
    func `SocketType.datagram exists`() {
        let type = Windows.Kernel.Socket.SocketType.datagram
        #expect(type.rawValue == SOCK_DGRAM)
    }

    @Test
    func `SocketType.raw exists`() {
        let type = Windows.Kernel.Socket.SocketType.raw
        #expect(type.rawValue == SOCK_RAW)
    }
}

// MARK: - Protocol Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `Protocol.tcp exists`() {
        let proto = Windows.Kernel.Socket.Protocol.tcp
        #expect(proto.rawValue == IPPROTO_TCP)
    }

    @Test
    func `Protocol.udp exists`() {
        let proto = Windows.Kernel.Socket.Protocol.udp
        #expect(proto.rawValue == IPPROTO_UDP)
    }

    @Test
    func `Protocol.default exists`() {
        let proto = Windows.Kernel.Socket.Protocol.default
        #expect(proto.rawValue == 0)
    }
}

// MARK: - Byte Order Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `htons converts port correctly`() {
        let port: UInt16 = 8080
        let networkOrder = Windows.Kernel.Socket.htons(port)
        let hostOrder = Windows.Kernel.Socket.ntohs(networkOrder)
        #expect(hostOrder == port)
    }

    @Test
    func `htonl converts value correctly`() {
        let value: UInt32 = 0x12345678
        let networkOrder = Windows.Kernel.Socket.htonl(value)
        let hostOrder = Windows.Kernel.Socket.ntohl(networkOrder)
        #expect(hostOrder == value)
    }
}

// MARK: - Socket Options Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `setReuseAddress succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setReuseAddress(sock, enabled: true)
    }

    @Test
    func `setNoDelay succeeds on TCP socket`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream, protocol: .tcp)

        try Windows.Kernel.Socket.setNoDelay(sock, enabled: true)
    }

    @Test
    func `setKeepAlive succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setKeepAlive(sock, enabled: true)
    }

    @Test
    func `setReceiveBuffer succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setReceiveBuffer(sock, size: 65536)
    }

    @Test
    func `setSendBuffer succeeds`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        try Windows.Kernel.Socket.setSendBuffer(sock, size: 65536)
    }

    @Test
    func `getError returns zero for new socket`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)

        let error = try Windows.Kernel.Socket.getError(sock)
        #expect(error == 0)
    }
}

// MARK: - Option Level Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `OptionLevel.socket exists`() {
        let level = Windows.Kernel.Socket.OptionLevel.socket
        #expect(level.rawValue == SOL_SOCKET)
    }

    @Test
    func `OptionLevel.tcp exists`() {
        let level = Windows.Kernel.Socket.OptionLevel.tcp
        #expect(level.rawValue == IPPROTO_TCP)
    }

    @Test
    func `OptionLevel.ipv4 exists`() {
        let level = Windows.Kernel.Socket.OptionLevel.ipv4
        #expect(level.rawValue == IPPROTO_IP)
    }

    @Test
    func `OptionLevel.ipv6 exists`() {
        let level = Windows.Kernel.Socket.OptionLevel.ipv6
        #expect(level.rawValue == IPPROTO_IPV6)
    }
}

// MARK: - Option Name Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `OptionName.reuseAddr exists`() {
        let name = Windows.Kernel.Socket.OptionName.reuseAddr
        #expect(name.rawValue == SO_REUSEADDR)
    }

    @Test
    func `OptionName.keepAlive exists`() {
        let name = Windows.Kernel.Socket.OptionName.keepAlive
        #expect(name.rawValue == SO_KEEPALIVE)
    }

    @Test
    func `OptionName.tcpNoDelay exists`() {
        let name = Windows.Kernel.Socket.OptionName.tcpNoDelay
        #expect(name.rawValue == TCP_NODELAY)
    }
}

// MARK: - Backlog Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `Backlog.default exists`() {
        let backlog = Kernel.Socket.Backlog.default
        #expect(backlog.rawValue == 128)
    }

    @Test
    func `Backlog.small exists`() {
        let backlog = Kernel.Socket.Backlog.small
        #expect(backlog.rawValue == 16)
    }

    @Test
    func `Backlog.large exists`() {
        let backlog = Kernel.Socket.Backlog.large
        #expect(backlog.rawValue == 4096)
    }

    @Test
    func `Backlog.max exists`() {
        let backlog = Kernel.Socket.Backlog.max
        #expect(backlog.rawValue == SOMAXCONN)
    }
}

// MARK: - Shutdown Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `Shutdown.How.sdReceive exists`() {
        let how = Kernel.Socket.Shutdown.How.sdReceive
        #expect(how == SD_RECEIVE)
    }

    @Test
    func `Shutdown.How.sdSend exists`() {
        let how = Kernel.Socket.Shutdown.How.sdSend
        #expect(how == SD_SEND)
    }

    @Test
    func `Shutdown.How.sdBoth exists`() {
        let how = Kernel.Socket.Shutdown.How.sdBoth
        #expect(how == SD_BOTH)
    }
}

// MARK: - Send/Receive Flags Tests

extension Windows.Kernel.Socket.Test.Unit {
    @Test
    func `SendFlags.none exists`() {
        let flags = Windows.Kernel.Socket.SendFlags.none
        #expect(flags.rawValue == 0)
    }

    @Test
    func `SendFlags.outOfBand exists`() {
        let flags = Windows.Kernel.Socket.SendFlags.outOfBand
        #expect(flags.rawValue == MSG_OOB)
    }

    @Test
    func `ReceiveFlags.none exists`() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.none
        #expect(flags.rawValue == 0)
    }

    @Test
    func `ReceiveFlags.peek exists`() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.peek
        #expect(flags.rawValue == MSG_PEEK)
    }

    @Test
    func `ReceiveFlags.waitAll exists`() {
        let flags = Windows.Kernel.Socket.ReceiveFlags.waitAll
        #expect(flags.rawValue == MSG_WAITALL)
    }
}

// MARK: - Edge Cases

extension Windows.Kernel.Socket.Test.EdgeCase {
    @Test
    func `create and immediately close many sockets`() throws {
        try Windows.Kernel.Socket.startup()
        defer { Windows.Kernel.Socket.cleanup() }

        for _ in 0..<100 {
            let sock = try Windows.Kernel.Socket.create(family: .inet, type: .stream)
            Windows.Kernel.Socket.close(sock)
        }
    }

    @Test
    func `invalid socket descriptor`() {
        let invalid = Kernel.Socket.Descriptor.invalid
        #expect(!invalid.isValid)
        #expect(invalid._rawValue == UInt.max)
    }
}

#endif
