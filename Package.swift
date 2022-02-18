// swift-tools-version:5.5

import PackageDescription

var package = Package(
    name: "GlobalDataFetcher",
    platforms: [.iOS(.v12)],
    products: [],
    dependencies: [
        .package(name: "RxSwift", url: "git@github.com:ReactiveX/RxSwift.git", .upToNextMajor(from: "6.5.0")),
        .package(name: "RxAnimated", url: "git@github.com:RxSwiftCommunity/RxAnimated.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: []
)
