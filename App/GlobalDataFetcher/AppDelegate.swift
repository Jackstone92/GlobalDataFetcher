//
//  AppDelegate.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import UIKit
import RxSwift
import DataFetchFeature
import ContentServiceLive
import LastResponseCodeServiceLive
import CounterServiceLive
import NetworkClient
import CounterStoreLive
import ResponseCodeStoreLive
import StyleGuide

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private lazy var userDefaults = UserDefaults.standard

    private lazy var viewModel: DataFetchViewModel = .live(
        contentService: .live(using: NetworkClient()),
        counterService: .live(using: .live(using: userDefaults)),
        lastResponseCodeService: .live(using: .live(using: userDefaults)),
        mainScheduler: MainScheduler.asyncInstance
    )

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureGlobalAppearances()

        let window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = DataFetchViewController(viewModel: viewModel)
        viewController.title = "Global Data Fetcher"

        let navController = UINavigationController(rootViewController: viewController)

        window.rootViewController = navController

        self.window = window
        window.makeKeyAndVisible()

        return true
    }

    private func configureGlobalAppearances() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.brand.primaryDark]
    }
}
