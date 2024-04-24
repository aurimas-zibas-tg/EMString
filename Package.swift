// swift-tools-version: 5.7.1

import PackageDescription

let package = Package(
    name: "EMString",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "EMString",
            targets: ["EMString"]
        ),
    ],
    targets: [
        .target(
            name: "EMString"
        )
    ]
)
