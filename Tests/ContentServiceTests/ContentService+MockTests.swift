//
//  ContentService+MockTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import ContentService
import TestSchedulers

final class ContentService_MockTests: XCTestCase {

    private var sut: ContentService!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    // MARK: - delayed tests
    func test_delayedReturnsProvidedResponseCodeAfterProvidedDelayInterval() {

        let responseCode = UUID()

        sut = .delayed(
            responseCode: responseCode,
            delayInterval: .seconds(300),
            scheduler: scheduler
        )

        let observer = scheduler.createObserver(ResponseCodeContent.self)
        sut.fetchCurrentResponseCode()
            .subscribe(observer)
            .disposed(by: disposeBag)

        scheduler.start()

        scheduler.advanceTo(300)

        let expected = ResponseCodeContent(path: "/delayed", responseCode: responseCode)

        XCTAssertEqual(observer.events, [.next(300, expected), .completed(301)])
    }

    func test_delayedDefaultDelayInterval() {

        let responseCode = UUID()

        sut = .delayed(
            responseCode: responseCode,
            scheduler: scheduler
        )

        let observer = scheduler.createObserver(ResponseCodeContent.self)
        sut.fetchCurrentResponseCode()
            .subscribe(observer)
            .disposed(by: disposeBag)

        scheduler.start()

        scheduler.advanceTo(3)

        let expected = ResponseCodeContent(path: "/delayed", responseCode: responseCode)

        XCTAssertEqual(observer.events, [.next(3, expected), .completed(4)])
    }
}
