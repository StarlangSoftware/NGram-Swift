// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NGram",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "NGram",
            targets: ["NGram"]),
    ],
    dependencies: [
        .package(name: "Math", url: "https://github.com/StarlangSoftware/Math-Swift.git", .exact("1.0.12")),
        .package(name: "DataStructure", url: "https://github.com/StarlangSoftware/DataStructure-Swift.git", .exact("1.0.4")),
        .package(name: "Sampling", url: "https://github.com/StarlangSoftware/Sampling-Swift.git", .exact("1.0.7")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "NGram",
            dependencies: ["Sampling", "Math", "DataStructure"],
            resources: [.process("simple1a.txt"),.process("simple1b.txt"),.process("simple2a.txt"),.process("simple2b.txt"),.process("simple2c.txt"),.process("simple2d.txt"),.process("simple3a.txt"),.process("simple3b.txt"),.process("simple3c.txt")]
        ),
        .testTarget(
            name: "NGramTests",
            dependencies: ["NGram"]),
    ]
)
