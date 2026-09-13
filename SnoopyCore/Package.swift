// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SnoopyCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SnoopyCore", targets: ["SnoopyCore"])
    ],
    targets: [
        .target(name: "SnoopyCore"),
        .testTarget(name: "SnoopyCoreTests", dependencies: ["SnoopyCore"])
    ]
)
