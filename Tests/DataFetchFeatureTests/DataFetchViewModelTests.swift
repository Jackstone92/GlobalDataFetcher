//
//  DataFetchViewModelTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import DataFetchFeature
import ContentService
import CounterService
import LastResponseCodeService
import TestSchedulers

final class DataFetchViewModelTests: XCTestCase {

    private var sut: DataFetchViewModel!

    private var stateSubject: BehaviorSubject<State>!
    private var disposeBag: DisposeBag!

    private let scheduler = ImmediateScheduler.instance

    override func setUp() {
        super.setUp()

        stateSubject = .init(value: State())
        disposeBag = DisposeBag()
    }

    // MARK: - responseCodeLabel tests
    func test_responseCodeLabelWhenResponseCodeIsNil() {

        var labels = [String?]()

        sut = .live(
            contentService: .notInvoked,
            counterService: .notInvoked,
            lastResponseCodeService: .notInvoked,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(responseCode: nil))

        XCTAssertTrue(labels.isEmpty)

        sut.responseCodeLabel
            .subscribe(onNext: { labels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(labels, [nil])
    }

    func test_responseCodeLabelWhenResponseCodeIsNotNil() {

        let code = UUID()
        var labels = [String?]()

        sut = .live(
            contentService: .notInvoked,
            counterService: .notInvoked,
            lastResponseCodeService: .notInvoked,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(responseCode: code))

        XCTAssertTrue(labels.isEmpty)

        sut.responseCodeLabel
            .subscribe(onNext: { labels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(labels, ["\(code.uuidString)"])
    }

    // MARK: - timesFetchedLabel tests
    func test_timesFetchedLabel() {

        var labels = [String]()

        sut = .live(
            contentService: .notInvoked,
            counterService: .notInvoked,
            lastResponseCodeService: .notInvoked,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(timesFetched: 999))

        XCTAssertTrue(labels.isEmpty)

        sut.timesFetchedLabel
            .subscribe(onNext: { labels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(labels, ["999"])
    }

    // MARK: - errorMessageLabel tests
    func test_errorMessageLabelWhenNil() {

        var labels = [String?]()

        sut = .live(
            contentService: .notInvoked,
            counterService: .notInvoked,
            lastResponseCodeService: .notInvoked,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(errorMessage: nil))

        XCTAssertTrue(labels.isEmpty)

        sut.errorMessageLabel
            .subscribe(onNext: { labels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(labels, [nil])
    }

    func test_errorMessageLabelWhenNotNil() {

        var labels = [String?]()

        sut = .live(
            contentService: .notInvoked,
            counterService: .notInvoked,
            lastResponseCodeService: .notInvoked,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(errorMessage: "Unable to fetch content"))

        XCTAssertTrue(labels.isEmpty)

        sut.errorMessageLabel
            .subscribe(onNext: { labels.append($0) })
            .disposed(by: disposeBag)

        XCTAssertEqual(labels, ["Unable to fetch content"])
    }

    // MARK: - onAppear tests
    func test_onAppearInvokesLastResponseCodeService() {

        let code = UUID()
        var lastResponseCodeServiceInvocationCount = 0

        let spy = LastResponseCodeService(
            responseCode: {
                lastResponseCodeServiceInvocationCount += 1
                return code
            },
            updateResponseCode: { _ in XCTFail("updateResponseCode should not be invoked") }
        )

        sut = .live(
            contentService: .notInvoked,
            counterService: .noop,
            lastResponseCodeService: spy,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertNil(try stateSubject.value().responseCode)
        XCTAssertEqual(lastResponseCodeServiceInvocationCount, 0)

        sut.onAppear()

        XCTAssertEqual(try stateSubject.value().responseCode, code)
        XCTAssertEqual(lastResponseCodeServiceInvocationCount, 1)
    }

    func test_onAppearInvokesCounterServiceWhenCurrentCountIsNil() {

        var counterServiceInvocationCount = 0

        let spy = CounterService(
            currentCount: {
                counterServiceInvocationCount += 1
                return nil
            },
            increment: { XCTFail("increment should not be invoked"); return 0 }
        )

        sut = .live(
            contentService: .notInvoked,
            counterService: spy,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        stateSubject.onNext(State(timesFetched: 1))

        XCTAssertEqual(counterServiceInvocationCount, 0)

        sut.onAppear()

        XCTAssertEqual(try stateSubject.value().timesFetched, 0)
        XCTAssertEqual(counterServiceInvocationCount, 1)
    }

    func test_onAppearInvokesCounterServiceWhenCurrentCountIsNotNil() {

        var counterServiceInvocationCount = 0

        let spy = CounterService(
            currentCount: {
                counterServiceInvocationCount += 1
                return 98
            },
            increment: { XCTFail("increment should not be invoked"); return 0 }
        )

        sut = .live(
            contentService: .notInvoked,
            counterService: spy,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value().timesFetched, 0)
        XCTAssertEqual(counterServiceInvocationCount, 0)

        sut.onAppear()

        XCTAssertEqual(try stateSubject.value().timesFetched, 98)
        XCTAssertEqual(counterServiceInvocationCount, 1)
    }

    // MARK: - fetchContent tests
    func test_fetchContentUpdatesResponseCode() {

        var receivedCodes = [UUID]()
        let code = UUID()

        let spy = LastResponseCodeService(
            responseCode: { XCTFail("responseCode should not be invoked"); return nil },
            updateResponseCode: { receivedCodes.append($0) }
        )

        sut = .live(
            contentService: .succeeding(with: code),
            counterService: .noop,
            lastResponseCodeService: spy,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertTrue(receivedCodes.isEmpty)

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertEqual(receivedCodes, [code])
    }

    func test_fetchContentDoesNotUpdateResponseCodeIfContentServiceFails() {

        var receivedCodes = [UUID]()

        let spy = LastResponseCodeService(
            responseCode: { XCTFail("responseCode should not be invoked"); return nil },
            updateResponseCode: { receivedCodes.append($0) }
        )

        sut = .live(
            contentService: .failing,
            counterService: .noop,
            lastResponseCodeService: spy,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertTrue(receivedCodes.isEmpty)

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertTrue(receivedCodes.isEmpty)
    }

    func test_fetchContentIncrementsCount() {

        var counterServiceInvocationCount = 0

        let spy = CounterService(
            currentCount: { XCTFail("currentCount should not be invoked"); return nil },
            increment: {
                counterServiceInvocationCount += 1
                return 1
            }
        )

        sut = .live(
            contentService: .succeeding(),
            counterService: spy,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value().timesFetched, 0)
        XCTAssertEqual(counterServiceInvocationCount, 0)

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertEqual(try stateSubject.value().timesFetched, 1)
        XCTAssertEqual(counterServiceInvocationCount, 1)
    }

    func test_fetchContentDoesNotIncrementCountIfContentServiceFails() {

        var counterServiceInvocationCount = 0

        let spy = CounterService(
            currentCount: { XCTFail("currentCount should not be invoked"); return nil },
            increment: {
                counterServiceInvocationCount += 1
                return 1
            }
        )

        sut = .live(
            contentService: .failing,
            counterService: spy,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value().timesFetched, 0)
        XCTAssertEqual(counterServiceInvocationCount, 0)

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertEqual(try stateSubject.value().timesFetched, 0)
        XCTAssertEqual(counterServiceInvocationCount, 0)
    }

    func test_fetchContentUpdatesStateSubjectIfContentServiceFails() {

        sut = .live(
            contentService: .failing,
            counterService: .noop,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value(), State())

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertEqual(
            try stateSubject.value(),
            State(errorMessage: "Sorry, something went wrong. Please try again.")
        )
    }

    func test_fetchContentClearsExistingErrorMessageIfContentServiceSucceeds() {

        stateSubject.onNext(State(errorMessage: "Existing error message"))

        sut = .live(
            contentService: .succeeding(),
            counterService: .noop,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value().errorMessage, "Existing error message")

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertNil(try stateSubject.value().errorMessage)
    }

    func test_fetchContentClearsExistingErrorMessageIfContentServiceFails() {

        stateSubject.onNext(State(errorMessage: "Existing error message"))

        sut = .live(
            contentService: .failing,
            counterService: .noop,
            lastResponseCodeService: .noop,
            mainScheduler: scheduler,
            stateSubject: stateSubject
        )

        XCTAssertEqual(try stateSubject.value().errorMessage, "Existing error message")

        sut.fetchContent()
            .subscribe()
            .disposed(by: disposeBag)

        XCTAssertEqual(
            try stateSubject.value(),
            State(errorMessage: "Sorry, something went wrong. Please try again.")
        )
    }
}

// MARK: - Test helpers
private struct TestError: Error {}

private extension ContentService {

    static var noop: Self {
        Self(
            fetchCurrentResponseCode: {
                return .just(ResponseCodeContent(path: "/noop", responseCode: UUID()))
            }
        )
    }

    static var notInvoked: Self {
        Self(
            fetchCurrentResponseCode: {
                XCTFail("fetchCurrentResponseCode should not be invoked")
                return .just(ResponseCodeContent(path: "/noop", responseCode: UUID()))
            }
        )
    }

    static func succeeding(with responseCode: UUID = UUID()) -> Self {
        Self(
            fetchCurrentResponseCode: {
                return .just(ResponseCodeContent(path: "/test", responseCode: responseCode))
            }
        )
    }

    static var failing: Self {
        Self(
            fetchCurrentResponseCode: {
                return .error(TestError())
            }
        )
    }
}

private extension CounterService {

    static var noop: Self {
        Self(
            currentCount: { return nil },
            increment: { return 0 }
        )
    }

    static var notInvoked: Self {
        Self(
            currentCount: {
                XCTFail("currentCount should not be invoked")
                return nil
            },
            increment: {
                XCTFail("increment should not be invoked")
                return 0
            }
        )
    }
}

private extension LastResponseCodeService {

    static var noop: Self {
        Self(
            responseCode: { return nil },
            updateResponseCode: { _ in }
        )
    }

    static var notInvoked: Self {
        Self(
            responseCode: {
                XCTFail("responseCode should not be invoked")
                return nil
            },
            updateResponseCode: { _ in
                XCTFail("updateResponseCode should not be invoked")
            }
        )
    }
}
