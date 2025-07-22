// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LMS",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "LMS",
            targets: ["LMS"]),
    ],
    dependencies: [
        // No external dependencies for now
    ],
    targets: [
        .target(
            name: "LMS",
            dependencies: [],
            path: "LMS"
        ),
        .testTarget(
            name: "LMSTests",
            dependencies: ["LMS"],
            path: "LMSTests"
        ),
    ]
) 