//
//  NetworkClientTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import NetworkClient
import NetworkClientTestSupport

final class NetworkClientTests: XCTestCase {

    private var sut: NetworkClient!
    private var networkClient: NetworkClient!
    private var disposeBag: DisposeBag!

    private let validURL = URL(string: "https://www.test.com")!
    private let timeout: TimeInterval = 0.1

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    struct TestModel: Equatable, Codable {
        let id: UUID
        let title: String
        let counts: [Int]
    }

    override func setUp() {
        super.setUp()

        MockURLProtocol.requestHandler = nil
        sut = NetworkClient(session: .mock)

        disposeBag = DisposeBag()
    }

    // MARK: - fetch tests
    func test_networkClientRequestsWithExpectedURLRequest() {

        let expectation = self.expectation(description: "Should make network request")
        expectation.assertForOverFulfill = false

        var receivedRequests = [URLRequest]()

        MockURLProtocol.requestHandler = { urlRequest in
            receivedRequests.append(urlRequest)
            expectation.fulfill()
            return (HTTPURLResponse(), nil)
        }

        XCTAssertTrue(receivedRequests.isEmpty)

        sut.fetch(url: validURL, as: TestModel.self, using: decoder)
            .subscribe(onNext: { _ in })
            .disposed(by: disposeBag)

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(receivedRequests.map(\.url), [validURL])
    }

    func test_networkClientReturnsDecodedDataSuccessfully() throws {

        let expectation = self.expectation(description: "Should invoke onNext")
        expectation.assertForOverFulfill = false

        var receivedDecodedModels = [TestModel]()

        MockURLProtocol.requestHandler = { [encoder, validURL] _ throws in
            let encodedData: Data? = try encoder.encode(TestModel.dummy)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)

            return (try XCTUnwrap(httpURLResponse), encodedData)
        }

        XCTAssertTrue(receivedDecodedModels.isEmpty)

        sut.fetch(url: validURL, as: TestModel.self, using: decoder)
            .subscribe(
                onNext: {
                    receivedDecodedModels.append($0)
                    expectation.fulfill()
                },
                onError: { _ in XCTFail("Should not invoke onError") }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(receivedDecodedModels, [.dummy])
    }

    func test_networkClientErrorsIfServerError() {

        let expectation = self.expectation(description: "Should invoke onError")
        expectation.assertForOverFulfill = false

        var receivedErrors = [Error]()

        MockURLProtocol.requestHandler = { [validURL] _ throws in
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 404)

            return (try XCTUnwrap(httpURLResponse), nil)
        }

        XCTAssertTrue(receivedErrors.isEmpty)

        sut.fetch(url: validURL, as: TestModel.self, using: decoder)
            .subscribe(
                onNext: { _ in XCTFail("Should not invoke onNext") },
                onError: {
                    receivedErrors.append($0)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(receivedErrors.count, 1)
    }

    func test_networkClientErrorsIfDecodingError() {

        let expectation = self.expectation(description: "Should invoke onError")
        expectation.assertForOverFulfill = false

        var receivedErrors = [Error]()

        MockURLProtocol.requestHandler = { [validURL] _ throws in
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
            let invalidEncodedString = "{ \"somethingElse\": true }"

            return (try XCTUnwrap(httpURLResponse), Data(invalidEncodedString.utf8))
        }

        XCTAssertTrue(receivedErrors.isEmpty)

        sut.fetch(url: validURL, as: TestModel.self, using: decoder)
            .subscribe(
                onNext: { _ in XCTFail("Should not invoke onNext") },
                onError: {
                    receivedErrors.append($0)
                    expectation.fulfill()
                }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(receivedErrors.count, 1)
    }
}

// MARK: - Test helpers
private extension NetworkClientTests.TestModel {

    static var dummy: Self = {
        Self(
            id: UUID(),
            title: "Dummy Test Model",
            counts: [0, 1, 1, 2, 3, 5, 8, 13]
        )
    }()
}

private extension HTTPURLResponse {

    static func make(with url: URL, statusCode: Int) -> Self? {
        Self(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
    }
}
