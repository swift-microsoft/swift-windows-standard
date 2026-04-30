// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
    public import Error_Primitives
    public import WinSDK

    extension Windows.Kernel.IO.Completion.Port.Entry {
        /// Byte-related properties for completion entry.
        ///
        /// Provides access to byte counts from completed I/O operations.
        public struct Bytes: Sendable {
            @usableFromInline
            let entry: Windows.Kernel.IO.Completion.Port.Entry

            @usableFromInline
            init(entry: Windows.Kernel.IO.Completion.Port.Entry) {
                self.entry = entry
            }

            /// Number of bytes transferred in the completed operation.
            @inlinable
            public var transferred: Windows.Kernel.File.Size {
                Windows.Kernel.File.Size(Int64(entry.raw.dwNumberOfBytesTransferred))
            }
        }
    }

#endif
