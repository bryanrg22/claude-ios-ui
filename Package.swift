// swift-tools-version: 6.2
import PackageDescription
let package = Package(
    name: "ClaudeUI", platforms: [.iOS(.v26), .macOS(.v14)],
    products: [
        .library(name: "ClaudeUI", targets: ["ClaudeUI"]), .library(name: "ClaudeWidgets", targets: ["ClaudeWidgets"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", exact: "0.9.0"),
        .package(url: "https://github.com/smittytone/HighlighterSwift.git", exact: "3.1.0")
    ],
    targets: [
        .target(
            name: "ClaudeUI",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Highlighter", package: "HighlighterSwift")
            ], resources: [.process("Resources")]), .target(name: "ClaudeWidgets", resources: [.process("Resources")]),
        .testTarget(name: "ClaudeUITests", dependencies: ["ClaudeUI", "ClaudeWidgets"])
    ])
