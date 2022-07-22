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
        
         // Be careful on switching Lock package from github-based to local development repo in the PackageRouter
         // in certain situation you may want to change path to Auth0 package here too to avoid multiple packaging
         // usage
         .package(name: "Auth0", url: "https://github.com/Formelife/Auth0.swift", .branch("master")), // .upToNextMajor(from: "1.31.0")),
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
