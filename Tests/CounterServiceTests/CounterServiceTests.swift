//
//  DataFetchCounterTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import CounterService
import CounterServiceLive
import CounterStore

final class CounterServiceTests: XCTestCase {

    private var sut: CounterService!

    // MARK: - currentCount tests
    func test_currentCountInvokesStoreWithExpectedKey() {

        var receivedKeys = [String]()

        let spy = CounterStore(
            get: { receivedKeys.append($0); return nil },
            insert: { _, _ in XCTFail("Insert method should not be invoked") }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedKeys.isEmpty)

        _ = sut.currentCount()

        XCTAssertEqual(receivedKeys, ["LAST_COUNTER_VALUE"])
    }

    func test_currentCountReturnsValueFromStore() {

        sut = .live(using: .stubbed(with: 9_999))

        let value = sut.currentCount()

        XCTAssertEqual(value, 9_999)
    }

    // MARK: - increment tests
    func test_incrementInvokesStoreWithExpectedKey() {

        var receivedKeys = [String]()

        let spy = CounterStore(
            get: { _ in return nil },
            insert: { _, key in receivedKeys.append(key) }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedKeys.isEmpty)

        _ = sut.increment()

        XCTAssertEqual(receivedKeys, ["LAST_COUNTER_VALUE"])
    }

    func test_incrementWhenNoExistingStoredCount() {

        let existingCount: Int? = nil
        var receivedCounts = [Int]()

        let spy = CounterStore(
            get: { _ in return existingCount },
            insert: { incrementedCount, _ in receivedCounts.append(incrementedCount) }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedCounts.isEmpty)

        let incrementedCount = sut.increment()

        XCTAssertEqual(incrementedCount, 1)
        XCTAssertEqual(receivedCounts, [1])
    }

    func test_incrementWhenExistingStoredCount() {

        let existingCount = 9
        var receivedCounts = [Int]()

        let spy = CounterStore(
            get: { _ in return existingCount },
            insert: { incrementedCount, _ in receivedCounts.append(incrementedCount) }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedCounts.isEmpty)

        let incrementedCount = sut.increment()

        XCTAssertEqual(incrementedCount, 10)
        XCTAssertEqual(receivedCounts, [10])
    }
}

private extension CounterStore {

    static func stubbed(with getResult: Int?) -> Self {
        Self(
            get: { _ in return getResult },
            insert: { _, _ in }
        )
    }
}
