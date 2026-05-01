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

extension Windows.`32`.Kernel.File.Open.Error {
    /// Creates an error by mapping a Windows error code to the appropriate case.
    @inlinable
    package init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Windows.`32`.Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Windows.`32`.Kernel.Storage.Error(code: code) {
            self = .space(e)
            return
        }
        if let e = Windows.`32`.Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
#endif
