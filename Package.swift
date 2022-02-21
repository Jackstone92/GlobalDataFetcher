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

// MARK: - Features
package.products.append(contentsOf: [
    .library(
        name: "DataFetchFeature",
        targets: ["DataFetchFeature"]
    )
])

package.targets.append(contentsOf: [
    .target(
        name: "DataFetchFeature",
        dependencies: [
            .product(name: "RxSwift", package: "RxSwift"),
            .product(name: "RxCocoa", package: "RxSwift"),
            .product(name: "RxAnimated", package: "RxAnimated"),
            "StyleGuide",
            "ContentService",
            "CounterService",
            "LastResponseCodeService"
        ]
    ),
    .testTarget(
        name: "DataFetchFeatureTests",
        dependencies: [
            "DataFetchFeature",
            "TestSchedulers"
        ]
    )
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

// MARK: - Clients and services
package.products.append(contentsOf: [
    .library(
        name: "NetworkClient",
        targets: ["NetworkClient"]
    ),
    .library(
        name: "ContentServiceLive",
        targets: ["ContentServiceLive"]
    ),
    .library(
        name: "CounterServiceLive",
        targets: ["CounterServiceLive"]
    ),
    .library(
        name: "LastResponseCodeServiceLive",
        targets: ["LastResponseCodeServiceLive"]
    ),
])

package.targets.append(contentsOf: [
    .target(
        name: "NetworkClient",
        dependencies: [
            .product(name: "RxSwift", package: "RxSwift"),
            .product(name: "RxCocoa", package: "RxSwift")
        ]
    ),
    .testTarget(
        name: "NetworkClientTests",
        dependencies: ["NetworkClient", "NetworkClientTestSupport"]
    ),

    .target(
        name: "ContentService",
        dependencies: [.product(name: "RxSwift", package: "RxSwift")]
    ),
    .target(
        name: "ContentServiceLive",
        dependencies: ["ContentService", "NetworkClient"]
    ),
    .testTarget(
        name: "ContentServiceTests",
        dependencies: [
            .product(name: "RxTest", package: "RxSwift"),
            "ContentServiceLive",
            "TestSchedulers",
            "NetworkClientTestSupport"
        ]
    ),

    .target(
        name: "CounterService",
        dependencies: []
    ),
    .target(
        name: "CounterServiceLive",
        dependencies: ["CounterService", "CounterStore"]
    ),
    .testTarget(
        name: "CounterServiceTests",
        dependencies: ["CounterServiceLive"]
    ),

    .target(
        name: "LastResponseCodeService",
        dependencies: []
    ),
    .target(
        name: "LastResponseCodeServiceLive",
        dependencies: [
            "LastResponseCodeService",
            "ResponseCodeStore"
        ]
    ),
    .testTarget(
        name: "LastResponseCodeServiceTests",
        dependencies: ["LastResponseCodeServiceLive"]
    ),
])

// MARK: - Test support
package.products.append(contentsOf: [
    .library(
        name: "NetworkClientTestSupport",
        targets: ["NetworkClientTestSupport"]
    )
])

package.targets.append(contentsOf: [
    .target(
        name: "NetworkClientTestSupport",
        dependencies: []
    ),
    .testTarget(
        name: "NetworkClientTestSupportTests",
        dependencies: ["NetworkClientTestSupport"]
    ),

    .target(
        name: "TestSchedulers",
        dependencies: [.product(name: "RxSwift", package: "RxSwift")]
    ),
    .testTarget(
        name: "TestSchedulersTests",
        dependencies: ["TestSchedulers"]
    )
])
