//
//  NetworkClient.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// The network client that is used to perform network requests.
///
public struct NetworkClient {

    private let session: URLSession

    /// - Parameter session: The `URLSession` instance to use in order to perform network requests.
    ///
    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches data for a given endpoint and attempts to decode it as the specified type.
    ///
    /// - Parameter url: The URL to fetch data from.
    /// - Parameter as: The type to decode the data as.
    /// - Parameter jsonDecoder: The `JSONDecoder` instance to use when decoding.
    ///
    public func fetch<T: Decodable>(
        url: URL,
        as: T.Type,
        using jsonDecoder: JSONDecoder
    ) -> Observable<T> {

        let request = URLRequest(url: url)

        return session.rx.data(request: request)
            .decode(type: T.self, decoder: jsonDecoder)
    }
}
