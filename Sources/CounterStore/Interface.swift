//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import Store

/// A store that persists the number of times a data was fetched.
public typealias CounterStore = Store<String, Int>
