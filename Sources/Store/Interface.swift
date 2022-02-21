//
//  Interface.swift
//  Copyright © 2022 Notonthehighstreet Enterprises Limited. All rights reserved.
//

import Foundation

/// A generic store interface that supports CRUD operations that operate on the given keys and values.
public struct Store<Key: Hashable, Value> {

    /// Returns the store's value for a given key, if a value is present in the store.
    public let get: (_ key: Key) -> Value?

    /// Inserts a new value into the store against a given key.
    public let insert: (_ value: Value, _ key: Key) -> Void

    public init(
        get: @escaping (Key) -> Value?,
        insert: @escaping (Value, Key) -> Void
    ) {
        self.get = get
        self.insert = insert
    }
}
