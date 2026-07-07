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

/// Windows implementation of Terminal stream write operations.

#if os(Windows)
    public import Terminal_Primitives

    extension Terminal.Stream.Write {
        /// Write bytes to this terminal stream.
        ///
        /// Composes `Windows.`32`.Kernel.IO.Write.write(_:Terminal.Stream, from:)`
        /// with a partial-write loop. Returns only when every byte has been
        /// written, or throws if the underlying syscall reports a failure.
        ///
        /// Materializes the input sequence into contiguous storage before the
        /// syscall.
        ///
        /// - Parameter bytes: The bytes to write.
        /// - Returns: Total number of bytes written (equals `bytes.count` on
        ///   success; may be less on partial completion before a failure).
        /// - Throws: `Windows.`32`.Kernel.IO.Write.Error` on failure.
        @discardableResult
        public func callAsFunction(
            _ bytes: some Swift.Sequence<UInt8>
        ) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int {
            let array = ContiguousArray<UInt8>(bytes)
            return try unsafe array.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<UInt8>) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int in
                let raw = UnsafeRawBufferPointer(buffer)
                return try unsafe write(raw)
            }
        }

        /// Inner loop: partial-write retry over a contiguous raw buffer. No
        /// EINTR handling — Windows does not surface EINTR via WriteFile.
        private func write(
            _ raw: UnsafeRawBufferPointer
        ) throws(Windows.`32`.Kernel.IO.Write.Error) -> Int {
            var written = 0
            while written < raw.count {
                let remaining = unsafe UnsafeRawBufferPointer(rebasing: raw[written..<raw.count])
                let n = try unsafe Windows.`32`.Kernel.IO.Write.write(stream, from: remaining)
                written += n
            }
            return written
        }
    }

#endif
