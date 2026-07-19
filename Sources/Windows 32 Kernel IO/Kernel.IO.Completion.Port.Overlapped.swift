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

    extension Windows.`32`.Kernel.IO.Completion.Port {
        /// Tracks the state of an asynchronous I/O operation on Windows.
        ///
        /// Every asynchronous I/O operation requires an `OVERLAPPED` structure
        /// to track its state. The structure must remain valid until the
        /// operation completes. Common patterns embed this in a larger struct
        /// to associate application state with the operation.
        ///
        /// ## Usage
        ///
        /// `read`/`write` take `UnsafeMutablePointer<Overlapped>`, not
        /// `inout Overlapped`: the pointer must stay valid and unmoved for
        /// the *entire operation*, not merely for the duration of the call
        /// that starts it. On a `.pending` result the kernel keeps writing
        /// completion state into this exact address, and posts a packet
        /// referencing it, after the initiating call has already returned —
        /// which can be arbitrarily later. A plain Swift local passed via
        /// `inout` does not give that guarantee (`withUnsafeMutablePointer`
        /// only promises validity for its own closure's duration); a
        /// pointer the caller allocates and owns for the operation's
        /// lifetime does:
        ///
        /// ```swift
        /// let overlapped = UnsafeMutablePointer<Windows.`32`.Kernel.IO.Completion.Port.Overlapped>
        ///     .allocate(capacity: 1)
        /// overlapped.initialize(to: .init())
        /// overlapped.pointee.offset = position
        ///
        /// // Start async read — `overlapped` must remain valid and unmoved
        /// // until the operation completes (dequeued or cancelled).
        /// let result = try unsafe Windows.`32`.Kernel.IO.Completion.Port.read(
        ///     handle,
        ///     into: buffer,
        ///     overlapped: overlapped
        /// )
        ///
        /// // Later, retrieve completion
        /// let entry = try Windows.`32`.Kernel.IO.Completion.Port.Dequeue.single(port, timeout: .infinite)
        /// let count = entry.bytes.transferred
        ///
        /// // Once dequeued (or cancelled and confirmed not pending), the
        /// // caller reclaims the storage:
        /// overlapped.deinitialize(count: 1)
        /// overlapped.deallocate()
        /// ```
        ///
        /// ## Container-Of Pattern
        ///
        /// For associating state with operations, embed `Overlapped` as the
        /// first field of a **heap-allocated** (e.g. `class`) type, so its
        /// address stays stable across the whole operation the same way the
        /// pointer above does:
        ///
        /// ```swift
        /// final class MyOperation {
        ///     var overlapped: Windows.`32`.Kernel.IO.Completion.Port.Overlapped
        ///     var buffer: [UInt8]
        ///     var callback: (Int) -> Void
        ///     init(buffer: [UInt8], callback: @escaping (Int) -> Void) {
        ///         self.overlapped = .init()
        ///         self.buffer = buffer
        ///         self.callback = callback
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/IO/Completion/Port``
        /// - ``Kernel/IO/Completion/Port/Entry``
        @safe
        public struct Overlapped: @unchecked Sendable {
            /// The underlying Windows OVERLAPPED structure.
            @usableFromInline
            internal var raw: OVERLAPPED

            /// Creates a zero-initialized overlapped structure.
            @inlinable
            public init() {
                raw = OVERLAPPED()
            }
        }
    }

    // MARK: - Accessors

    extension Windows.`32`.Kernel.IO.Completion.Port.Overlapped {
        /// The 64-bit file offset for positioned I/O.
        @inlinable
        public var offset: Int64 {
            get { Int64(raw.Offset) | (Int64(raw.OffsetHigh) << 32) }
            set {
                raw.Offset = DWORD(truncatingIfNeeded: newValue)
                raw.OffsetHigh = DWORD(truncatingIfNeeded: newValue >> 32)
            }
        }
    }

#endif
