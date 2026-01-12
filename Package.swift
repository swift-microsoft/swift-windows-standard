// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-windows-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
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
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-kernel-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-test-primitives.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-testing-extras.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Windows Primitives",
            dependencies: []
        ),
        .target(
            name: "Windows Kernel Primitives",
            dependencies: [
                .target(name: "Windows Primitives"),
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
            ]
        ),
        .testTarget(
            name: "Windows Kernel Primitives Tests",
            dependencies: [
                "Windows Kernel Primitives",
                .product(name: "Kernel Primitives", package: "swift-kernel-primitives"),
                .product(name: "Test Primitives", package: "swift-test-primitives"),
                .product(name: "Testing Extras", package: "swift-testing-extras"),
            ],
            path: "Tests/Windows Kernel Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
