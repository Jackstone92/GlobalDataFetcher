//
//  Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift
import ContentService
import NetworkClient

extension ContentService {

    /// Because the responses from the server use snake case, we can use the corresponding key decoding strategy
    /// when decoding the data.
    private static var snakeCaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    /// The `live` configuration that should be used in production.
    ///
    /// - Parameter rootURLString: The root URL to fetch in order to derive the `NextPathContent` with the actual `ResponseCodeContent`.
    /// - Parameter networkClient: The client to use in order to perform the network requests.
    ///
    public static func live(
        rootURLString: String = "http://localhost:8000",
        using networkClient: NetworkClient
    ) -> Self {
        Self(
            fetchCurrentResponseCode: {
                guard let rootURL = URL(string: rootURLString) else {
                    return .error(Error.invalidRootURL)
                }

                return networkClient
                    .fetch(url: rootURL, as: NextPathContent.self, using: snakeCaseDecoder)
                    .flatMap { content -> Observable<ResponseCodeContent> in
                        return networkClient.fetch(url: content.nextPath, as: ResponseCodeContent.self, using: snakeCaseDecoder)
                    }
            }
        )
    }
}
