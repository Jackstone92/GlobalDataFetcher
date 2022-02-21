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

// MARK: - Common
package.products.append(contentsOf: [
    .library(
        name: "StyleGuide",
        targets: ["StyleGuide"]
    ),
])

package.targets.append(contentsOf: [
    .target(
        name: "StyleGuide",
        dependencies: [
            .product(name: "RxSwift", package: "RxSwift"),
            .product(name: "RxCocoa", package: "RxSwift"),
        ]
    ),
    .testTarget(
        name: "StyleGuideTests",
        dependencies: [
            "StyleGuide",
            .product(name: "RxTest", package: "RxSwift"),
            "TestSchedulers"
        ]
    ),
])

// MARK: - Stores
package.products.append(contentsOf: [
    .library(
        name: "ResponseCodeStoreLive",
        targets: ["ResponseCodeStoreLive"]
    ),
    .library(
        name: "CounterStoreLive",
        targets: ["CounterStoreLive"]
    ),
])

package.targets.append(contentsOf: [
    .target(
        name: "Store",
        dependencies: []
    ),

    .target(
        name: "ResponseCodeStore",
        dependencies: ["Store"]
    ),
    .target(
        name: "ResponseCodeStoreLive",
        dependencies: ["ResponseCodeStore"]
    ),
    .testTarget(
        name: "ResponseCodeStoreTests",
        dependencies: ["ResponseCodeStoreLive"]
    ),

    .target(
        name: "CounterStore",
        dependencies: ["Store"]
    ),
    .target(
        name: "CounterStoreLive",
        dependencies: ["CounterStore"]
    ),
    .testTarget(
        name: "CounterStoreTests",
        dependencies: ["CounterStoreLive"]
    ),
])
