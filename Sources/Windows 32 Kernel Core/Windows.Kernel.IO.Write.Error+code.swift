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

    // MARK: - Windows Error Code Access

    extension Windows.`32`.Kernel.IO.Write.Error {
        /// The underlying Windows error code.
        @inlinable
        public var code: Error_Primitives.Error.Code {
            switch self {
            case .handle(let e): return e.code
            case .blocking: return .Windows.ERROR_NOT_SUPPORTED
            case .platform(let e): return e.code
            }
        }
    }

    // MARK: - Windows Error Code Mapping

    extension Windows.`32`.Kernel.IO.Write.Error {
        /// Creates an error from a Windows error code.
        @inlinable
        public init(code: Error_Primitives.Error.Code) {
            if let e = Windows.`32`.Kernel.Descriptor.Validity.Error(code: code) {
                self = .handle(e)
                return
            }
            if let e = Windows.`32`.Kernel.IO.Blocking.Error(code: code) {
                self = .blocking(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: code))
        }
    }
#endif
