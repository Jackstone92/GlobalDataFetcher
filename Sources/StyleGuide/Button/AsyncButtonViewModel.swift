//
//  AsyncButtonViewModel.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift

/// A view model that encapsulates asynchronous loading for use with button elements.
final class AsyncButtonViewModel {

    /// The loading status that be used to drive UI changes.
    let isLoadingSubject: BehaviorSubject<Bool>
    let buttonTapSubject = BehaviorSubject<State>(value: .pending)
    let completionSubject = PublishSubject<Void>()

    let title: String
    var action: AsyncButtonAction

    /// The alpha value for the button title.
    /// This is dependent on whether the button is in a loading state or not.
    ///
    var buttonTitleAlpha: Observable<Double> {
        isLoadingSubject
            .map { isLoading in return isLoading ? 0 : 1 }
    }

    /// The button's accessibility label.
    /// This is dependent on whether the button is in a loading state or not.
    ///
    var accessibilityLabel: Observable<String> {
        isLoadingSubject
            .map { [title] isLoading -> String in
                return isLoading ? title + " - loading" : title
            }
    }

    private let mainScheduler: SchedulerType
    private let disposeBag = DisposeBag()
    private var buttonCompletionDisposable: Disposable?
    private var loadingDelayDisposable: Disposable?

    var buttonCompletion: AsyncButtonCompletion {
        return { [weak self] in self?.completionSubject.onNext(()) }
    }

    /// A state model describing the possible loading states.
    enum State: Equatable {

        /// The button has not yet been tapped and is ready.
        case pending

        /// The button has been tapped and asynchronous tasks are in-flight.
        case buttonTapped
    }

    enum Constants {
        /// The grace period between an `action` and the `buttonCompletion` being invoked, before
        /// the `isLoading` status is toggled.
        static let loadingGracePeriod: RxTimeInterval = .seconds(1)
        static let debouncePeriod: RxTimeInterval = .milliseconds(300)
    }

    init(
        title: String,
        action: @escaping AsyncButtonAction,
        isLoading: Bool = false,
        mainScheduler: SchedulerType = MainScheduler.asyncInstance
    ) {
        self.title = title
        self.action = action
        self.isLoadingSubject = BehaviorSubject<Bool>(value: isLoading)
        self.mainScheduler = mainScheduler

        subscribeToButtonTapSubject()
    }

    /// The main method to call in order to trigger a button action.
    func onButtonTap() {
        guard let state = try? buttonTapSubject.value(), state != .buttonTapped else { return }
        buttonTapSubject.onNext(.buttonTapped)
    }

    // MARK: - Subscriptions
    private func subscribeToButtonTapSubject() {
        buttonTapSubject
            .observe(on: mainScheduler)
            .filter { $0 == .buttonTapped }
            .subscribe(onNext: { _ in
                self.action(self.buttonCompletion)
                self.subscribeToCompletionSubject()
            })
            .disposed(by: disposeBag)
    }

    private func subscribeToCompletionSubject() {

        // A subscription that toggles the `isLoadingSubject` value to true after a defined grace period
        // has passed (ie. in the event no completion has been invoked in a reasonable
        // amount of time).
        loadingDelayDisposable = Observable<Void>.just(())
            .delay(Constants.loadingGracePeriod, scheduler: mainScheduler)
            .observe(on: mainScheduler)
            .subscribe(onNext: { _ in self.isLoadingSubject.onNext(true) })

        // In the event the completion subject receives output, we can toggle the `isLoadingSubject`
        // value to false and terminate the subscription. In the event output is received from the
        // `completionSubject` before the `loadingGracePeriod` has passed, the delay subscription
        // is cancelled to prevent the `isLoadingSubject` value from ever being flipped to `true`.
        buttonCompletionDisposable = completionSubject
            .debounce(Constants.debouncePeriod, scheduler: mainScheduler)
            .observe(on: mainScheduler)
            .take(1)
            .subscribe(onNext: { _ in
                self.isLoadingSubject.onNext(false)
                self.buttonTapSubject.onNext(.pending)
                self.loadingDelayDisposable?.dispose()
            })
    }
}
