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

public import Path_Primitives

// MARK: - Windows Error Code Mapping

extension Path.Canonical.Error {
    /// Creates an error from a Windows error code.
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        // Path.Canonical.Error has no `.permission` case (only .path / .platform);
        // access-denied and similar Win32 codes fold into .platform.
        self = .platform(Error_Primitives.Error(code: code))
    }
}
#endif
