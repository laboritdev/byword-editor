// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LabWord",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "LabWord", targets: ["LabWord"]),
        .library(name: "LabWordCore", targets: ["LabWordCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.11.0"),
    ],
    targets: [
        .target(
            name: "LabWordCore",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "Sources"
        ),
        .executableTarget(
            name: "LabWord",
            dependencies: ["LabWordCore"],
            path: "Entry",
            sources: ["Entry.swift"]
        ),
        .testTarget(
            name: "LabWordTests",
            dependencies: [
                "LabWordCore",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests"
        ),
    ]
)
