//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A service that is responsible for retrieving and updating response codes.
///
public struct LastResponseCodeService {

    /// Fetches the last know response code, if any.
    public let responseCode: () -> UUID?

    /// Updates the latest response code.
    public let updateResponseCode: (UUID) -> Void

    public init(
        responseCode: @escaping () -> UUID?,
        updateResponseCode: @escaping (UUID) -> Void
    ) {
        self.responseCode = responseCode
        self.updateResponseCode = updateResponseCode
    }
}
