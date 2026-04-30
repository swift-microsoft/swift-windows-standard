// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-windows-32",
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
            name: "Windows 32 Kernel",
            targets: ["Windows 32 Kernel"]
        ),
        .library(
            name: "Windows 32 Kernel Clock",
            targets: ["Windows 32 Kernel Clock"]
        ),
        .library(
            name: "Windows 32 Kernel Console",
            targets: ["Windows 32 Kernel Console"]
        ),
        .library(
            name: "Windows 32 Kernel Directory",
            targets: ["Windows 32 Kernel Directory"]
        ),
        .library(
            name: "Windows 32 Kernel Environment",
            targets: ["Windows 32 Kernel Environment"]
        ),
        .library(
            name: "Windows 32 Kernel File",
            targets: ["Windows 32 Kernel File"]
        ),
        .library(
            name: "Windows 32 Kernel IO",
            targets: ["Windows 32 Kernel IO"]
        ),
        .library(
            name: "Windows 32 Kernel Memory Map",
            targets: ["Windows 32 Kernel Memory Map"]
        ),
        .library(
            name: "Windows 32 Kernel Process",
            targets: ["Windows 32 Kernel Process"]
        ),
        .library(
            name: "Windows 32 Kernel Socket",
            targets: ["Windows 32 Kernel Socket"]
        ),
        .library(
            name: "Windows 32 Kernel System",
            targets: ["Windows 32 Kernel System"]
        ),
        .library(
            name: "Windows 32 Kernel Thread",
            targets: ["Windows 32 Kernel Thread"]
        ),
        .library(
            name: "Windows 32 Kernel Time",
            targets: ["Windows 32 Kernel Time"]
        ),
        // MARK: - Other
        .library(
            name: "Windows 32 Identity",
            targets: ["Windows 32 Identity"]
        ),
        .library(
            name: "Windows 32 Interop",
            targets: ["Windows 32 Interop"]
        ),
        .library(
            name: "Windows 32 Loader",
            targets: ["Windows 32 Loader"]
        ),
        .library(
            name: "Windows 32 Memory",
            targets: ["Windows 32 Memory"]
        ),
        // MARK: - Test Support
        .library(
            name: "Windows 32 Kernel Test Support",
            targets: ["Windows 32 Kernel Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-memory-primitives"),
        .package(path: "../../swift-primitives/swift-clock-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-sequence-primitives"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-error-primitives"),
        .package(path: "../../swift-primitives/swift-random-primitives"),
        .package(path: "../../swift-primitives/swift-path-primitives"),
        .package(path: "../../swift-primitives/swift-system-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Windows 32 Core",
            dependencies: []
        ),
        .target(
            name: "CWindowsMemoryShim",
            dependencies: []
        ),

        // MARK: - Kernel Core
        .target(
            name: "Windows 32 Kernel Core",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),

        // MARK: - Kernel Clock
        .target(
            name: "Windows 32 Kernel Clock",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Clock Primitives", package: "swift-clock-primitives"),
            ]
        ),

        // MARK: - Kernel Console
        .target(
            name: "Windows 32 Kernel Console",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel Directory
        .target(
            name: "Windows 32 Kernel Directory",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),

        // MARK: - Kernel Environment
        .target(
            name: "Windows 32 Kernel Environment",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),

        // MARK: - Kernel File
        .target(
            name: "Windows 32 Kernel File",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Path Primitives", package: "swift-path-primitives"),
            ]
        ),

        // MARK: - Kernel IO
        .target(
            name: "Windows 32 Kernel IO",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel Memory Map
        .target(
            name: "Windows 32 Kernel Memory Map",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "Memory Primitives", package: "swift-memory-primitives"),
            ]
        ),

        // MARK: - Kernel Process
        .target(
            name: "Windows 32 Kernel Process",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel Socket
        .target(
            name: "Windows 32 Kernel Socket",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel System
        .target(
            name: "Windows 32 Kernel System",
            dependencies: [
                "Windows 32 Kernel Core",
                .product(name: "System Primitives", package: "swift-system-primitives"),
                .product(name: "Random Primitives", package: "swift-random-primitives"),
            ]
        ),

        // MARK: - Kernel Thread
        .target(
            name: "Windows 32 Kernel Thread",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel Time
        .target(
            name: "Windows 32 Kernel Time",
            dependencies: [
                "Windows 32 Kernel Core",
            ]
        ),

        // MARK: - Kernel Umbrella
        .target(
            name: "Windows 32 Kernel",
            dependencies: [
                "Windows 32 Kernel Core",
                "Windows 32 Kernel Clock",
                "Windows 32 Kernel Console",
                "Windows 32 Kernel Directory",
                "Windows 32 Kernel Environment",
                "Windows 32 Kernel File",
                "Windows 32 Kernel IO",
                "Windows 32 Kernel Memory Map",
                "Windows 32 Kernel Process",
                "Windows 32 Kernel Socket",
                "Windows 32 Kernel System",
                "Windows 32 Kernel Thread",
                "Windows 32 Kernel Time",
            ]
        ),

        // MARK: - Identity
        .target(
            name: "Windows 32 Identity",
            dependencies: [
                .target(name: "Windows 32 Core"),
            ]
        ),

        // MARK: - Interop
        .target(
            name: "Windows 32 Interop",
            dependencies: [
                .target(name: "Windows 32 Core"),
            ]
        ),

        // MARK: - Loader
        .target(
            name: "Windows 32 Loader",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives")
            ]
        ),

        // MARK: - Memory
        .target(
            name: "Windows 32 Memory",
            dependencies: [
                .target(name: "Windows 32 Core"),
                .target(name: "CWindowsMemoryShim", condition: .when(platforms: [.windows]))
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Windows 32 Kernel Test Support",
            dependencies: [
                "Windows 32 Kernel",
                "Windows 32 Loader",
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Windows 32 Kernel Tests",
            dependencies: [
                "Windows 32 Kernel",
                "Windows 32 Kernel Test Support",
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
            ]
        ),
        .testTarget(
            name: "Windows 32 Loader Tests",
            dependencies: [
                "Windows 32 Loader",
                "Windows 32 Kernel Test Support",
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
