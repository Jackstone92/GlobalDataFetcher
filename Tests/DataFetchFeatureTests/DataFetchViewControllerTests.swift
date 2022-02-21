//
//  DataFetchViewControllerTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
@testable import DataFetchFeature

final class DataFetchViewControllerTests: XCTestCase {

    private var sut: DataFetchViewController!

    // MARK: - init tests
    func test_initialisesWithViewModel() {

        let viewModel: DataFetchViewModel = .noop

        sut = DataFetchViewController(viewModel: viewModel)

        XCTAssertIdentical(sut.viewModel, viewModel)
    }

    // MARK: - viewDidAppear tests
    func test_viewDidAppearInvokesViewModel() {

        var onAppearInvocationCount = 0

        let spy = DataFetchViewModel(
            responseCodeLabel: .empty(),
            timesFetchedLabel: .empty(),
            errorMessageLabel: .empty(),
            onAppear: { onAppearInvocationCount += 1 },
            fetchContent: { .empty() }
        )

        sut = DataFetchViewController(viewModel: spy)

        XCTAssertEqual(onAppearInvocationCount, 0)

        sut.loadViewIfNeeded()
        sut.viewDidAppear(false)

        XCTAssertEqual(onAppearInvocationCount, 1)
    }

    // MARK: - fetchContentButton
    func test_fetchContentButtonActionInvokesViewModel() throws {

        let expectation = self.expectation(description: "Should invoke fetchContent")
        expectation.assertForOverFulfill = false

        var fetchContentInvocationCount = 0

        let spy = DataFetchViewModel(
            responseCodeLabel: .empty(),
            timesFetchedLabel: .empty(),
            errorMessageLabel: .empty(),
            onAppear: {},
            fetchContent: {
                fetchContentInvocationCount += 1
                expectation.fulfill()
                return .just(())
            }
        )

        sut = DataFetchViewController(viewModel: spy)
        sut.loadViewIfNeeded()

        XCTAssertEqual(fetchContentInvocationCount, 0)

        // Because we are not using a host application, we need to
        // get the selector from the button manually and invoke `performSelector`.
        // If we were using a host application, we could have used `sendActions(for:)`.
        let action = try XCTUnwrap(
            sut.fetchContentButton
                .actions(
                    forTarget: sut.fetchContentButton,
                    forControlEvent: .touchUpInside
                )?
                .first
        )
        sut.fetchContentButton.performSelector(onMainThread: Selector(action), with: nil, waitUntilDone: true)

        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(fetchContentInvocationCount, 1)
    }
}

// MARK: - Test helpers
private extension DataFetchViewModel {

    static var noop: Self {
        Self(
            responseCodeLabel: .empty(),
            timesFetchedLabel: .empty(),
            errorMessageLabel: .empty(),
            onAppear: {},
            fetchContent: { .empty() }
        )
    }
}
