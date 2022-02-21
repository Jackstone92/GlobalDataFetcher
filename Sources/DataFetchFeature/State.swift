//
//  State.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// The main state model for the `DataFetchFeature`.
public struct State: Equatable {

    /// The response code that was last fetched.
    public var responseCode: UUID?

    /// The counter value indicating the number of times data was fetched in the lifetime of the app.
    public var timesFetched: Int

    /// An error message to notify the user with.
    public var errorMessage: String?

    public init(
        responseCode: UUID? = nil,
        timesFetched: Int = 0,
        errorMessage: String? = nil
    ) {
        self.responseCode = responseCode
        self.timesFetched = timesFetched
        self.errorMessage = errorMessage
    }
}
