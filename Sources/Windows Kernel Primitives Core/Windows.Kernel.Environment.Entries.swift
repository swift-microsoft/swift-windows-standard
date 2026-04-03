// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-windows project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
@_spi(Syscall) public import Kernel_Primitives
public import WinSDK
public import Sequence_Primitives

// MARK: - Windows Environment Enumeration

extension Windows.Kernel.Environment {
    /// An iterator over all environment variables.
    ///
    /// Uses `GetEnvironmentStringsW` to retrieve the environment block
    /// and iterates over null-separated entries.
    ///
    /// ## Usage
    /// ```swift
    /// for entry in Windows.Kernel.Environment.Entries() {
    ///     if let (name, value) = entry.parsed {
    ///         print("\(name)=\(value)")
    ///     }
    /// }
    /// ```
    public struct Entries: ~Copyable, Sequence {
        private let block: LPWCH

        /// Creates an iterator over all environment variables.
        ///
        /// Returns `nil` if the environment block cannot be retrieved.
        public init?() {
            guard let block = GetEnvironmentStringsW() else {
                return nil
            }
            self.block = block
        }

        deinit {
            FreeEnvironmentStringsW(block)
        }

        public func makeIterator() -> Iterator {
            Iterator(current: block)
        }
    }
}

// MARK: - Entry Type

extension Windows.Kernel.Environment.Entries {
    /// A single environment variable entry.
    public struct Entry: Sendable {
        /// The raw UTF-16 string (NAME=VALUE format).
        public let raw: [UInt16]

        init(raw: [UInt16]) {
            self.raw = raw
        }

        /// The entry as a Swift String.
        public var string: String? {
            String(decoding: raw, as: UTF16.self)
        }

        /// Parses the entry into name and value.
        ///
        /// - Returns: Tuple of (name, value), or `nil` if parsing fails.
        public var parsed: (name: String, value: String)? {
            guard let str = string,
                  let eqIndex = str.firstIndex(of: "="),
                  eqIndex != str.startIndex else {
                return nil
            }
            let name = String(str[..<eqIndex])
            let value = String(str[str.index(after: eqIndex)...])
            return (name, value)
        }
    }
}

// MARK: - Iterator

extension Windows.Kernel.Environment.Entries {
    /// Iterator over environment variable entries.
    public struct Iterator: Sequence.Iterator.`Protocol`, IteratorProtocol {
        private var current: LPWCH

        init(current: LPWCH) {
            self.current = current
        }

        private var _element: Entry? = nil

        @_lifetime(&self)
        public mutating func nextSpan(maximumCount: Cardinal) -> Span<Entry> {
            let ptr = unsafe withUnsafeMutablePointer(to: &_element) { p in
                unsafe UnsafePointer<Entry>(
                    unsafe UnsafeRawPointer(p).assumingMemoryBound(to: Entry.self)
                )
            }
            guard maximumCount > .zero else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            guard let value = next() else {
                let span = unsafe Span(_unsafeStart: ptr, count: 0)
                return unsafe _overrideLifetime(span, mutating: &self)
            }
            _element = value
            let span = unsafe Span(_unsafeStart: ptr, count: 1)
            return unsafe _overrideLifetime(span, mutating: &self)
        }

        public mutating func next() -> Entry? {
            // Check for end of block (double null)
            guard current.pointee != 0 else {
                return nil
            }

            // Find the end of this entry
            var end = current
            while end.pointee != 0 {
                end = end.advanced(by: 1)
            }

            // Calculate length and copy
            let length = current.distance(to: end)
            guard length > 0 else {
                return nil
            }

            // Copy the string
            var chars = [UInt16](repeating: 0, count: length)
            for i in 0..<length {
                chars[i] = current.advanced(by: i).pointee
            }

            // Move past the null terminator to the next entry
            current = end.advanced(by: 1)

            return Entry(raw: chars)
        }
    }
}

// MARK: - Convenience

extension Windows.Kernel.Environment {
    /// Returns all environment variables as a dictionary.
    ///
    /// - Returns: Dictionary of name-value pairs, or `nil` on failure.
    public static func all() -> [String: String]? {
        guard let entries = Entries() else { return nil }

        var result = [String: String]()
        for entry in entries {
            if let (name, value) = entry.parsed {
                result[name] = value
            }
        }
        return result
    }
}

#endif
