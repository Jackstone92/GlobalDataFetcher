//
//  Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import ResponseCodeStore

extension ResponseCodeStore {

    /// The `live` instance that should be used in production.
    ///
    /// - Parameter userDefaults: The user defaults to use in order to persist and retrieve response codes.
    ///
    public static func live(using userDefaults: UserDefaults) -> Self {
        Self(
            get: { key in
                guard let uuidString = userDefaults.value(forKey: key) as? String else {
                    return nil
                }

                return UUID(uuidString: uuidString)
            },
            insert: { uuid, key in
                userDefaults.set(uuid.uuidString, forKey: key)
            }
        )
    }
}
