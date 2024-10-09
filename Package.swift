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
    targets: [
        .target(
            name: "Collector",
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "CollectorTests",
            dependencies: ["Collector"]
        ),
    ]
)
