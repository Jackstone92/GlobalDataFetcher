//
//  MockURLProtocolTests.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest
import RxSwift
import NetworkClientTestSupport

final class MockURLProtocolTests: XCTestCase {

    private var sut: MockURLProtocol!
    private var client: MockURLProtocolClient!

    private let validURL = URL(string: "https://www.test.com")

    override func setUp() {
        super.setUp()

        MockURLProtocol.requestHandler = nil
        client = MockURLProtocolClient()
    }

    func test_canInitReturnsTrue() throws {

        let urlRequest = URLRequest(url: try XCTUnwrap(validURL))

        XCTAssertTrue(MockURLProtocol.canInit(with: urlRequest))
    }

    func test_canonicalRequestReturnsRequest() throws {

        let urlRequest = URLRequest(url: try XCTUnwrap(validURL))

        XCTAssertEqual(MockURLProtocol.canonicalRequest(for: urlRequest), urlRequest)
    }

    func test_startLoadingInvokesClientDidReceive() throws {

        var responses = [URLResponse]()
        var policies = [URLCache.StoragePolicy]()

        client.didReceiveInvoked = { response, policy in
            responses.append(response)
            policies.append(policy)
        }

        MockURLProtocol.requestHandler = { _ throws in
            let validURL = try XCTUnwrap(self.validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
            let data: Data? = Data("{}".utf8)

            return (try XCTUnwrap(httpURLResponse), data)
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertTrue(responses.isEmpty)
        XCTAssertTrue(policies.isEmpty)

        sut.startLoading()

        XCTAssertEqual(responses.count, 1)
        XCTAssertEqual(policies, [.notAllowed])
    }

    func test_startLoadingDoesNotInvokeClientDidReceiveIfRequestHandlerThrows() throws {

        var responses = [URLResponse]()
        var policies = [URLCache.StoragePolicy]()

        client.didReceiveInvoked = { response, policy in
            responses.append(response)
            policies.append(policy)
        }

        MockURLProtocol.requestHandler = { _ throws in
            throw TestError()
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertTrue(responses.isEmpty)
        XCTAssertTrue(policies.isEmpty)

        sut.startLoading()

        XCTAssertTrue(responses.isEmpty)
        XCTAssertTrue(policies.isEmpty)
    }

    func test_startLoadingInvokesDidLoadWhenDataIsPresent() throws {

        var receivedData = [Data]()

        client.didLoadInvoked = { receivedData.append($0) }

        MockURLProtocol.requestHandler = { _ throws in
            let validURL = try XCTUnwrap(self.validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
            let data: Data? = Data("{}".utf8)

            return (try XCTUnwrap(httpURLResponse), data)
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertTrue(receivedData.isEmpty)

        sut.startLoading()

        XCTAssertEqual(receivedData, [Data("{}".utf8)])
    }

    func test_startLoadingDoesNotInvokeDidLoadWhenDataIsNil() throws {

        var receivedData = [Data]()

        client.didLoadInvoked = { receivedData.append($0) }

        MockURLProtocol.requestHandler = { _ throws in
            let validURL = try XCTUnwrap(self.validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)

            return (try XCTUnwrap(httpURLResponse), nil)
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertTrue(receivedData.isEmpty)

        sut.startLoading()

        XCTAssertTrue(receivedData.isEmpty)
    }

    func test_startLoadingInvokesURLProtocolDidFinishLoading() throws {

        var invocationCount = 0

        client.didFinishLoadingInvoked = { invocationCount += 1 }

        MockURLProtocol.requestHandler = { _ throws in
            let validURL = try XCTUnwrap(self.validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
            let data: Data? = Data("{}".utf8)

            return (try XCTUnwrap(httpURLResponse), data)
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertEqual(invocationCount, 0)

        sut.startLoading()

        XCTAssertEqual(invocationCount, 1)
    }

    func test_startLoadingInvokesDidFailWithError() throws {

        var invocationCount = 0

        client.didFailWithErrorInvoked = { invocationCount += 1 }

        MockURLProtocol.requestHandler = { _ throws in
            throw TestError()
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertEqual(invocationCount, 0)

        sut.startLoading()

        XCTAssertEqual(invocationCount, 1)
    }

    func test_startLoadingDoesNotInvokeDidFailWithErrorIfSucceeds() throws {

        var invocationCount = 0

        client.didFailWithErrorInvoked = { invocationCount += 1 }

        MockURLProtocol.requestHandler = { _ throws in
            let validURL = try XCTUnwrap(self.validURL)
            let httpURLResponse = HTTPURLResponse.make(with: validURL, statusCode: 200)
            let data: Data? = Data("{}".utf8)

            return (try XCTUnwrap(httpURLResponse), data)
        }

        sut = MockURLProtocol(
            request: URLRequest(url: try XCTUnwrap(validURL)),
            cachedResponse: nil,
            client: client
        )

        XCTAssertEqual(invocationCount, 0)

        sut.startLoading()

        XCTAssertEqual(invocationCount, 0)
    }
}

private class MockURLProtocolClient: NSObject, URLProtocolClient {

    var didReceiveInvoked: ((_ response: URLResponse, _ policy: URLCache.StoragePolicy) -> Void)?
    var didLoadInvoked: ((Data) -> Void)?
    var didFinishLoadingInvoked: (() -> Void)?
    var didFailWithErrorInvoked: (() -> Void)?

    func urlProtocol(_ protocol: URLProtocol, didReceive response: URLResponse, cacheStoragePolicy policy: URLCache.StoragePolicy) {
        didReceiveInvoked?(response, policy)
    }

    func urlProtocol(_ protocol: URLProtocol, didLoad data: Data) {
        didLoadInvoked?(data)
    }

    func urlProtocolDidFinishLoading(_ protocol: URLProtocol) {
        didFinishLoadingInvoked?()
    }

    func urlProtocol(_ protocol: URLProtocol, didFailWithError error: Error) {
        didFailWithErrorInvoked?()
    }

    func urlProtocol(_ protocol: URLProtocol, wasRedirectedTo request: URLRequest, redirectResponse: URLResponse) {
        XCTFail("wasDirectedTo should not be invoked")
    }

    func urlProtocol(_ protocol: URLProtocol, cachedResponseIsValid cachedResponse: CachedURLResponse) {
        XCTFail("cachedResponseIsValid should not be invoked")
    }

    func urlProtocol(_ protocol: URLProtocol, didReceive challenge: URLAuthenticationChallenge) {
        XCTFail("didReceive:challenge: should not be invoked")
    }

    func urlProtocol(_ protocol: URLProtocol, didCancel challenge: URLAuthenticationChallenge) {
        XCTFail("didCancel should not be invoked")
    }
}

// MARK: - Test helpers
private struct TestError: Error {}

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
