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

public import Clock_Primitives
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

// MARK: - Clock.Continuous Windows Implementation

extension Clock.Continuous: _Concurrency.Clock {
    /// The current instant according to the continuous clock.
    ///
    /// Uses `Kernel.Clock.Continuous.now()` which wraps
    /// `QueryPerformanceCounter` on Windows.
    public var now: Instant {
        Instant(nanoseconds: Kernel.Clock.Continuous.now())
    }

    /// The current instant according to the continuous clock (static convenience).
    public static var now: Instant { Self().now }

    /// Suspends until the given deadline, checking for cancellation.
    nonisolated(nonsending)
    public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        let target = deadline.nanoseconds
        while Kernel.Clock.Continuous.now() < target {
            try Task.checkCancellation()
            try await Task.sleep(for: .nanoseconds(1_000_000))
        }
    }
}

// MARK: - Clock.Suspending Windows Implementation

extension Clock.Suspending: _Concurrency.Clock {
    /// The current instant according to the suspending clock.
    ///
    /// Uses `Kernel.Clock.Suspending.now()` which wraps
    /// `QueryUnbiasedInterruptTime` on Windows.
    public var now: Instant {
        Instant(nanoseconds: Kernel.Clock.Suspending.now())
    }

    /// The current instant according to the suspending clock (static convenience).
    public static var now: Instant { Self().now }

    /// Suspends until the given deadline, checking for cancellation.
    nonisolated(nonsending)
    public func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
        let target = deadline.nanoseconds
        while Kernel.Clock.Suspending.now() < target {
            try Task.checkCancellation()
            try await Task.sleep(for: .nanoseconds(1_000_000))
        }
    }
}

#endif
