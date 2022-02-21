//
//  Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import CounterService
import CounterStore

extension CounterService {

    /// The `live` instance that should be used in production.
    ///
    /// - Parameter store: The store to use in order to persist and retrieve data fetch count values.
    ///
    public static func live(using store: CounterStore) -> Self {

        let storeKey = "LAST_COUNTER_VALUE"

        return Self(
            currentCount: {
                store.get(storeKey)
            },
            increment: {
                let existingCount = store.get(storeKey) ?? 0
                let incremented = existingCount + 1

                store.insert(incremented, storeKey)

                return incremented
            }
        )
    }
}
