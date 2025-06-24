// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LMS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "LMS",
            targets: ["LMS"]),
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        
        // Keychain
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
        
        // Testing
        .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "LMS",
            dependencies: [
                "Alamofire",
                "KeychainAccess"
            ]),
        .testTarget(
            name: "LMSTests",
            dependencies: [
                "LMS",
                "ViewInspector"
            ]),
    ]
) 