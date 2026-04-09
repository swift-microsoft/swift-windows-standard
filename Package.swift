// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-windows-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Kernel
        .library(
            name: "Windows Kernel Primitives",
            targets: ["Windows Kernel Primitives"]
        ),
        .library(
            name: "Windows Kernel File Primitives",
            targets: ["Windows Kernel File Primitives"]
        ),
        .library(
            name: "Windows Kernel Socket Primitives",
            targets: ["Windows Kernel Socket Primitives"]
        ),
        .library(
            name: "Windows Kernel IO Primitives",
            targets: ["Windows Kernel IO Primitives"]
        ),
        .library(
            name: "Windows Kernel Memory Map Primitives",
            targets: ["Windows Kernel Memory Map Primitives"]
        ),
        // MARK: - Other
        .library(
            name: "Windows Loader Primitives",
            targets: ["Windows Loader Primitives"]
        ),
        .library(
            name: "Windows Memory Primitives",
            targets: ["Windows Memory Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-kernel-primitives"),
        .package(path: "../swift-clock-primitives"),
        .package(path: "../swift-loader-primitives"),
        .package(path: "../swift-sequence-primitives"),
        // SDG(wraps): Windows syscalls wrap GetLastError
        // .package(path: "../swift-error-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Windows Primitives Core",
            dependencies: []
        ),
        .target(
            name: "CWindowsMemoryShim",
            dependencies: []
        ),

        // MARK: - Kernel Core
        .target(
            name: "Windows Kernel Primitives Core",
            dependencies: [
                .target(name: "Windows Primitives Core"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Clock Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Environment Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel System Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),

        // MARK: - Kernel File
        .target(
            name: "Windows Kernel File Primitives",
            dependencies: [
                "Windows Kernel Primitives Core",
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Socket
        .target(
            name: "Windows Kernel Socket Primitives",
            dependencies: [
                "Windows Kernel Primitives Core",
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Socket Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO
        .target(
            name: "Windows Kernel IO Primitives",
            dependencies: [
                "Windows Kernel Primitives Core",
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Memory Map
        .target(
            name: "Windows Kernel Memory Map Primitives",
            dependencies: [
                "Windows Kernel Primitives Core",
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Umbrella
        .target(
            name: "Windows Kernel Primitives",
            dependencies: [
                "Windows Kernel Primitives Core",
                "Windows Kernel File Primitives",
                "Windows Kernel Socket Primitives",
                "Windows Kernel IO Primitives",
                "Windows Kernel Memory Map Primitives",
            ]
        ),
        .target(
            name: "Windows Loader Primitives",
            dependencies: [
                .target(name: "Windows Primitives Core"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),
        .target(
            name: "Windows Memory Primitives",
            dependencies: [
                .target(name: "Windows Primitives Core"),
                .target(name: "CWindowsMemoryShim", condition: .when(platforms: [.windows]))
            ]
        ),
        .testTarget(
            name: "Windows Kernel Primitives Tests",
            dependencies: [
                "Windows Kernel Primitives",
            ]
        ),
        .testTarget(
            name: "Windows Loader Primitives Tests",
            dependencies: [
                "Windows Loader Primitives",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
