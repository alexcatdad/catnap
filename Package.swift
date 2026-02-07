// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Catnap",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Catnap",
            path: "Sources"
        ),
        .testTarget(
            name: "CatnapTests",
            dependencies: ["Catnap"],
            path: "Tests"
        )
    ]
)
