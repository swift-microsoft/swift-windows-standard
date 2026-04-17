// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-windows-standard",
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
            name: "Windows Kernel Standard",
            targets: ["Windows Kernel Standard"]
        ),
        .library(
            name: "Windows Kernel Clock Standard",
            targets: ["Windows Kernel Clock Standard"]
        ),
        .library(
            name: "Windows Kernel Console Standard",
            targets: ["Windows Kernel Console Standard"]
        ),
        .library(
            name: "Windows Kernel Directory Standard",
            targets: ["Windows Kernel Directory Standard"]
        ),
        .library(
            name: "Windows Kernel Environment Standard",
            targets: ["Windows Kernel Environment Standard"]
        ),
        .library(
            name: "Windows Kernel File Standard",
            targets: ["Windows Kernel File Standard"]
        ),
        .library(
            name: "Windows Kernel IO Standard",
            targets: ["Windows Kernel IO Standard"]
        ),
        .library(
            name: "Windows Kernel Memory Map Standard",
            targets: ["Windows Kernel Memory Map Standard"]
        ),
        .library(
            name: "Windows Kernel Process Standard",
            targets: ["Windows Kernel Process Standard"]
        ),
        .library(
            name: "Windows Kernel Socket Standard",
            targets: ["Windows Kernel Socket Standard"]
        ),
        .library(
            name: "Windows Kernel System Standard",
            targets: ["Windows Kernel System Standard"]
        ),
        .library(
            name: "Windows Kernel Thread Standard",
            targets: ["Windows Kernel Thread Standard"]
        ),
        .library(
            name: "Windows Kernel Time Standard",
            targets: ["Windows Kernel Time Standard"]
        ),
        // MARK: - Other
        .library(
            name: "Windows Identity Standard",
            targets: ["Windows Identity Standard"]
        ),
        .library(
            name: "Windows Interop Standard",
            targets: ["Windows Interop Standard"]
        ),
        .library(
            name: "Windows Loader Standard",
            targets: ["Windows Loader Standard"]
        ),
        .library(
            name: "Windows Memory Standard",
            targets: ["Windows Memory Standard"]
        ),
        // MARK: - Test Support
        .library(
            name: "Windows Kernel Standard Test Support",
            targets: ["Windows Kernel Standard Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-clock-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-sequence-primitives"),
        // SDG(wraps): Windows syscalls wrap GetLastError
        // .package(path: "../swift-error-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Windows Standard Core",
            dependencies: []
        ),
        .target(
            name: "CWindowsMemoryShim",
            dependencies: []
        ),

        // MARK: - Kernel Core
        .target(
            name: "Windows Kernel Standard Core",
            dependencies: [
                .target(name: "Windows Standard Core"),
                .product(name: "Kernel Primitives Core", package: "swift-kernel-primitives"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Clock
        .target(
            name: "Windows Kernel Clock Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Clock Primitives", package: "swift-kernel-primitives"),
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
            ]
        ),

        // MARK: - Kernel Console
        .target(
            name: "Windows Kernel Console Standard",
            dependencies: [
                "Windows Kernel Standard Core",
            ]
        ),

        // MARK: - Kernel Directory
        .target(
            name: "Windows Kernel Directory Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Environment
        .target(
            name: "Windows Kernel Environment Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Environment Primitives", package: "swift-kernel-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),

        // MARK: - Kernel File
        .target(
            name: "Windows Kernel File Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Path Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel IO
        .target(
            name: "Windows Kernel IO Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel IO Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Memory Map
        .target(
            name: "Windows Kernel Memory Map Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Memory Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Process
        .target(
            name: "Windows Kernel Process Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Process Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Socket
        .target(
            name: "Windows Kernel Socket Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Socket Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel System
        .target(
            name: "Windows Kernel System Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel System Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Thread
        .target(
            name: "Windows Kernel Thread Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Time
        .target(
            name: "Windows Kernel Time Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                .product(name: "Kernel Time Primitives", package: "swift-kernel-primitives"),
            ]
        ),

        // MARK: - Kernel Umbrella
        .target(
            name: "Windows Kernel Standard",
            dependencies: [
                "Windows Kernel Standard Core",
                "Windows Kernel Clock Standard",
                "Windows Kernel Console Standard",
                "Windows Kernel Directory Standard",
                "Windows Kernel Environment Standard",
                "Windows Kernel File Standard",
                "Windows Kernel IO Standard",
                "Windows Kernel Memory Map Standard",
                "Windows Kernel Process Standard",
                "Windows Kernel Socket Standard",
                "Windows Kernel System Standard",
                "Windows Kernel Thread Standard",
                "Windows Kernel Time Standard",
            ]
        ),

        // MARK: - Identity
        .target(
            name: "Windows Identity Standard",
            dependencies: [
                .target(name: "Windows Standard Core"),
            ]
        ),

        // MARK: - Interop
        .target(
            name: "Windows Interop Standard",
            dependencies: [
                .target(name: "Windows Standard Core"),
            ]
        ),

        // MARK: - Loader
        .target(
            name: "Windows Loader Standard",
            dependencies: [
                .target(name: "Windows Standard Core"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),

        // MARK: - Memory
        .target(
            name: "Windows Memory Standard",
            dependencies: [
                .target(name: "Windows Standard Core"),
                .target(name: "CWindowsMemoryShim", condition: .when(platforms: [.windows]))
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Windows Kernel Standard Test Support",
            dependencies: [
                "Windows Kernel Standard",
                "Windows Loader Standard",
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Windows Kernel Standard Tests",
            dependencies: [
                "Windows Kernel Standard",
                "Windows Kernel Standard Test Support",
            ]
        ),
        .testTarget(
            name: "Windows Loader Standard Tests",
            dependencies: [
                "Windows Loader Standard",
                "Windows Kernel Standard Test Support",
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
