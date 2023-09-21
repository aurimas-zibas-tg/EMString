// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "EMString",
    products: [
        .library(
            name: "EMString",
            targets: ["EMString"]
        ),
    ],
    targets: [
        .target(
            name: "EMString",
            path: "EMString",
            publicHeadersPath: "include"
        )
    ]
)
