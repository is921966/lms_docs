// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LMS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LMS",
            targets: ["LMS"]
        )
    ],
    dependencies: [
        // ViewInspector for SwiftUI testing
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.8")
    ],
    targets: [
        .target(
            name: "LMS",
            dependencies: []
        ),
        .testTarget(
            name: "LMSTests",
            dependencies: [
                "LMS",
                .product(name: "ViewInspector", package: "ViewInspector")
            ]
        )
    ]
) 