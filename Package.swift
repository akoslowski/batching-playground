// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Collector",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(
            name: "Collector",
            targets: ["Collector"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Collector",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "CollectorTests",
            dependencies: [
                "Collector",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
    ]
)
