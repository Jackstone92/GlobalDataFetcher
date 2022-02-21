//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation
import Store

/// A store that persists response codes.
public typealias ResponseCodeStore = Store<String, UUID>
