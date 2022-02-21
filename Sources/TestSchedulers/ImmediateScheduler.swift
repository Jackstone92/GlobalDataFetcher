//
//  SchedulerType+Immediate.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import RxSwift

/// A scheduler for performing synchronous actions.
///
/// You can only use this scheduler for immediate actions. If you attempt to schedule actions
/// after a specific date, this scheduler ignores the date and performs them immediately.
///
/// This scheduler is useful for writing tests against `Observable`s that use asynchronous operators,
/// such as `subscribe` and others, because it forces the `Observable` to emit
/// immediately rather than needing to wait for thread hops or delays using `XCTestExpectation`.
///
/// - Note: This scheduler can _not_ be used to test `Observable`s with more complex timing logic,
///   like those that use `Debounce`, `Throttle` etc, and in fact
///   `ImmediateScheduler` will not schedule this work in a defined way.
///
public struct ImmediateScheduler: RxSwift.SchedulerType {

    /// Overriding this closure should be used for testing only.
    /// This is so we can control the date object that is returned when `now`
    /// is called without risking a flaky test.
    var _now: () -> Date = { Date() }

    public var now: RxTime { _now() }

    private init() {}

    public func scheduleRelative<StateType>(
        _ state: StateType,
        dueTime: RxTimeInterval,
        action: @escaping (StateType) -> Disposable
    ) -> Disposable {
        action(state)
    }


    public func schedule<StateType>(
        _ state: StateType,
        action: @escaping (StateType) -> Disposable
    ) -> Disposable {
        action(state)
    }
}

extension ImmediateScheduler {

    /// Creates an instance of the `ImmediateScheduler`.
    public static var instance: Self { Self() }
}
