//
//  CounterStoreTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import CounterStore
import CounterStoreLive

final class CounterStoreTests: XCTestCase {

    private var sut: CounterStore!
    private var testDefaults: UserDefaults!

    private let key = "Key"

    override func setUp() {
        super.setUp()
        testDefaults = UserDefaults(suiteName: #file)
        sut = .live(using: testDefaults)
    }

    override func tearDown() {
        super.tearDown()
        testDefaults.removePersistentDomain(forName: #file)
    }

    // MARK: - get tests
    func test_counterStore_getWhenExists() {

        let count = 99

        testDefaults.set(count, forKey: key)

        let value = sut.get(key)

        XCTAssertEqual(value, count)
    }

    func test_counterStore_getWhenDoesNotExist() {

        XCTAssertNil(testDefaults.value(forKey: key))

        let value = sut.get(key)

        XCTAssertNil(value)
    }

    func test_counterStore_getWhenNotInt() {

        let nonIntCount = "Ten"

        testDefaults.set(nonIntCount, forKey: key)

        let value = sut.get(key)

        XCTAssertNil(value)
    }

    // MARK: - insert tests
    func test_counterStore_insert() {

        XCTAssertNil(testDefaults.value(forKey: key))

        let count = 200

        sut.insert(count, key)

        XCTAssertEqual(try XCTUnwrap(testDefaults.value(forKey: key) as? Int), count)
    }

    func test_counterStore_insertOverwritesExistingResponseCode() {

        let existingCount = 99
        let count = 200

        testDefaults.set(existingCount, forKey: key)

        sut.insert(count, key)

        XCTAssertEqual(try XCTUnwrap(testDefaults.value(forKey: key) as? Int), count)
    }
}
