// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Randomizer",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        .executableTarget(
            name: "Randomizer",
            path: "Sources/Randomizer",
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
