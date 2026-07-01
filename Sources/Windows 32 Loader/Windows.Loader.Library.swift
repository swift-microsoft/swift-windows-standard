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
public import Loader_Primitives
public import WinSDK

// MARK: - Windows Library Loading Operations

extension Windows.Loader.Library {
    /// Opens a dynamic library.
    ///
    /// Loads the specified DLL into the address space of the calling process.
    /// Uses Unicode API (LoadLibraryW) for proper path handling.
    ///
    /// - Parameter path: Path to the DLL file to load.
    /// - Returns: Handle to the loaded library.
    /// - Throws: `Loader.Error.open` on failure.
    ///
    /// ## Thread Safety
    ///
    /// Thread-safe. The loader provides internal synchronization.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let handle = try Windows.Loader.Library.open(path: "kernel32.dll")
    /// defer { try? Windows.Loader.Library.close(handle) }
    /// ```
    @unsafe
    public static func open(path: String) throws(Loader.Error) -> Loader.Library.Handle {
        let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
            LoadLibraryW(pathPtr)
        }

        guard let handle else {
            throw .open(captureLastErrorMessage())
        }

        return unsafe Loader.Library.Handle(rawValue: handle)
    }

    /// Opens a dynamic library with extended options.
    ///
    /// - Parameters:
    ///   - path: Path to the DLL file to load.
    ///   - flags: Loading flags (LOAD_LIBRARY_* constants).
    /// - Returns: Handle to the loaded library.
    /// - Throws: `Loader.Error.open` on failure.
    @unsafe
    public static func open(path: String, flags: DWORD) throws(Loader.Error) -> Loader.Library.Handle {
        let handle = path.withCString(encodedAs: UTF16.self) { pathPtr in
            LoadLibraryExW(pathPtr, nil, flags)
        }

        guard let handle else {
            throw .open(captureLastErrorMessage())
        }

        return unsafe Loader.Library.Handle(rawValue: handle)
    }

    /// Closes a dynamic library handle.
    ///
    /// Decrements the reference count for the loaded DLL. When the reference
    /// count reaches zero, the module is unloaded from the address space.
    ///
    /// - Parameter handle: The library handle to close.
    /// - Throws: `Loader.Error.close` on failure.
    ///
    /// ## Warning
    ///
    /// After calling close, all symbol pointers obtained from this library
    /// are invalid. Caller must ensure no in-flight symbol lookups are
    /// occurring on this handle.
    @unsafe
    public static func close(_ handle: Loader.Library.Handle) throws(Loader.Error) {
        let success = unsafe FreeLibrary(handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self))
        guard success else {
            throw .close(captureLastErrorMessage())
        }
    }

    /// Gets a handle to an already-loaded module.
    ///
    /// Returns a handle to a module that is already loaded in the calling process.
    ///
    /// - Parameter moduleName: Name of the module, or `nil` for the main executable.
    /// - Returns: Handle to the module, or `nil` if not loaded.
    @unsafe
    public static func getHandle(moduleName: String?) -> Loader.Library.Handle? {
        let handle: HMODULE?

        if let moduleName {
            handle = moduleName.withCString(encodedAs: UTF16.self) { namePtr in
                GetModuleHandleW(namePtr)
            }
        } else {
            handle = GetModuleHandleW(nil)
        }

        guard let handle else {
            return nil
        }

        return unsafe Loader.Library.Handle(rawValue: handle)
    }
}

// MARK: - Loading Flags

extension Windows.Loader.Library {
    /// Flags for LoadLibraryExW.
    public struct Flags: OptionSet, Sendable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /// If this value is used, and the executable module is a DLL, the
        /// system does not call DllMain for process and thread initialization
        /// and termination.
        public static let dontResolveDllReferences = Flags(rawValue: UInt32(DONT_RESOLVE_DLL_REFERENCES))

        /// The system does not check AppLocker rules or apply Software
        /// Restriction Policies for the DLL.
        public static let loadIgnoreCodeAuthzLevel = Flags(rawValue: UInt32(LOAD_IGNORE_CODE_AUTHZ_LEVEL))

        /// If this value is used, the system maps the file into the calling
        /// process's virtual address space as if it were a data file.
        public static let loadLibraryAsDatafile = Flags(rawValue: UInt32(LOAD_LIBRARY_AS_DATAFILE))

        /// Similar to LOAD_LIBRARY_AS_DATAFILE, except that the DLL file is
        /// opened with exclusive write access for the calling process.
        public static let loadLibraryAsDatafileExclusive = Flags(rawValue: UInt32(LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE))

        /// If this value is used, the system maps the file into the process's
        /// virtual address space as an image file.
        public static let loadLibraryAsImageResource = Flags(rawValue: UInt32(LOAD_LIBRARY_AS_IMAGE_RESOURCE))

        /// If this value is used, the directory that contains the DLL is
        /// temporarily added to the beginning of the list of directories
        /// that are searched for the DLL's dependencies.
        public static let loadWithAlteredSearchPath = Flags(rawValue: UInt32(LOAD_WITH_ALTERED_SEARCH_PATH))
    }
}

#endif
