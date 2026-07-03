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

// ISO 9945 signature parity for L3 consumers (swift-environment,
// swift-kernel test support).
//
// The POSIX leg's call forms — `get(name)`, `set(name, to:overwrite:)`,
// `unset(name)`, `entries()` — bind `Swift.String` arguments to
// `UnsafePointer<String.Char>` via the language's implicit conversion
// (String.Char == UInt8 there). That conversion does not exist for
// UInt16 pointers, so on Windows (String.Char == UInt16) semantic parity
// takes `Swift.String` directly and widens to UTF-16 at this boundary.

#if os(Windows)
internal import WinSDK
public import String_Primitives

extension Windows.`32`.Kernel.Environment {
    /// Gets an environment variable value.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment.get(_:)`: returns an owned
    /// copy, or `nil` if the variable is not set.
    public static func get(_ name: Swift.String) -> String_Primitives.String? {
        var wname = Array(name.utf16)
        wname.append(0)
        guard let units = wname.withUnsafeBufferPointer({ buf -> [UInt16]? in
            let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return get(name: wptr)
        }) else {
            return nil
        }
        return String_Primitives.String(units.span)
    }

    /// Sets an environment variable.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment.set(_:to:overwrite:)`
    /// (POSIX `setenv` semantics: with `overwrite: false` an existing
    /// value is kept and the call succeeds).
    public static func set(
        _ name: Swift.String,
        to value: Swift.String,
        overwrite: Bool = true
    ) throws(Windows.`32`.Kernel.Environment.Error) {
        // Throwing calls stay outside the buffer closures: the stdlib's
        // rethrows `withUnsafeBufferPointer` erases typed throws.
        var wname = Array(name.utf16)
        wname.append(0)
        var wvalue = Array(value.utf16)
        wvalue.append(0)
        if !overwrite {
            let exists = wname.withUnsafeBufferPointer { buf in
                let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                return GetEnvironmentVariableW(wptr, nil, 0) != 0
            }
            if exists {
                return  // exists and overwrite not requested — setenv semantics
            }
        }
        let ok = wname.withUnsafeBufferPointer { nameBuf in
            wvalue.withUnsafeBufferPointer { valueBuf in
                SetEnvironmentVariableW(
                    UnsafeRawPointer(nameBuf.baseAddress!).assumingMemoryBound(to: WCHAR.self),
                    UnsafeRawPointer(valueBuf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
                )
            }
        }
        guard ok else {
            throw .current()
        }
    }

    /// Unsets (removes) an environment variable.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment.unset(_:)`; does not fail if
    /// the variable does not exist.
    public static func unset(_ name: Swift.String) throws(Windows.`32`.Kernel.Environment.Error) {
        var wname = Array(name.utf16)
        wname.append(0)
        let ok = wname.withUnsafeBufferPointer { buf in
            let wptr = UnsafeRawPointer(buf.baseAddress!).assumingMemoryBound(to: WCHAR.self)
            return SetEnvironmentVariableW(wptr, nil)
        }
        if !ok {
            if GetLastError() == DWORD(ERROR_ENVVAR_NOT_FOUND) {
                return  // already unset, not an error
            }
            throw .current()
        }
    }

    /// Creates an iterator over all environment variables.
    ///
    /// Mirrors `ISO_9945.Kernel.Environment.entries()`. Optional on
    /// Windows: the environment block retrieval itself can fail.
    /// Windows-internal pseudo-variables (names beginning with `=`) are
    /// skipped by `next()`.
    public static func entries() -> Entries? {
        Entries()
    }
}

// MARK: - Entry name/value (ISO parity)

// Borrowed views rather than owned strings: mirrors the ISO 9945 Entry
// shape, and an owned `String_Primitives.String` return would make
// `Swift.String(entry.name)` ambiguous downstream (both swift-strings
// and swift-kernel's Kernel File declare owned-String bridge inits;
// only swift-strings declares the Borrowed one). Same lifetime pattern
// as `Directory.Entry.name`.

extension Windows.`32`.Kernel.Environment.Entries.Entry {
    /// The variable name as a borrowed view (UTF-16 code units before
    /// the first `=`). Mirrors `ISO_9945.Kernel.Environment.Entry.name`.
    public var name: String_Primitives.String.Borrowed {
        @_lifetime(borrow self)
        borrowing get {
            let ptr = unsafe _name.withUnsafeBufferPointer { $0.baseAddress! }
            let view = unsafe String_Primitives.String.Borrowed(ptr, count: _name.count - 1)
            return unsafe _overrideLifetime(view, borrowing: self)
        }
    }

    /// The variable value as a borrowed view (UTF-16 code units after
    /// the first `=`; empty if none). Mirrors
    /// `ISO_9945.Kernel.Environment.Entry.value`.
    public var value: String_Primitives.String.Borrowed {
        @_lifetime(borrow self)
        borrowing get {
            let ptr = unsafe _value.withUnsafeBufferPointer { $0.baseAddress! }
            let view = unsafe String_Primitives.String.Borrowed(ptr, count: _value.count - 1)
            return unsafe _overrideLifetime(view, borrowing: self)
        }
    }
}

#endif
