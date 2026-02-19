// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OneMinuteColorCore",
    products: [
        .library(name: "OneMinuteColorCore", targets: ["OneMinuteColorCore"])
    ],
    targets: [
        .target(
            name: "OneMinuteColorCore",
            path: "OneMinuteColor/Core"
        ),
        .testTarget(
            name: "OneMinuteColorCoreTests",
            dependencies: ["OneMinuteColorCore"],
            path: "Tests/OneMinuteColorCoreTests"
        )
    ]
)
