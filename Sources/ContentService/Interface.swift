//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift

/// The interface for the `ContentService`.
/// This service is responsible for fetching the current response code.
/// 
public struct ContentService {

    /// Fetches the current response code.
    public let fetchCurrentResponseCode: () -> Observable<ResponseCodeContent>

    public enum Error: Swift.Error {
        /// The root URL that was called was invalid.
        case invalidRootURL
    }

    public init(fetchCurrentResponseCode: @escaping () -> Observable<ResponseCodeContent>) {
        self.fetchCurrentResponseCode = fetchCurrentResponseCode
    }
}
