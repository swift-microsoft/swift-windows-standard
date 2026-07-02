// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Error_Primitives
public import Memory_Primitives

extension Windows.`32`.Kernel.File.Handle {
    /// Errors for handle-level I/O. Mirrors
    /// `ISO_9945.Kernel.File.Handle.Error`.
    public enum Error: Swift.Error, Sendable, Equatable {
        case invalidHandle
        case endOfFile
        case noSpace
        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)
        case misalignedOffset(offset: Int64, required: Memory.Alignment)
        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)
        case requirementsUnknown
        case alignmentViolation(operation: Operation)
        case platform(code: Error_Primitives.Error.Code, operation: Operation)
    }
}
