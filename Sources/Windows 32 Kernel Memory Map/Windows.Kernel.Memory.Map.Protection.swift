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
    public import Error_Primitives
    public import Memory_Primitives
    public import WinSDK

    // MARK: - Windows Memory Protection Constants

    extension Memory.Map.Protection {
        /// Permits reading from mapped pages.
        public static let read = Self(rawValue: 1)

        /// Permits writing to mapped pages.
        public static let write = Self(rawValue: 2)

        /// Permits executing code from mapped pages.
        public static let execute = Self(rawValue: 4)

        /// Convenience for read and write access.
        public static let readWrite: Self = read | write

        /// Convenience for read and execute access.
        public static let readExecute: Self = read | execute
    }

    // MARK: - Windows Protection Conversion

    extension Memory.Map.Protection {
        /// Converts to Windows VirtualAlloc/VirtualProtect protection flags.
        @usableFromInline
        internal var windowsVirtualProtect: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            if hasExecute && hasWrite {
                return DWORD(PAGE_EXECUTE_READWRITE)
            } else if hasExecute && hasRead {
                return DWORD(PAGE_EXECUTE_READ)
            } else if hasExecute {
                return DWORD(PAGE_EXECUTE)
            } else if hasWrite {
                return DWORD(PAGE_READWRITE)
            } else if hasRead {
                return DWORD(PAGE_READONLY)
            } else {
                return DWORD(PAGE_NOACCESS)
            }
        }

        /// Converts to Windows CreateFileMapping protection flags.
        @usableFromInline
        internal var windowsFileMapProtect: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            if hasExecute && hasWrite {
                return DWORD(PAGE_EXECUTE_READWRITE)
            } else if hasExecute && hasRead {
                return DWORD(PAGE_EXECUTE_READ)
            } else if hasWrite {
                return DWORD(PAGE_READWRITE)
            } else {
                return DWORD(PAGE_READONLY)
            }
        }

        /// Converts to Windows MapViewOfFile desired access flags.
        @usableFromInline
        internal var windowsMapViewAccess: DWORD {
            let hasRead = contains(.read)
            let hasWrite = contains(.write)
            let hasExecute = contains(.execute)

            var access: DWORD = 0
            if hasWrite {
                access = DWORD(FILE_MAP_WRITE)
            } else if hasRead {
                access = DWORD(FILE_MAP_READ)
            }
            if hasExecute {
                access |= DWORD(FILE_MAP_EXECUTE)
            }
            return access
        }

        /// Converts to Windows CreateFileMapping protection flags for a
        /// copy-on-write (`.private`) mapping.
        ///
        /// Windows expresses "private" (`Memory.Map.Options.private`) via
        /// `PAGE_WRITECOPY` / `PAGE_EXECUTE_WRITECOPY` on the *mapping
        /// object*, paired with `FILE_MAP_COPY` on the *view* (see
        /// ``windowsMapViewAccessCopyOnWrite``). `MapViewOfFile` requires
        /// the mapping object to have been created with `PAGE_READWRITE`,
        /// `PAGE_EXECUTE_READWRITE`, `PAGE_WRITECOPY`, or
        /// `PAGE_EXECUTE_WRITECOPY` protection before `FILE_MAP_COPY` is a
        /// valid view access — a plain `PAGE_READONLY` mapping object (what
        /// ``windowsFileMapProtect`` would otherwise select for read-only
        /// protection) cannot back a copy-on-write view at all.
        @usableFromInline
        internal var windowsFileMapProtectCopyOnWrite: DWORD {
            contains(.execute) ? DWORD(PAGE_EXECUTE_WRITECOPY) : DWORD(PAGE_WRITECOPY)
        }

        /// Converts to Windows MapViewOfFile desired access flags for a
        /// copy-on-write (`.private`) mapping.
        ///
        /// `FILE_MAP_COPY` alone already permits writes (with copy-on-write
        /// semantics: modified pages are privately copied and never written
        /// back to the file) — it must not be combined with
        /// `FILE_MAP_WRITE`. `FILE_MAP_EXECUTE` may still be combined with
        /// it for an executable private view.
        @usableFromInline
        internal var windowsMapViewAccessCopyOnWrite: DWORD {
            var access = DWORD(FILE_MAP_COPY)
            if contains(.execute) {
                access |= DWORD(FILE_MAP_EXECUTE)
            }
            return access
        }
    }

#endif
