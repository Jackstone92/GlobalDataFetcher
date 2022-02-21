//
//  AsyncButtonTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import TestSchedulers
@testable import StyleGuide

final class AsyncButtonTests: XCTestCase {

    private var sut: AsyncButton!
    private let scheduler = ImmediateScheduler.instance
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        sut = AsyncButton(
            title: "Test",
            action: { $0() },
            mainScheduler: scheduler,
            frame: CGRect(x: 0, y: 0, width: 88, height: 44)
        )

        disposeBag = DisposeBag()
    }

    // MARK: - init tests
    func test_initialisesButtonTitle() {

        let title = "Button Title"

        sut = AsyncButton(title: title, action: { $0() })

        XCTAssertEqual(sut.viewModel.title, title)
    }

    func test_initialisesButtonAction() {

        var actionInvocationCount = 0
        var completionInvocationCount = 0

        let completion: AsyncButtonCompletion = {
            completionInvocationCount += 1
        }

        let action: AsyncButtonAction = { completion in
            actionInvocationCount += 1
            completion()
        }

        sut = AsyncButton(title: "", action: action)

        XCTAssertEqual(actionInvocationCount, 0)
        XCTAssertEqual(completionInvocationCount, 0)

        sut.viewModel.action(completion)

        XCTAssertEqual(actionInvocationCount, 1)
        XCTAssertEqual(completionInvocationCount, 1)
    }

    func test_initialisesIsLoading() {

        sut = AsyncButton(title: "", action: { $0() }, isLoading: true)

        XCTAssertTrue(try sut.viewModel.isLoadingSubject.value())
    }

    func test_defaultIsLoading() {

        sut = AsyncButton(title: "", action: { $0() })

        XCTAssertFalse(try sut.viewModel.isLoadingSubject.value())
    }

    // MARK: - isHighlighted tests
    func test_backgroundColorWhenIsHighlightedIsTrue() {

        sut.isHighlighted = true

        XCTAssertEqual(sut.backgroundColor, .brand.primaryDark)
    }

    func test_backgroundColorWhenIsHighlightedIsFalse() {

        sut.isHighlighted = false

        XCTAssertEqual(sut.backgroundColor, .brand.primaryBase)
    }

    // MARK: - style tests
    func test_buttonContentAlphaWhenLoading() {

        sut.viewModel.isLoadingSubject.onNext(true)

        XCTAssertEqual(sut.titleLabel?.alpha, 0)
        XCTAssertEqual(sut.imageView?.alpha, 0)
    }

    func test_buttonContentAlphaWhenNotLoading() {

        sut.viewModel.isLoadingSubject.onNext(false)

        XCTAssertEqual(sut.titleLabel?.alpha, 1)
        XCTAssertEqual(sut.imageView?.alpha, 1)
    }

    func test_activityIndicatorWhenLoading() {

        sut.viewModel.isLoadingSubject.onNext(true)

        XCTAssertFalse(sut.activityIndicator.isHidden)
        XCTAssertTrue(sut.activityIndicator.isAnimating)
    }

    func test_activityIndicatorWhenNotLoading() {

        sut.viewModel.isLoadingSubject.onNext(false)

        XCTAssertTrue(sut.activityIndicator.isHidden)
        XCTAssertFalse(sut.activityIndicator.isAnimating)
    }

    // MARK: - tap tests
    func test_buttonTapInvokesViewModel() throws {

        let expectation = self.expectation(description: "Should trigger buttonTapSubject")
        expectation.assertForOverFulfill = false

        var states = [AsyncButtonViewModel.State]()

        sut.viewModel.buttonTapSubject
            .subscribe(onNext: {
                states.append($0)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        XCTAssertEqual(states, [.pending])

        // Because we are not using a host application, we need to
        // get the selector from the button manually and invoke `performSelector`.
        // If we were using a host application, we could have used `sendActions(for:)`.
        let action = try XCTUnwrap(sut.actions(forTarget: sut, forControlEvent: .touchUpInside)?.first)
        sut.performSelector(onMainThread: Selector(action), with: nil, waitUntilDone: true)

        waitForExpectations(timeout: 0.1)

        XCTAssertEqual(states, [.pending, .buttonTapped])
    }
}
