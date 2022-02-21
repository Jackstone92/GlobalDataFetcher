//
//  AsyncButtonAction.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A button action that can be invoked to perform a task.
/// Invocation of the provided button completion signals that the task has completed and, whether this is
/// an asynchronous or synchronous task, the button completion should always be invoked.
///
/// - Parameter completion: The button completion that should be invoked in order to signal that the
///                         asynchronous task has completed.
///
public typealias AsyncButtonAction = (@escaping AsyncButtonCompletion) -> Void

/// An asynchronous completion handler that should be invoked in order to signal that an `AsyncButtonAction` has completed.
public typealias AsyncButtonCompletion = () -> Void
