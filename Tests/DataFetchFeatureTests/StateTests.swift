//
//  StateTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import DataFetchFeature

final class StateTests: XCTestCase {

    private var sut: State!

    // MARK: - init tests
    func test_initialisesWithProvidedValues() {

        let responseCode = UUID()
        let timesFetched = 99
        let errorMessage = "Error!"

        sut = State(
            responseCode: responseCode,
            timesFetched: timesFetched,
            errorMessage: errorMessage
        )

        XCTAssertEqual(sut.responseCode, responseCode)
        XCTAssertEqual(sut.timesFetched, timesFetched)
        XCTAssertEqual(sut.errorMessage, errorMessage)
    }

    func test_initialisesWithDefaultValues() {

        sut = State()

        XCTAssertNil(sut.responseCode)
        XCTAssertEqual(sut.timesFetched, 0)
        XCTAssertNil(sut.errorMessage)
    }
}
