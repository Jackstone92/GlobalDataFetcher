//
//  ImmediateSchedulerTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
@testable import TestSchedulers

final class ImmediateSchedulerTests: XCTestCase {

    private var sut: ImmediateScheduler!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()
        sut = .instance
        disposeBag = DisposeBag()
    }

    // MARK: - now tests
    func test_now() {

        let date = Date()
        sut._now = { date }

        XCTAssertEqual(sut.now, date)
    }

    // MARK: - scheduleRelative tests
    func test_scheduleRelativeInvokesActionImmediately() {

        var actionInvocationCount = 0

        sut
            .scheduleRelative("Some State", dueTime: .seconds(500)) { _ in
                actionInvocationCount += 1
                return Disposables.create()
            }
            .disposed(by: disposeBag)

        XCTAssertEqual(actionInvocationCount, 1)
    }

    // MARK: - schedule tests
    func test_scheduleInvokesActionImmediately() {

        var actionInvocationCount = 0

        sut
            .schedule("Some State") { _ in
                actionInvocationCount += 1
                return Disposables.create()
            }
            .disposed(by: disposeBag)

        XCTAssertEqual(actionInvocationCount, 1)
    }
}
