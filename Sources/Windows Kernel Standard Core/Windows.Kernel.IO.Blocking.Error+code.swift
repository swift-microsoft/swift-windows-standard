// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)

// MARK: - Windows Error Code Mapping
//
// Windows has no analogue of POSIX `EAGAIN` for non-blocking I/O on synchronous
// handles — overlapped I/O surfaces "would block" via different mechanisms. The
// Windows mapping therefore returns `nil` for all codes; the cascade callers
// fall through to the next sub-mapper.

extension Kernel.IO.Blocking.Error {
    /// Always returns `nil` on Windows.
    @inlinable
    public init?(code: Error_Primitives.Error.Code) {
        return nil
    }
}
#endif
