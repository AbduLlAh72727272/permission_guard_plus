// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "permission_guard",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "permission_guard", targets: ["permission_guard"]),
    ],
    targets: [
        .target(name: "permission_guard", path: "Classes")
    ]
)
