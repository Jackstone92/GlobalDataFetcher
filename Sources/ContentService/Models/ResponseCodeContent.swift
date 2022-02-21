//
//  ResponseCodeContent.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A content model that details the current response code and the path at which the code was found.
public struct ResponseCodeContent: Equatable, Codable {

    public let path: String
    public let responseCode: UUID

    public init(path: String, responseCode: UUID) {
        self.path = path
        self.responseCode = responseCode
    }
}
