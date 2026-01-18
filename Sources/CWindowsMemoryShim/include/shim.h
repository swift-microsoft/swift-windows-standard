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

#ifndef CWINDOWS_MEMORY_SHIM_H
#define CWINDOWS_MEMORY_SHIM_H

#if defined(_WIN32)

#include <windows.h>

/// Memory statistics structure for Windows.
typedef struct {
    SIZE_T allocations;
    SIZE_T deallocations;
    SIZE_T bytes_allocated;
} WindowsMemoryStats;

/// Query Windows heap memory statistics.
///
/// Uses GetProcessHeaps and HeapWalk to gather memory information.
static inline WindowsMemoryStats windows_heap_statistics(void) {
    WindowsMemoryStats stats = {0, 0, 0};

    PROCESS_MEMORY_COUNTERS_EX pmc;
    if (GetProcessMemoryInfo(GetCurrentProcess(), (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
        stats.bytes_allocated = pmc.WorkingSetSize;
        stats.allocations = pmc.PageFaultCount;
    }

    return stats;
}

#endif /* _WIN32 */

#endif /* CWINDOWS_MEMORY_SHIM_H */
