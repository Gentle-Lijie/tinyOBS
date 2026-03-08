// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tinyOBS",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "tinyOBS",
            targets: ["tinyOBS"]
        )
    ],
    targets: [
        .executableTarget(
            name: "tinyOBS",
            path: "tinyOBS"
        )
    ]
)
