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
        .library(
            name: "Windows Primitives",
            targets: ["Windows Primitives"]
        ),
        .library(
            name: "Windows Kernel Primitives",
            targets: ["Windows Kernel Primitives"]
        ),
        .library(
            name: "Windows Loader Primitives",
            targets: ["Windows Loader Primitives"]
        ),
        .library(
            name: "Windows Memory Primitives",
            targets: ["Windows Memory Primitives"]
        )
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
        .target(
            name: "Windows Primitives",
            dependencies: []
        ),
        .target(
            name: "CWindowsMemoryShim",
            dependencies: []
        ),
        .target(
            name: "Windows Kernel Primitives",
            dependencies: [
                .target(name: "Windows Primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),
        .target(
            name: "Windows Loader Primitives",
            dependencies: [
                .target(name: "Windows Primitives"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),
        .target(
            name: "Windows Memory Primitives",
            dependencies: [
                .target(name: "Windows Primitives"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
