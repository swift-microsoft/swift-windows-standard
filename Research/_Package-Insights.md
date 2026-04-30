# Windows Standard Insights

<!--
---
title: Windows Standard Insights
version: 1.0.0
last_updated: 2026-04-30
applies_to: [swift-windows-standard]
normative: false
---
-->

Design decisions, implementation patterns, and lessons learned specific to this package.

## Overview

This document captures insights that emerged during development of `swift-windows-standard`. These are not API requirements — they are recorded decisions and patterns that inform future work on this package.

**Document type**: Non-normative (recorded decisions, not requirements).

**Consolidation source**: Reflection entries tagged with `[package: swift-windows-standard]`.

---

## Kernel.Thread.Local lacks per-thread cleanup on Windows

**Date**: 2026-04-30

**Context**: A 2026-04-26 cycle promoted `Kernel.Thread.Local` from an untyped slot to a generic class `Kernel.Thread.Local<Payload: AnyObject>` (per [PLAT-ARCH-008f] solution (a) rename of L2 `Local` → `Key` / `Index`). The L3 wrapper installs a destructor on POSIX so the kernel auto-releases retained payloads on thread exit; the Windows path leaves the slot uncleaned because `TlsAlloc` lacks a destructor mechanism.

`Windows.Kernel.Thread.Index` (the Win32 `DWORD`-based TLS index, mirroring Win32 "TLS index" terminology) currently exposes only the basic `TlsAlloc` / `TlsSetValue` / `TlsGetValue` / `TlsFree` API surface. The L3 `Kernel.Thread.Local<Payload>` wraps `TlsAlloc` on Windows and stores `Unmanaged.passRetained(payload).toOpaque()` into the slot; the matching `Unmanaged<AnyObject>.release()` call that POSIX wires through `pthread_key_create`'s destructor parameter does NOT occur on Windows on thread exit.

**Implication for consumers**:

A short-lived thread that retains a payload in a `Kernel.Thread.Local<Payload>` slot leaks the retained object on thread exit. The leak does not surface during process termination (the OS reclaims the process), but does surface in:

- Long-running processes that spawn many short-lived threads (worker pools, request handlers).
- Test suites that create and discard threads to exercise per-thread state.
- Services where thread lifecycle is decoupled from process lifecycle.

The leak is one retained-object reference per `(thread × Local-slot)` pair.

**Future work**:

Wire `FlsAlloc` / `FlsSetCallback` / `FlsFree` (Fiber-Local Storage with destructor support) for symmetric per-thread cleanup. Despite the "Fiber-Local" name, FLS works on regular threads and supports the destructor callback mechanism that TLS lacks. The migration is a contained API surface change in `Windows.Kernel.Thread.Index`'s wrapper init; no consumer change is required because `Kernel.Thread.Local<Payload>`'s public surface stays identical.

The trigger for the future work: any short-lived-thread use of `Kernel.Thread.Local` on Windows that surfaces the leak in production.

**Applies to**: `Windows.Kernel.Thread.Index` (this package); cross-references `swift-foundations/swift-kernel`'s L3 `Kernel.Thread.Local<Payload: AnyObject>` wrapper.
