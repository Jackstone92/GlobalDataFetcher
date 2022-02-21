//
//  DataFetchViewModel+Live.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ContentService
import CounterService
import LastResponseCodeService

extension DataFetchViewModel {

    /// The `live` view model configuration that should be used in production.
    ///
    /// - Parameters:
    ///     - contentService: The `ContentService` instance to use in order to fetch new content.
    ///     - counterService: The `CounterService` instance to use in order to fetch the latest count as well as increment.
    ///     - lastResponseCodeService: The `LastResponseCodeService` to use in order to restore the last known response code as well as to update that value.
    ///     - mainScheduler: The main scheduler that should be used.
    ///     - stateSubject: The state subject that is the current state source of truth and drives the other `Observable`s and downstream bindings.
    ///
    public static func live(
        contentService: ContentService,
        counterService: CounterService,
        lastResponseCodeService: LastResponseCodeService,
        mainScheduler: SchedulerType,
        stateSubject: BehaviorSubject<State> = .init(value: State())
    ) -> Self {
        Self(
            responseCodeLabel: stateSubject
                .map(\.responseCode?.uuidString),

            timesFetchedLabel: stateSubject
                .map(\.timesFetched)
                .map(String.init),

            errorMessageLabel: stateSubject
                .map(\.errorMessage),

            onAppear: {
                let lastResponseCode = lastResponseCodeService.responseCode()
                let lastCounterValue = counterService.currentCount() ?? 0

                let updatedState = State(
                    responseCode: lastResponseCode,
                    timesFetched: lastCounterValue
                )

                stateSubject.onNext(updatedState)
            },
            fetchContent: {
                // Clear existing error message but don't be blocking
                if var updatedState = try? stateSubject.value() {
                    updatedState.errorMessage = nil
                    stateSubject.onNext(updatedState)
                }

                return contentService.fetchCurrentResponseCode()
                    .observe(on: mainScheduler)
                    .do(onNext: { content in lastResponseCodeService.updateResponseCode(content.responseCode) })
                    .map { content in
                        let responseCode = content.responseCode
                        let updatedCount = counterService.increment()

                        return State(responseCode: responseCode, timesFetched: updatedCount)
                    }
                    .do(
                        onNext: { stateSubject.onNext($0) },
                        onError: { _ in
                            guard var updatedState = try? stateSubject.value() else { return }
                            updatedState.errorMessage = "Sorry, something went wrong. Please try again."

                            stateSubject.onNext(updatedState)
                        }
                    )
                    .eraseToVoid()
            }
        )
    }
}

private extension Observable {

    func eraseToVoid() -> Observable<Void> {
        return map { _ in () }
    }
}
