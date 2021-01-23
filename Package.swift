// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "KeyboardAutoLayout",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(
            name: "KeyboardAutoLayout",
            targets: ["KeyboardAutoLayout"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KeyboardAutoLayout",
            dependencies: ["KeyboardAutoLayout-ObjC"],
            path: "Sources",
            exclude: ["KeyboardAutoLayoutLoader.m"]
        ),
        .target(
            name: "KeyboardAutoLayout-ObjC",
            dependencies: [],
            path: "Sources",
            sources: ["KeyboardAutoLayoutLoader.m"]
        ),
        .testTarget(
            name: "KeyboardAutoLayoutTests",
            dependencies: ["KeyboardAutoLayout"],
            path: "Tests",
            exclude: ["LinuxMain.swift"]
        ),
    ]
)
