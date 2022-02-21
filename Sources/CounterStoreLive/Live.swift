//
//  Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import CounterStore

extension CounterStore {


    /// The `live` instance that should be used in production.
    ///
    /// - Parameter userDefaults: The user defaults to use in order to persist and retrieve the data fetch count value.
    ///
    public static func live(using userDefaults: UserDefaults) -> Self {
        Self(
            get: { key in
                return userDefaults.value(forKey: key) as? Int
            },
            insert: { count, key in
                userDefaults.set(count, forKey: key)
            }
        )
    }
}
