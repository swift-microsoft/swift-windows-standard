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
@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
public import WinSDK

// MARK: - Windows Console Operations

extension Windows.Kernel {
    /// Namespace for Windows console operations.
    public enum Console {}
}

// MARK: - Standard Handles

extension Windows.Kernel.Console {
    /// Returns the standard input handle.
    @inlinable
    public static func standardInput() -> HANDLE? {
        let handle = GetStdHandle(DWORD(STD_INPUT_HANDLE))
        return handle == INVALID_HANDLE_VALUE ? nil : handle
    }

    /// Returns the standard output handle.
    @inlinable
    public static func standardOutput() -> HANDLE? {
        let handle = GetStdHandle(DWORD(STD_OUTPUT_HANDLE))
        return handle == INVALID_HANDLE_VALUE ? nil : handle
    }

    /// Returns the standard error handle.
    @inlinable
    public static func standardError() -> HANDLE? {
        let handle = GetStdHandle(DWORD(STD_ERROR_HANDLE))
        return handle == INVALID_HANDLE_VALUE ? nil : handle
    }

    /// Checks if a handle refers to a console.
    ///
    /// - Parameter handle: The handle to check.
    /// - Returns: `true` if the handle is a console, `false` otherwise.
    @inlinable
    public static func isConsole(_ handle: HANDLE) -> Bool {
        var mode: DWORD = 0
        return GetConsoleMode(handle, &mode)
    }
}

// MARK: - Console Mode

extension Windows.Kernel.Console {
    /// Console input mode flags.
    public struct InputMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// Enable line input (read returns when Enter is pressed).
        public static let enableLineInput = InputMode(rawValue: DWORD(ENABLE_LINE_INPUT))

        /// Echo input characters.
        public static let enableEchoInput = InputMode(rawValue: DWORD(ENABLE_ECHO_INPUT))

        /// Enable Ctrl+C processing.
        public static let enableProcessedInput = InputMode(rawValue: DWORD(ENABLE_PROCESSED_INPUT))

        /// Enable window and mouse events.
        public static let enableWindowInput = InputMode(rawValue: DWORD(ENABLE_WINDOW_INPUT))

        /// Enable mouse events.
        public static let enableMouseInput = InputMode(rawValue: DWORD(ENABLE_MOUSE_INPUT))

        /// Enable insert mode.
        public static let enableInsertMode = InputMode(rawValue: DWORD(ENABLE_INSERT_MODE))

        /// Enable quick edit mode (mouse selection).
        public static let enableQuickEditMode = InputMode(rawValue: DWORD(ENABLE_QUICK_EDIT_MODE))

        /// Enable virtual terminal input sequences.
        public static let enableVirtualTerminalInput = InputMode(rawValue: DWORD(ENABLE_VIRTUAL_TERMINAL_INPUT))

        /// Default console input mode.
        public static let `default`: InputMode = [.enableLineInput, .enableEchoInput, .enableProcessedInput]

        /// Raw mode (no line buffering, no echo).
        public static let raw: InputMode = []
    }

    /// Console output mode flags.
    public struct OutputMode: OptionSet, Sendable {
        public let rawValue: DWORD

        public init(rawValue: DWORD) {
            self.rawValue = rawValue
        }

        /// Process control characters (\n, \t, etc.).
        public static let enableProcessedOutput = OutputMode(rawValue: DWORD(ENABLE_PROCESSED_OUTPUT))

        /// Wrap at end of line.
        public static let enableWrapAtEolOutput = OutputMode(rawValue: DWORD(ENABLE_WRAP_AT_EOL_OUTPUT))

        /// Enable virtual terminal processing (ANSI escape sequences).
        public static let enableVirtualTerminalProcessing = OutputMode(rawValue: DWORD(ENABLE_VIRTUAL_TERMINAL_PROCESSING))

        /// Disable newline auto-return.
        public static let disableNewlineAutoReturn = OutputMode(rawValue: DWORD(DISABLE_NEWLINE_AUTO_RETURN))

        /// Default console output mode.
        public static let `default`: OutputMode = [.enableProcessedOutput, .enableWrapAtEolOutput]

        /// ANSI mode (enables VT processing).
        public static let ansi: OutputMode = [.enableProcessedOutput, .enableWrapAtEolOutput, .enableVirtualTerminalProcessing]
    }

    /// Gets the current console input mode.
    ///
    /// - Parameter handle: The console input handle.
    /// - Returns: The current input mode, or `nil` if the handle is not a console.
    @inlinable
    public static func getInputMode(_ handle: HANDLE) -> InputMode? {
        var mode: DWORD = 0
        guard GetConsoleMode(handle, &mode) else { return nil }
        return InputMode(rawValue: mode)
    }

    /// Sets the console input mode.
    ///
    /// - Parameters:
    ///   - handle: The console input handle.
    ///   - mode: The input mode to set.
    /// - Returns: `true` on success, `false` on failure.
    @inlinable
    @discardableResult
    public static func setInputMode(_ handle: HANDLE, mode: InputMode) -> Bool {
        SetConsoleMode(handle, mode.rawValue)
    }

    /// Gets the current console output mode.
    ///
    /// - Parameter handle: The console output handle.
    /// - Returns: The current output mode, or `nil` if the handle is not a console.
    @inlinable
    public static func getOutputMode(_ handle: HANDLE) -> OutputMode? {
        var mode: DWORD = 0
        guard GetConsoleMode(handle, &mode) else { return nil }
        return OutputMode(rawValue: mode)
    }

    /// Sets the console output mode.
    ///
    /// - Parameters:
    ///   - handle: The console output handle.
    ///   - mode: The output mode to set.
    /// - Returns: `true` on success, `false` on failure.
    @inlinable
    @discardableResult
    public static func setOutputMode(_ handle: HANDLE, mode: OutputMode) -> Bool {
        SetConsoleMode(handle, mode.rawValue)
    }
}

// MARK: - Console Read/Write

extension Windows.Kernel.Console {
    /// Reads from the console.
    ///
    /// - Parameters:
    ///   - handle: The console input handle.
    ///   - buffer: Buffer to receive the characters.
    /// - Returns: Number of characters read, or `nil` on failure.
    @inlinable
    public static func read(
        _ handle: HANDLE,
        into buffer: UnsafeMutableBufferPointer<WCHAR>
    ) -> Int? {
        var charsRead: DWORD = 0
        guard ReadConsoleW(handle, buffer.baseAddress, DWORD(buffer.count), &charsRead, nil) else {
            return nil
        }
        return Int(charsRead)
    }

    /// Writes to the console.
    ///
    /// - Parameters:
    ///   - handle: The console output handle.
    ///   - buffer: Buffer containing the characters to write.
    /// - Returns: Number of characters written, or `nil` on failure.
    @inlinable
    public static func write(
        _ handle: HANDLE,
        from buffer: UnsafeBufferPointer<WCHAR>
    ) -> Int? {
        var charsWritten: DWORD = 0
        guard WriteConsoleW(handle, buffer.baseAddress, DWORD(buffer.count), &charsWritten, nil) else {
            return nil
        }
        return Int(charsWritten)
    }

    /// Writes a string to the console.
    ///
    /// - Parameters:
    ///   - handle: The console output handle.
    ///   - string: The string to write.
    /// - Returns: Number of characters written, or `nil` on failure.
    @inlinable
    public static func write(_ handle: HANDLE, string: String) -> Int? {
        var utf16 = Array(string.utf16)
        return utf16.withUnsafeBufferPointer { buffer in
            let wcharBuffer = UnsafeBufferPointer<WCHAR>(
                start: UnsafeRawPointer(buffer.baseAddress)?.assumingMemoryBound(to: WCHAR.self),
                count: buffer.count
            )
            return write(handle, from: wcharBuffer)
        }
    }
}

// MARK: - Console Screen Buffer

extension Windows.Kernel.Console {
    /// Console screen buffer information.
    public struct ScreenBufferInfo {
        /// Size of the screen buffer.
        public let size: (width: Int, height: Int)

        /// Current cursor position.
        public let cursorPosition: (x: Int, y: Int)

        /// Current text attributes.
        public let attributes: WORD

        /// Visible window rectangle.
        public let window: (left: Int, top: Int, right: Int, bottom: Int)

        /// Maximum window size.
        public let maxWindowSize: (width: Int, height: Int)

        init(_ info: CONSOLE_SCREEN_BUFFER_INFO) {
            self.size = (Int(info.dwSize.X), Int(info.dwSize.Y))
            self.cursorPosition = (Int(info.dwCursorPosition.X), Int(info.dwCursorPosition.Y))
            self.attributes = info.wAttributes
            self.window = (
                Int(info.srWindow.Left),
                Int(info.srWindow.Top),
                Int(info.srWindow.Right),
                Int(info.srWindow.Bottom)
            )
            self.maxWindowSize = (Int(info.dwMaximumWindowSize.X), Int(info.dwMaximumWindowSize.Y))
        }
    }

    /// Gets console screen buffer information.
    ///
    /// - Parameter handle: The console output handle.
    /// - Returns: Screen buffer info, or `nil` on failure.
    @inlinable
    public static func getScreenBufferInfo(_ handle: HANDLE) -> ScreenBufferInfo? {
        var info = CONSOLE_SCREEN_BUFFER_INFO()
        guard GetConsoleScreenBufferInfo(handle, &info) else { return nil }
        return ScreenBufferInfo(info)
    }

    /// Sets the cursor position.
    ///
    /// - Parameters:
    ///   - handle: The console output handle.
    ///   - x: Column position (0-based).
    ///   - y: Row position (0-based).
    /// - Returns: `true` on success, `false` on failure.
    @inlinable
    @discardableResult
    public static func setCursorPosition(_ handle: HANDLE, x: Int, y: Int) -> Bool {
        let coord = COORD(X: SHORT(x), Y: SHORT(y))
        return SetConsoleCursorPosition(handle, coord)
    }
}

#endif
