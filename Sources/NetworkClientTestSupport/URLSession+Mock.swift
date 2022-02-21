//
//  URLSession+Mock.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

extension URLSession {

    /// A mock configuration that includes `MockURLProtocol` pre-assigned.
    /// When using this, all that is needed is to define `MockURLProtocol.requestHandler`.
    ///
    public static var mock: URLSession {
        let configuration: URLSessionConfiguration = .default
        configuration.protocolClasses = [MockURLProtocol.self]

        return URLSession(configuration: configuration)
    }
}
