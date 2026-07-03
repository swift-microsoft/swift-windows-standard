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

/// Terminal.Stream overloads for Windows.`32`.Kernel.IO.Write.
///
/// Standard streams (stdin/stdout/stderr) on Windows are obtained via
/// `GetStdHandle` rather than from numeric file descriptors. The mapping
/// from `Terminal.Stream` to `STD_*_HANDLE` is performed at the C boundary
/// per [IMPL-010]; the resolved HANDLE is then passed to the existing
/// `Windows.`32`.Kernel.IO.Write.write(_ handle: UInt, from:)` package-scoped
/// raw syscall.

#if os(Windows)
public import Terminal_Primitives
internal import WinSDK

extension Windows.`32`.Kernel.IO.Write {
    /// Writes bytes to a terminal stream.
    ///
    /// Single `WriteFile` invocation against the HANDLE resolved via
    /// `GetStdHandle`. Does NOT loop on partial writes. The high-level
    /// `Terminal.Stream.Write.callAsFunction` composes this with a partial-
    /// write loop suitable for terminal output.
    ///
    /// - Parameters:
    ///   - stream: The terminal stream to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: `Windows.`32`.Kernel.IO.Write.Error` on failure.
    public static func write(
        _ stream: Terminal.Stream,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard buffer.baseAddress != nil else {
            return 0
        }
        let stdHandleId: DWORD
        switch stream {
        case .stdin: stdHandleId = STD_INPUT_HANDLE
        case .stdout: stdHandleId = STD_OUTPUT_HANDLE
        case .stderr: stdHandleId = STD_ERROR_HANDLE
        }
        guard let stdHandle = GetStdHandle(stdHandleId),
              stdHandle != INVALID_HANDLE_VALUE else {
            throw .handle(.invalid)
        }
        return try Self.write(UInt(bitPattern: stdHandle), from: buffer)
    }
}

#endif
