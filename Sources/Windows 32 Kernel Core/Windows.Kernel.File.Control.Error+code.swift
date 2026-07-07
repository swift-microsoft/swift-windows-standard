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

    extension Windows.`32`.Kernel.File.Control.Error {
        /// Creates an error from a Windows error code.
        @usableFromInline
        internal init(code: Error_Primitives.Error.Code) {
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
