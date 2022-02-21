//
//  Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import LastResponseCodeService
import ResponseCodeStore

extension LastResponseCodeService {

    /// The `live` instance that should be used in production.
    ///
    /// - Parameter store: The store to use in order to persist and retrieve response codes.
    ///
    public static func live(using store: ResponseCodeStore) -> Self {

        let storeKey = "LAST_RESPONSE_CODE"

        return Self(
            responseCode: {
                store.get(storeKey)
            },
            updateResponseCode: { responseCode in
                store.insert(responseCode, storeKey)
            }
        )
    }
}
