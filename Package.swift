// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Lock",
    defaultLocalization: "en",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "Lock", targets: ["Lock"])
    ],
    dependencies: [
         .package(name: "Auth0", url: "https://github.com/auth0/Auth0.swift.git", .upToNextMajor(from: "1.31.0")),
         .package(name: "Quick", url: "https://github.com/Quick/Quick.git", .upToNextMajor(from: "3.0.0")),
         .package(name: "Nimble", url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.0.0")),
         .package(name: "OHHTTPStubs", url: "https://github.com/AliSoftware/OHHTTPStubs.git", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        .target(
            name: "Lock",
            dependencies: ["Auth0"],
            path: "Lock",
            exclude: ["Info.plist"],
            resources: [
                .process("Lock.xcassets"),
                .process("passwordless_country_codes.plist")
            ]),
        .testTarget(
            name: "LockTests",
            dependencies: [
                "Lock",
                "Auth0",
                "Quick",
                "Nimble",
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs")
            ],
            path: "LockTests",
            exclude: ["Info.plist"])
    ]
)
