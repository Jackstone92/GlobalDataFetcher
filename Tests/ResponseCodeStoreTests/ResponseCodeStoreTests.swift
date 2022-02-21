//
//  ResponseCodeStoreTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import ResponseCodeStore
import ResponseCodeStoreLive

final class ResponseCodeStoreTests: XCTestCase {

    private var sut: ResponseCodeStore!
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
    func test_responseCodeStore_getWhenExists() {

        let uuid = UUID()

        testDefaults.set(uuid.uuidString, forKey: key)

        let value = sut.get(key)

        XCTAssertEqual(value, uuid)
    }

    func test_responseCodeStore_getWhenDoesNotExist() {

        XCTAssertNil(testDefaults.value(forKey: key))

        let value = sut.get(key)

        XCTAssertNil(value)
    }

    func test_responseCodeStore_getWhenNonUUIDString() {

        let nonUUIDString = 1000

        testDefaults.set(nonUUIDString, forKey: key)

        let value = sut.get(key)

        XCTAssertNil(value)
    }

    func test_responseCodeStore_getWhenInvalidUUIDString() {

        let invalidUUIDString = "_asdf-1"

        testDefaults.set(invalidUUIDString, forKey: key)

        let value = sut.get(key)

        XCTAssertNil(value)
    }

    // MARK: - insert tests
    func test_responseCodeStore_insert() {

        let uuid = UUID()

        XCTAssertNil(testDefaults.value(forKey: key))

        sut.insert(uuid, key)

        XCTAssertEqual(try XCTUnwrap(testDefaults.value(forKey: key) as? String), uuid.uuidString)
    }

    func test_responseCodeStore_insertOverwritesExistingResponseCode() {

        let existingUUID = UUID()
        let uuid = UUID()

        testDefaults.set(existingUUID.uuidString, forKey: key)

        sut.insert(uuid, key)

        XCTAssertEqual(try XCTUnwrap(testDefaults.value(forKey: key) as? String), uuid.uuidString)
    }
}
