// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "Storage", targets: ["Contracts", "Store"]),
    ],
    targets: [
        .target(
            name: "Contracts",
            path: "./Contracts"
        ),
        .target(
            name: "Store",
            dependencies: ["Contracts"],
            path: "./Store"
        ),
    ]
)
