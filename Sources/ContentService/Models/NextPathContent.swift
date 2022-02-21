//
//  NextPathContent.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A content model that details the endpoint to retrieve the response code content from.
public struct NextPathContent: Equatable, Codable {

    public let nextPath: URL

    public init(nextPath: URL) {
        self.nextPath = nextPath
    }
}
