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

    // MARK: - Windows Symbol Lookup

    extension Windows.Loader.Symbol {
        /// Looks up a symbol in a loaded library.
        ///
        /// Retrieves the address of an exported function or variable from the
        /// specified dynamic-link library (DLL).
        ///
        /// - Parameters:
        ///   - name: The name of the symbol to look up.
        ///   - scope: The scope to search in.
        /// - Returns: Pointer to the symbol.
        /// - Throws: `Loader.Error.symbol` if the symbol is not found.
        ///
        /// ## Pointer Lifetime
        ///
        /// The returned pointer is valid only while the owning library remains loaded.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let handle = try Windows.Loader.Library.open(path: "user32.dll")
        /// let msgBox = try Windows.Loader.Symbol.lookup(name: "MessageBoxW", in: .handle(handle))
        /// typealias MessageBoxFn = @convention(c) (HWND?, LPCWSTR, LPCWSTR, UINT) -> Int32
        /// let fn = unsafeBitCast(msgBox, to: MessageBoxFn.self)
        /// ```
        @unsafe
        public static func lookup(
            name: String,
            in scope: Loader.Symbol.Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {
            let procAddress: FARPROC?

            switch unsafe scope {
            case .handle(let handle):
                procAddress = name.withCString { namePtr in
                    unsafe GetProcAddress(handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self), namePtr)
                }

            case .default:
                // Windows doesn't have RTLD_DEFAULT equivalent.
                // Search in main executable first, then loaded modules.
                if let mainHandle = Windows.Loader.Library.getHandle(moduleName: nil) {
                    procAddress = name.withCString { namePtr in
                        unsafe GetProcAddress(mainHandle.rawValue.assumingMemoryBound(to: HINSTANCE__.self), namePtr)
                    }
                } else {
                    procAddress = nil
                }

            case .next:
                // Windows doesn't have RTLD_NEXT equivalent.
                // This is not directly supported on Windows.
                throw .symbol(Loader.Message(ascii: "RTLD_NEXT equivalent not available on Windows"))
            }

            guard let procAddress else {
                throw .symbol(captureLastErrorMessage())
            }

            return unsafe unsafeBitCast(procAddress, to: UnsafeRawPointer.self)
        }

        /// Looks up a symbol by ordinal in a loaded library.
        ///
        /// - Parameters:
        ///   - ordinal: The ordinal value of the export.
        ///   - handle: The library handle to search in.
        /// - Returns: Pointer to the symbol.
        /// - Throws: `Loader.Error.symbol` if the symbol is not found.
        @unsafe
        public static func lookup(
            ordinal: UInt16,
            in handle: Loader.Library.Handle
        ) throws(Loader.Error) -> UnsafeRawPointer {
            // MAKEINTRESOURCEA converts ordinal to a pseudo-pointer
            let namePtr = UnsafePointer<CChar>(bitPattern: UInt(ordinal))
            let procAddress = unsafe GetProcAddress(handle.rawValue.assumingMemoryBound(to: HINSTANCE__.self), namePtr)

            guard let procAddress else {
                throw .symbol(captureLastErrorMessage())
            }

            return unsafe unsafeBitCast(procAddress, to: UnsafeRawPointer.self)
        }
    }

#endif
