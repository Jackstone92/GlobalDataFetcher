//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A service responsible for retrieving the current data fetch count as well as incrementing that value.
public struct CounterService {

    /// Returns the current data fetch count, if available.
    public let currentCount: () -> Int?

    /// Increments the current data fetch count.
    public let increment: () -> Int

    public init(
        currentCount: @escaping () -> Int?,
        increment: @escaping () -> Int
    ) {
        self.currentCount = currentCount
        self.increment = increment
    }
}
