// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BywordEditor",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BywordEditor", targets: ["BywordEditor"]),
        .library(name: "BywordEditorCore", targets: ["BywordEditorCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.11.0"),
    ],
    targets: [
        .target(
            name: "BywordEditorCore",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
            ],
            path: "Sources"
        ),
        .executableTarget(
            name: "BywordEditor",
            dependencies: ["BywordEditorCore"],
            path: "Entry",
            sources: ["Entry.swift"]
        ),
        .testTarget(
            name: "BywordEditorTests",
            dependencies: [
                "BywordEditorCore",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests"
        ),
    ]
)
