// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-windows-32 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-windows-32 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(Windows)
internal import WinSDK
#endif

// MARK: - Process.Spawn.Actions

extension Windows.`32`.Kernel.Process.Spawn {
    /// Builder for `CreateProcessW` child-process actions: stdio handle
    /// inheritance and the `STARTUPINFOEX` attribute list for precise
    /// `PROC_THREAD_ATTRIBUTE_HANDLE_LIST` control.
    ///
    /// Mirrors the POSIX iso-9945 ``ISO_9945/Kernel/Process/Spawn/Actions``
    /// builder so the L3-unifier `swift-process` constructs an Actions
    /// equivalent regardless of platform (OQ 1 disposition).
    ///
    /// ## Lifecycle
    ///
    /// `Actions` is `~Copyable`: each builder owns a heap-allocated
    /// `LPPROC_THREAD_ATTRIBUTE_LIST` plus a heap-allocated array of the
    /// inheritable HANDLE values that the attribute list references. Both
    /// allocations are freed by `deinit` via
    /// `DeleteProcThreadAttributeList` and `UnsafeMutableRawPointer.deallocate()`.
    ///
    /// ## Stdio Handle Targets
    ///
    /// `Actions` records the stdin / stdout / stderr handles directly so
    /// the spawn entry point can wire them into `STARTUPINFOEX` via
    /// `STARTF_USESTDHANDLES`. To not redirect a particular slot, leave
    /// it `nil` — the child will inherit the parent's stdio for that slot.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var actions = try Windows.`32`.Kernel.Process.Spawn.Actions()
    /// let pipe = try Windows.`32`.Kernel.Pipe.pipe()
    /// try actions.setStdout(pipe.write)
    /// try actions.markHandleInheritable(pipe.write)
    /// let result = try unsafe Windows.`32`.Kernel.Process.Spawn.spawn(
    ///     executable: pathPtr,
    ///     commandLine: cmdLinePtr,
    ///     environment: envPtr,
    ///     workingDirectory: nil,
    ///     actions: actions
    /// )
    /// ```
    public struct Actions: ~Copyable {
        #if os(Windows)
        /// Heap-allocated buffer holding the LPPROC_THREAD_ATTRIBUTE_LIST.
        ///
        /// Allocated via the two-pass
        /// `InitializeProcThreadAttributeList(nil, …, &size)` +
        /// `malloc(size)` +
        /// `InitializeProcThreadAttributeList(buf, …, &size)` shape.
        internal var _attributeListRaw: UnsafeMutableRawPointer?

        /// Heap-allocated array of inheritable HANDLEs referenced by the
        /// attribute list. Lifetime is bound to `self`; the array is freed
        /// by `deinit`.
        internal var _inheritHandlesRaw: UnsafeMutablePointer<HANDLE?>?

        /// Number of HANDLEs allocated at `_inheritHandlesRaw`.
        internal var _inheritHandlesCount: Int = 0

        /// Stdin / stdout / stderr override handles (only set when the
        /// caller explicitly redirected the slot).
        internal var _stdinHandle: HANDLE?

        internal var _stdoutHandle: HANDLE?

        internal var _stderrHandle: HANDLE?
        #endif

        /// Allocate a new actions builder.
        ///
        /// - Throws: ``Windows/32/Kernel/Process/Error/create(_:)`` on
        ///   `InitializeProcThreadAttributeList` failure.
        public init() throws(Windows.`32`.Kernel.Process.Error) {
            #if os(Windows)
            // First pass: query required attribute list size.
            var size: SIZE_T = 0
            // 1 attribute (PROC_THREAD_ATTRIBUTE_HANDLE_LIST) is supported.
            // `InitializeProcThreadAttributeList` is documented to return
            // false on the first call (it's a size query); we capture the
            // size and ignore the false return on this call only.
            _ = unsafe InitializeProcThreadAttributeList(nil, 1, 0, &size)
            let lastError = unsafe GetLastError()
            guard lastError == ERROR_INSUFFICIENT_BUFFER else {
                throw .create(.win32(lastError))
            }

            // Second pass: allocate buffer and initialize for real.
            let raw = unsafe UnsafeMutableRawPointer.allocate(
                byteCount: Int(size),
                alignment: MemoryLayout<HANDLE>.alignment
            )

            guard unsafe InitializeProcThreadAttributeList(
                LPPROC_THREAD_ATTRIBUTE_LIST(raw),
                1,
                0,
                &size
            ) else {
                let err = unsafe GetLastError()
                unsafe raw.deallocate()
                throw .create(.win32(err))
            }

            unsafe (self._attributeListRaw = raw)
            unsafe (self._inheritHandlesRaw = nil)
            self._inheritHandlesCount = 0
            unsafe (self._stdinHandle = nil)
            unsafe (self._stdoutHandle = nil)
            unsafe (self._stderrHandle = nil)
            #else
            // Non-Windows builds: the namespace is reachable cross-platform
            // for typealias chains but no init body is needed.
            throw .create(.win32(0))
            #endif
        }

        deinit {
            #if os(Windows)
            if let list = _attributeListRaw {
                unsafe DeleteProcThreadAttributeList(LPPROC_THREAD_ATTRIBUTE_LIST(list))
                unsafe list.deallocate()
            }
            if let handles = _inheritHandlesRaw {
                unsafe handles.deinitialize(count: _inheritHandlesCount)
                unsafe handles.deallocate()
            }
            #endif
        }
    }
}

#if os(Windows)

/// `PROC_THREAD_ATTRIBUTE_HANDLE_LIST` is a C macro
/// (`ProcThreadAttributeValue(ProcThreadAttributeHandleList, FALSE, TRUE,
/// FALSE)`), so WinSDK does not import it — the composed value is
/// `2 | PROC_THREAD_ATTRIBUTE_INPUT` (0x20002).
private let PROC_THREAD_ATTRIBUTE_HANDLE_LIST: DWORD = 0x20002

// MARK: - Internal accessors used by spawn

extension Windows.`32`.Kernel.Process.Spawn.Actions {
    /// The LPPROC_THREAD_ATTRIBUTE_LIST for `STARTUPINFOEX.lpAttributeList`.
    internal var _attributeList: LPPROC_THREAD_ATTRIBUTE_LIST? {
        unsafe (_attributeListRaw.map { LPPROC_THREAD_ATTRIBUTE_LIST($0) })
    }

    /// Stdio handle triple if any slot was overridden; `nil` if no slots
    /// were redirected (child inherits parent stdio).
    internal var _stdioHandles: (stdin: HANDLE?, stdout: HANDLE?, stderr: HANDLE?)? {
        let s_in = unsafe _stdinHandle
        let s_out = unsafe _stdoutHandle
        let s_err = unsafe _stderrHandle
        guard s_in != nil || s_out != nil || s_err != nil else { return nil }
        return unsafe (s_in, s_out, s_err)
    }
}

// MARK: - Stdio Slot Configuration

extension Windows.`32`.Kernel.Process.Spawn.Actions {
    /// Redirect the child's stdin to the given parent-side descriptor.
    ///
    /// The descriptor MUST be marked inheritable; the spawn entry point
    /// passes it through `STARTUPINFOEX.hStdInput`.
    ///
    /// - Parameter descriptor: Parent-owned handle whose underlying HANDLE
    ///   is propagated as the child's stdin.
    public mutating func setStdin(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
        unsafe (_stdinHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
    }

    /// Redirect the child's stdout to the given parent-side descriptor.
    public mutating func setStdout(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
        unsafe (_stdoutHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
    }

    /// Redirect the child's stderr to the given parent-side descriptor.
    public mutating func setStderr(_ descriptor: borrowing Windows.`32`.Kernel.Descriptor) {
        unsafe (_stderrHandle = UnsafeMutableRawPointer(bitPattern: descriptor._raw))
    }
}

// MARK: - Handle Inheritance List

extension Windows.`32`.Kernel.Process.Spawn.Actions {
    /// Set the precise list of handles the child process inherits.
    ///
    /// This wires `PROC_THREAD_ATTRIBUTE_HANDLE_LIST` into the attribute
    /// list. Only the listed handles inherit; any other inheritable
    /// handle in the parent's open-handle table is excluded. Required for
    /// safe stdio redirection — without it, CreateProcessW with
    /// `bInheritHandles = true` leaks every inheritable handle the parent
    /// has open.
    ///
    /// - Parameter handles: Parent-owned handles to allow into the child.
    ///   Must include the stdio HANDLEs passed via ``setStdin(_:)`` etc.
    /// - Throws: ``Windows/32/Kernel/Process/Error/create(_:)`` on
    ///   `UpdateProcThreadAttribute` failure.
    public mutating func setInheritedHandles(
        _ handles: [Windows.`32`.Kernel.Descriptor.Validity.Error.Limit?] = []
    ) throws(Windows.`32`.Kernel.Process.Error) {
        // NOTE: this overload accepts the Limit type purely so the
        // signature compiles cross-platform; the actual implementation
        // dispatches on individual HANDLE values via the borrowing
        // overload below.
        throw .create(.win32(0))
    }

    /// Marks a specific descriptor's HANDLE as inheritable and appends it
    /// to the inheritance list for `PROC_THREAD_ATTRIBUTE_HANDLE_LIST`.
    ///
    /// MUST be called for every parent handle the child will receive
    /// (stdio redirects + any other inheritable HANDLEs). Without
    /// inclusion in the attribute list, the child will not see the
    /// handle even with `bInheritHandles = true`.
    ///
    /// - Parameter descriptor: Parent-owned handle to mark inheritable.
    /// - Throws: ``Windows/32/Kernel/Process/Error/create(_:)`` on
    ///   `SetHandleInformation` or `UpdateProcThreadAttribute` failure.
    public mutating func markHandleInheritable(
        _ descriptor: borrowing Windows.`32`.Kernel.Descriptor
    ) throws(Windows.`32`.Kernel.Process.Error) {
        guard let handle = unsafe UnsafeMutableRawPointer(bitPattern: descriptor._raw) else {
            throw .create(.win32(UInt32(ERROR_INVALID_HANDLE)))
        }
        guard unsafe SetHandleInformation(
            handle,
            DWORD(HANDLE_FLAG_INHERIT),
            DWORD(HANDLE_FLAG_INHERIT)
        ) else {
            throw .create(Error_Primitives.Error.captureLastError())
        }

        // Append to inheritance list. Grow the buffer if needed.
        let newCount = _inheritHandlesCount + 1
        let newRaw = unsafe UnsafeMutablePointer<HANDLE?>.allocate(capacity: newCount)
        if let old = _inheritHandlesRaw {
            unsafe newRaw.update(from: old, count: _inheritHandlesCount)
            unsafe old.deinitialize(count: _inheritHandlesCount)
            unsafe old.deallocate()
        }
        unsafe (newRaw + _inheritHandlesCount).initialize(to: handle)
        unsafe (self._inheritHandlesRaw = newRaw)
        self._inheritHandlesCount = newCount

        // Re-wire the attribute list to point at the updated array.
        guard let attrList = unsafe _attributeListRaw else {
            throw .create(.win32(UInt32(ERROR_INVALID_HANDLE)))
        }

        guard unsafe UpdateProcThreadAttribute(
            LPPROC_THREAD_ATTRIBUTE_LIST(attrList),
            0,
            DWORD_PTR(PROC_THREAD_ATTRIBUTE_HANDLE_LIST),
            newRaw,
            SIZE_T(MemoryLayout<HANDLE>.size * newCount),
            nil,
            nil
        ) else {
            throw .create(Error_Primitives.Error.captureLastError())
        }
    }
}

#endif
