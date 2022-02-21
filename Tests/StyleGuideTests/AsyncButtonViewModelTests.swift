//
//  AsyncButtonViewModelTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import StyleGuide

final class AsyncButtonViewModelTests: XCTestCase {

    private var sut: AsyncButtonViewModel!
    private var disposeBag: DisposeBag!

    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        scheduler = TestScheduler(initialClock: 0, resolution: 0.1)
        sut = AsyncButtonViewModel(title: "", action: { $0() }, mainScheduler: scheduler)
        disposeBag = DisposeBag()
    }

    // MARK: - Property tests
    func test_title() {

        sut = AsyncButtonViewModel(title: "Button Title", action: { $0() }, mainScheduler: scheduler)

        XCTAssertEqual(sut.title, "Button Title")
    }

    func test_isLoading() {

        sut = AsyncButtonViewModel(title: "", action: { $0() }, isLoading: true, mainScheduler: scheduler)

        XCTAssertTrue(try sut.isLoadingSubject.value())
    }

    func test_gracePeriodBeforeLoadingToggle() {

        XCTAssertEqual(AsyncButtonViewModel.Constants.loadingGracePeriod, .seconds(1))
    }

    func test_buttonCompletionInvokesCompletionSubject() {

        var completionSubjectInvokedCount = 0

        sut.completionSubject
            .subscribe(onNext: { completionSubjectInvokedCount += 1 })
            .disposed(by: disposeBag)

        sut.buttonCompletion()

        XCTAssertEqual(completionSubjectInvokedCount, 1)
    }

    func test_isLoadingDefaultsToFalse() {

        XCTAssertFalse(try sut.isLoadingSubject.value())
    }

    // MARK: - buttonTitleAlpha tests
    func test_buttonTitleAlphaWhenLoading() {

        var alphaValues = [Double]()

        sut.isLoadingSubject.onNext(true)

        sut.buttonTitleAlpha
            .subscribe(onNext: { alphaValues.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(alphaValues, [0])
    }

    func test_buttonTitleAlphaWhenNotLoading() {

        var alphaValues = [Double]()

        sut.isLoadingSubject.onNext(false)

        sut.buttonTitleAlpha
            .subscribe(onNext: { alphaValues.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(alphaValues, [1])
    }

    // MARK: - accessibilityLabel tests
    func test_accessibilityLabelWhenLoading() {

        var accessibilityLabels = [String]()

        sut.isLoadingSubject.onNext(true)

        sut.accessibilityLabel
            .subscribe(onNext: { accessibilityLabels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(accessibilityLabels, [sut.title + " - loading"])
    }

    func test_accessibilityWhenNotLoading() {

        var accessibilityLabels = [String]()

        sut.isLoadingSubject.onNext(false)

        sut.accessibilityLabel
            .subscribe(onNext: { accessibilityLabels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(accessibilityLabels, [sut.title])
    }

    // MARK: - onButtonTap tests
    func test_onButtonTapTriggersButtonTapSubject() {

        var states = [AsyncButtonViewModel.State]()

        sut.buttonTapSubject
            .subscribe(onNext: { states.append($0) })
            .disposed(by: disposeBag)

        sut.onButtonTap()

        XCTAssertEqual(states, [.pending, .buttonTapped])
    }

    func test_onButtonTapInvokesAction() {

        var didInvokeAction = false

        let action: AsyncButtonAction = { _ in
            didInvokeAction = true
        }

        sut.action = action
        sut.onButtonTap()

        XCTAssertFalse(didInvokeAction)

        scheduler.start()

        XCTAssertTrue(didInvokeAction)
    }

    func test_multipleOnButtonTapInvocationsOnlyInvokeActionOnce() {

        var actionInvocationCount = 0

        let action: AsyncButtonAction = { _ in
            actionInvocationCount += 1
        }

        sut.action = action
        (0..<3).forEach { _ in sut.onButtonTap() }

        XCTAssertEqual(actionInvocationCount, 0)

        scheduler.start()

        XCTAssertEqual(actionInvocationCount, 1)
    }

    func test_onButtonTapWhenCompletionInvokedDuringGracePeriod() throws {

        var didInvokeAction = false
        var buttonCompletion: AsyncButtonCompletion?

        let action: AsyncButtonAction = { completion in
            buttonCompletion = completion
            didInvokeAction = true
        }

        let isLoading = scheduler.createObserver(Bool.self)
        sut.isLoadingSubject
            .bind(to: isLoading)
            .disposed(by: disposeBag)

        sut.action = action
        scheduler.start()

        sut.onButtonTap()

        scheduler.advanceTo(2)

        XCTAssertTrue(didInvokeAction)

        scheduler.advanceTo(4) // Advance within grace period

        try XCTUnwrap(buttonCompletion)()

        scheduler.advanceTo(50)

        XCTAssertEqual(isLoading.events, [.next(0, false), .next(8, false)])
    }

    func test_onButtonTapWhenCompletionInvokedAfterGracePeriod() throws {

        var didInvokeAction = false
        var buttonCompletion: AsyncButtonCompletion?

        let action: AsyncButtonAction = { completion in
            buttonCompletion = completion
            didInvokeAction = true
        }

        let isLoading = scheduler.createObserver(Bool.self)
        sut.isLoadingSubject
            .bind(to: isLoading)
            .disposed(by: disposeBag)

        sut.action = action
        scheduler.start()

        sut.onButtonTap()

        scheduler.advanceTo(5)

        XCTAssertTrue(didInvokeAction)

        scheduler.advanceTo(20)

        try XCTUnwrap(buttonCompletion)()

        scheduler.advanceTo(50)

        XCTAssertEqual(isLoading.events, [.next(0, false), .next(13, true), .next(24, false)])
    }

    func test_invokingButtonCompletionMultipleTimes() throws {

        var buttonCompletion: AsyncButtonCompletion?

        let action: AsyncButtonAction = { completion in
            buttonCompletion = completion
        }

        let isLoading = scheduler.createObserver(Bool.self)
        sut.isLoadingSubject
            .bind(to: isLoading)
            .disposed(by: disposeBag)

        sut.action = action
        scheduler.start()

        sut.onButtonTap()

        scheduler.advanceTo(4)

        try XCTUnwrap(buttonCompletion)()

        scheduler.advanceTo(20)

        // Ensure additional button completion invocations does not
        // re-trigger `isLoading` to be toggled in any way.
        try XCTUnwrap(buttonCompletion)()

        scheduler.advanceTo(50)

        XCTAssertEqual(isLoading.events, [.next(0, false), .next(8, false)])
    }
}
