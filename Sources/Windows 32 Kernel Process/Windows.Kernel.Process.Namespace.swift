// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Windows.`32`.Kernel {
    /// Win32 process operations namespace (L2 spec form).
    ///
    /// Hosts ``Spawn`` (CreateProcessW + STARTUPINFOEX wiring) plus
    /// per-process queries (``getCurrentId()``, ``getCurrentHandle()``,
    /// ``terminate(handle:exitCode:)``, ``getExitCode(handle:)``,
    /// ``wait(handle:timeout:)``) and ``Exit`` (`ExitProcess` for the
    /// calling process).
    ///
    /// Mirrors the POSIX iso-9945 ``ISO_9945/Kernel/Process`` namespace
    /// in shape so the L3-unifier swift-process composes typed process
    /// operations uniformly across platforms.
    public enum Process: Sendable {}
}

// Process.Error is currently declared at
// Sources/Windows 32 Kernel Process/Windows.Kernel.Process.swift inside
// `#if os(Windows)`. For cross-platform name resolution, declare a
// cross-platform Error type here.
extension Windows.`32`.Kernel.Process {
    /// Errors from Win32 process operations.
    ///
    /// Mirrors the POSIX iso-9945 ``ISO_9945/Kernel/Process/Error`` shape
    /// in structure (case for spawn / wait / status with embedded error
    /// codes).
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// `CreateProcessW` failed (or related setup such as
        /// `InitializeProcThreadAttributeList`).
        case create(Error_Primitives.Error.Code)

        /// `WaitForSingleObject` (or related wait) failed.
        case wait(Error_Primitives.Error.Code)

        /// Other platform error.
        case platform(Error_Primitives.Error)
    }
}

extension Windows.`32`.Kernel.Process.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .create(let c): return "create: \(c)"
        case .wait(let c): return "wait: \(c)"
        case .platform(let e): return "\(e)"
        }
    }
}
