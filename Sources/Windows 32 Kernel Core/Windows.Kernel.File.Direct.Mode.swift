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

extension Windows.`32`.Kernel.File.Direct {
    /// Requested caching/direct-I/O mode. Mirrors
    /// `ISO_9945.Kernel.File.Direct.Mode`.
    public enum Mode: Sendable, Equatable {
        /// Strict Direct I/O (alignment enforced).
        case direct

        /// Uncached I/O without strict alignment (macOS F_NOCACHE analog).
        case uncached

        /// Normal buffered I/O.
        case buffered

        /// Resolve automatically per ``Policy``.
        case auto(policy: Policy)
    }
}

// MARK: - Resolution

extension Windows.`32`.Kernel.File.Direct.Mode {
    /// Resolves the requested mode against the discovered requirements.
    ///
    /// Mirrors the ISO 9945 non-macOS resolution: strict `direct` requires
    /// known alignment requirements; `auto` falls back per policy.
    public func resolve(
        given requirements: Windows.`32`.Kernel.File.Direct.Requirements
    ) throws(Windows.`32`.Kernel.File.Direct.Error) -> Resolved {
        switch self {
        case .buffered:
            return .buffered

        case .uncached:
            // Windows has no F_NOCACHE analog distinct from NO_BUFFERING;
            // treat as buffered (matches the ISO non-Darwin path).
            return .buffered

        case .direct:
            guard case .known = requirements else {
                throw .notSupported
            }
            return .direct

        case .auto(let policy):
            if case .known = requirements {
                return .direct
            }
            switch policy {
            case .fallbackToBuffered:
                return .buffered
            case .errorOnViolation:
                throw .notSupported
            }
        }
    }
}
