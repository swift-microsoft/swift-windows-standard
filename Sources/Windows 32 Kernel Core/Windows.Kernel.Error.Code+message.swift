// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    internal import WinSDK

    // MARK: - Win32 message lookup via FormatMessageW

    // FormatMessageW is a Win32-spec API over an L1 type (`Error_Primitives.Error.Code`).
    // Its canonical home is L2, not L3, per [PLAT-ARCH-008c]. L3 consumers reach
    // this through the `Windows_32_Kernel` umbrella re-export.

    extension Error_Primitives.Error.Code {
        /// Returns the Win32 error message for `.win32` codes via `FormatMessageW`.
        ///
        /// - Returns: The system-provided error description with trailing
        ///   whitespace removed, or `nil` for `.posix` codes or when
        ///   `FormatMessageW` fails.
        public var win32Message: Swift.String? {
            switch self {
            case .posix:
                return nil

            case .win32(let rawValue):
                let flags: DWORD =
                    DWORD(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS)

                var buffer: LPWSTR? = nil

                // MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT): (SUBLANG_DEFAULT << 10) | LANG_NEUTRAL
                let langNeutralSublangDefault: DWORD = 0x0400

                let length: DWORD = withUnsafeMutablePointer(to: &buffer) { bufferPtr in
                    bufferPtr.withMemoryRebound(to: WCHAR.self, capacity: 1) { widePtr in
                        FormatMessageW(
                            flags,
                            nil,
                            rawValue,
                            langNeutralSublangDefault,
                            widePtr,
                            0,
                            nil
                        )
                    }
                }

                guard length > 0, let buffer else { return nil }
                defer { _ = LocalFree(buffer) }

                let u16 = UnsafeBufferPointer(start: buffer, count: Swift.Int(length))
                var message = Swift.String(decoding: u16, as: UTF16.self)

                // Trim trailing whitespace/newlines without Foundation
                while let last = message.unicodeScalars.last,
                    last == "\r" || last == "\n" || last == " " || last == "\t"
                {
                    message.unicodeScalars.removeLast()
                }
                return message
            }
        }
    }
#endif
