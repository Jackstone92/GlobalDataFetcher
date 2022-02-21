//
//  LastResponseCodeServiceTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import LastResponseCodeService
import LastResponseCodeServiceLive
import ResponseCodeStore

final class LastResponseCodeServiceTests: XCTestCase {

    private var sut: LastResponseCodeService!

    // MARK: - responseCode tests
    func test_responseCodeInvokesStoreWithExpectedKey() {

        var receivedKeys = [String]()

        let spy = ResponseCodeStore(
            get: { receivedKeys.append($0); return nil },
            insert: { _, _ in XCTFail("Insert method should not be invoked") }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedKeys.isEmpty)

        _ = sut.responseCode()

        XCTAssertEqual(receivedKeys, ["LAST_RESPONSE_CODE"])
    }

    func test_responseCodeReturnsValueFromStore() {

        let code = UUID()

        sut = .live(using: .stubbed(with: code))

        let responseCode = sut.responseCode()

        XCTAssertEqual(responseCode, code)
    }

    // MARK: - updateResponseCode tests
    func test_updateResponseCodeInvokesStoreWithExpectedKey() {

        var receivedKeys = [String]()

        let spy = ResponseCodeStore(
            get: { _ in XCTFail("Get method should not be invoked"); return nil },
            insert: { _, key in receivedKeys.append(key) }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedKeys.isEmpty)

        sut.updateResponseCode(UUID())

        XCTAssertEqual(receivedKeys, ["LAST_RESPONSE_CODE"])
    }

    func test_updateResponseCodeInvokesStoreWithExpectedResponseCode() {

        let code = UUID()
        var receivedCodes = [UUID?]()

        let spy = ResponseCodeStore(
            get: { _ in XCTFail("Get method should not be invoked"); return nil },
            insert: { responseCode, _ in receivedCodes.append(responseCode) }
        )

        sut = .live(using: spy)

        XCTAssertTrue(receivedCodes.isEmpty)

        sut.updateResponseCode(code)

        XCTAssertEqual(receivedCodes, [code])
    }
}

private extension ResponseCodeStore {

    static func stubbed(with getResult: UUID?) -> Self {
        Self(
            get: { _ in return getResult },
            insert: { _, _ in }
        )
    }
}
