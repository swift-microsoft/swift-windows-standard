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
public import WinSDK

// MARK: - Windows Environment Enumeration

extension Windows.`32`.Kernel.Environment {
    /// An iterator over all environment variables.
    ///
    /// Uses `GetEnvironmentStringsW` to retrieve the environment block
    /// and iterates over null-separated entries.
    ///
    /// ## Usage
    /// ```swift
    /// if let entries = Windows.`32`.Kernel.Environment.Entries() {
    ///     var iterator = entries.makeIterator()
    ///     while let entry = iterator.next() {
    ///         if let (name, value) = entry.parsed {
    ///             print("\(name)=\(value)")
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// `Entries` is `~Copyable` (it owns the environment block and frees it
    /// on deinit), so it cannot conform to `Swift.Sequence`; iterate via
    /// ``makeIterator()`` and `next()` (mirrors the ISO 9945 `Entries`
    /// shape, which also iterates without a `Sequence` conformance).
    public struct Entries: ~Copyable {
        private let block: LPWCH

        /// Iteration cursor for the self-iterating ISO-parity form.
        private var current: LPWCH

        /// Creates an iterator over all environment variables.
        ///
        /// Returns `nil` if the environment block cannot be retrieved.
        public init?() {
            guard let block = GetEnvironmentStringsW() else {
                return nil
            }
            self.block = block
            self.current = block
        }

        deinit {
            FreeEnvironmentStringsW(block)
        }
    }
}

extension Windows.`32`.Kernel.Environment.Entries {
    public func makeIterator() -> Iterator {
        Iterator(current: block)
    }

    /// Advances to the next environment variable (ISO-parity form:
    /// mirrors `ISO_9945.Kernel.Environment.Entries.next()`).
    ///
    /// Skips Windows-internal pseudo-variables (entries whose name
    /// begins with `=`, e.g. `=C:=C:\...`) so L3 consumers see only
    /// real variables.
    public mutating func next() -> Entry? {
        var iterator = Iterator(current: current)
        while let entry = iterator.next() {
            current = iterator.position
            if entry.raw.first == 0x003D {  // '='
                continue
            }
            return entry
        }
        current = iterator.position
        return nil
    }
}

// MARK: - Entry Type

extension Windows.`32`.Kernel.Environment.Entries {
    /// A single environment variable entry.
    public struct Entry: Sendable {
        /// The raw UTF-16 string (NAME=VALUE format).
        public let raw: [UInt16]

        /// Null-terminated UTF-16 name (code units before the first `=`).
        /// Stored so ``name`` can vend a borrowed view into stable storage.
        @usableFromInline
        internal let _name: [UInt16]

        /// Null-terminated UTF-16 value (code units after the first `=`;
        /// just the terminator if none). Stored so ``value`` can vend a
        /// borrowed view into stable storage.
        @usableFromInline
        internal let _value: [UInt16]

        init(raw: [UInt16]) {
            self.raw = raw
            let bound = raw.firstIndex(of: 0x003D) ?? raw.endIndex  // '='
            var name = Array(raw[..<bound])
            name.append(0)
            self._name = name
            var value = bound < raw.endIndex ? Array(raw[raw.index(after: bound)...]) : []
            value.append(0)
            self._value = value
        }
    }
}

extension Windows.`32`.Kernel.Environment.Entries.Entry {
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

// MARK: - Iterator

extension Windows.`32`.Kernel.Environment.Entries {
    /// Iterator over environment variable entries.
    public struct Iterator: IteratorProtocol {
        private var current: LPWCH

        init(current: LPWCH) {
            self.current = current
        }
    }
}

extension Windows.`32`.Kernel.Environment.Entries.Iterator {
    /// The current block position (consumed by `Entries.next()` to
    /// keep its own cursor in step).
    internal var position: LPWCH { current }

    public mutating func next() -> Windows.`32`.Kernel.Environment.Entries.Entry? {
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

        return Windows.`32`.Kernel.Environment.Entries.Entry(raw: chars)
    }
}

// MARK: - Convenience

extension Windows.`32`.Kernel.Environment {
    /// Returns all environment variables as a dictionary.
    ///
    /// - Returns: Dictionary of name-value pairs, or `nil` on failure.
    public static func all() -> [String: String]? {
        guard let entries = Entries() else { return nil }

        var result = [String: String]()
        var iterator = entries.makeIterator()
        while let entry = iterator.next() {
            if let (name, value) = entry.parsed {
                result[name] = value
            }
        }
        return result
    }
}

#endif
