//
//  Mock.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift

extension ContentService {

    /// A mock configuration that can be used to simulate a delay in the fetching of response
    /// codes (eg. due to a slow network connection).
    ///
    public static func delayed(
        responseCode: UUID = UUID(),
        delayInterval: RxTimeInterval = .seconds(3),
        scheduler: SchedulerType = MainScheduler.asyncInstance
    ) -> Self {
        Self(
            fetchCurrentResponseCode: {
                let content = ResponseCodeContent(path: "/delayed", responseCode: responseCode)

                return .just(content)
                    .delay(delayInterval, scheduler: scheduler)
            }
        )
    }
}
