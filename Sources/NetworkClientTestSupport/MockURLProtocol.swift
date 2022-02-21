//
//  MockURLProtocol.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import XCTest

/// A mock protocol that can be used to observe network requests that are being made by `URLSession`.
///
public final class MockURLProtocol: URLProtocol {

    // Handler to test the request and return mock response.
    public static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    public override class func canInit(with request: URLRequest) -> Bool {
        // Checks whether this protocol can handle the given request.
        return true
    }

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    public override func startLoading() {
        do {
            // Call handler with received request and capture the tuple of response and data.
            let (response, data) = try XCTUnwrap(MockURLProtocol.requestHandler)(request)
            // Pass received response to the client.
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                // Pass received data to the client.
                client?.urlProtocol(self, didLoad: data)
            }

            // Notify the client that the request has finished.
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            // Notify the client of the error.
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    public override func stopLoading() {
        // No-op
        // This is called if the request gets cancelled or completed.
    }
}
