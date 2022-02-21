//
//  ContentServiceTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import ContentService
import ContentServiceLive
import NetworkClient
import NetworkClientTestSupport
import TestSchedulers

final class ContentServiceTests: XCTestCase {

    private var sut: ContentService!
    private var networkClient: NetworkClient!
    private var disposeBag: DisposeBag!

    private let encoder = JSONEncoder()
    private let timeout: TimeInterval = 0.1

    private let validURL = URL(string: "https://www.test.com")

    override func setUp() {
        super.setUp()

        networkClient = NetworkClient(session: .mock)
        MockURLProtocol.requestHandler = nil

        sut = .live(using: networkClient)

        disposeBag = DisposeBag()
    }

    func test_fetchCurrentResponseCodeErrorsForInvalidRootURL() {

        let invalidRootURLString = "Invalid root URL"
        var receivedErrors = [Error]()

        sut = .live(
            rootURLString: invalidRootURLString,
            using: networkClient
        )

        sut.fetchCurrentResponseCode()
            .subscribe(
                onNext: { _ in XCTFail() },
                onError: { receivedErrors.append($0) }
            )
            .disposed(by: disposeBag)

        XCTAssertEqual(receivedErrors.count, 1)

        guard let error = receivedErrors.first, case ContentService.Error.invalidRootURL = error else {
            XCTFail("Unexpected error received")
            return
        }
    }

    func test_fetchCurrentResponseCodeDecodingExpectsSnakeCaseKeys() {

        let expectation = self.expectation(description: "Should invoke onError")
        expectation.assertForOverFulfill = false

        var receivedErrors = [Error]()

        MockURLProtocol.requestHandler = makeFailingSnakeCaseRequestHandler()

        sut = .live(using: networkClient)

        XCTAssertTrue(receivedErrors.isEmpty)

        sut.fetchCurrentResponseCode()
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

    func test_fetchCurrentResponseCodeSucceeds() throws {

        let expectation = self.expectation(description: "Should invoke onNext")
        expectation.assertForOverFulfill = false

        var receivedResponseCodeContent = [ResponseCodeContent]()

        let nextPathContent = NextPathContent(nextPath: try XCTUnwrap(validURL))
        let responseCodeContent = ResponseCodeContent(path: "/d", responseCode: UUID())

        MockURLProtocol.requestHandler = makeSucceedingRequestHandler(
            with: nextPathContent,
            and: responseCodeContent
        )

        sut = .live(using: networkClient)

        sut.fetchCurrentResponseCode()
            .subscribe(
                onNext: {
                    receivedResponseCodeContent.append($0)
                    expectation.fulfill()
                },
                onError: { _ in XCTFail("Should not invoke onError") }
            )
            .disposed(by: disposeBag)

        waitForExpectations(timeout: timeout)

        XCTAssertEqual(receivedResponseCodeContent, [responseCodeContent])
    }

    func test_fetchCurrentResponseCodeFailureAfterRootURLCall() {

        let expectation = self.expectation(description: "Should invoke onError")
        expectation.assertForOverFulfill = false

        var receivedErrors = [Error]()

        MockURLProtocol.requestHandler = makeFailOnInitialInvocationRequestHandler()

        sut = .live(using: networkClient)

        XCTAssertTrue(receivedErrors.isEmpty)

        sut.fetchCurrentResponseCode()
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

    func test_fetchCurrentResponseCodeFailureAfterNextPathCall() throws {

        let expectation = self.expectation(description: "Should invoke onError")
        expectation.assertForOverFulfill = false

        var receivedErrors = [Error]()

        let nextPathContent = NextPathContent(nextPath: try XCTUnwrap(validURL))

        MockURLProtocol.requestHandler = makeFailOnSecondInvocationRequestHandler(with: nextPathContent)

        sut = .live(using: networkClient)

        XCTAssertTrue(receivedErrors.isEmpty)

        sut.fetchCurrentResponseCode()
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

    // MARK: - Test helpers
    /// A factory method that vends a succeeding request handler for the `ContentService`.
    /// On its first invocation, it will return encoded `NextPathContent` data, on its second invocation,
    /// it will return encoded `ResponseCodeContent` data. Otherwise, it will return `nil` as it is only
    /// expected for 2 chained calls to be made.
    ///
    private func makeSucceedingRequestHandler(
        with nextPathContent: NextPathContent,
        and responseCodeContent: ResponseCodeContent
    ) -> (URLRequest) throws -> (HTTPURLResponse, Data?) {

        let invocationCountSubject = BehaviorSubject<Int>(value: 1)

        return { [encoder, validURL] _ throws in
            let validURL = try XCTUnwrap(validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)

            let invocationCount = try invocationCountSubject.value()

            let data: Data?
            switch invocationCount {
            case 1:     data = try encoder.encode(nextPathContent)
            case 2:     data = try encoder.encode(responseCodeContent)
            default:    data = nil
            }

            invocationCountSubject.onNext(invocationCount + 1)

            return (try XCTUnwrap(httpURLResponse), data)
        }
    }

    private func makeFailingSnakeCaseRequestHandler() -> (URLRequest) throws -> (HTTPURLResponse, Data?) {
        return { [validURL] _ throws in
            let validURL = try XCTUnwrap(validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)

            let invalidNextPathString = "{ \"nextPath\": \"http://localhost:8000/d/12345\" }"

            return (try XCTUnwrap(httpURLResponse), Data(invalidNextPathString.utf8))
        }
    }

    private func makeFailOnInitialInvocationRequestHandler() -> (URLRequest) throws -> (HTTPURLResponse, Data?) {
        return { [validURL] _ throws in
            let validURL = try XCTUnwrap(validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 503)

            return (try XCTUnwrap(httpURLResponse), nil)
        }
    }

    private func makeFailOnSecondInvocationRequestHandler(
        with nextPathContent: NextPathContent
    ) -> (URLRequest) throws -> (HTTPURLResponse, Data?) {

        let invocationCountSubject = BehaviorSubject<Int>(value: 1)

        return { [encoder, validURL] _ throws in
            let validURL = try XCTUnwrap(validURL)

            let invocationCount = try invocationCountSubject.value()

            let httpURLResponse: HTTPURLResponse?
            let data: Data?
            switch invocationCount {
            case 1:
                httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
                data = try encoder.encode(nextPathContent)

            default:
                httpURLResponse = nil
                data = nil
            }

            return (try XCTUnwrap(httpURLResponse), data)
        }
    }
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
