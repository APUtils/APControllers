//
//  Dictionary+Extension.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/12/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

extension Dictionary {
    
    /// Map keys and values together into a new dictionary.
    /// - warning: Resulting keys must be unique!
    @inlinable func mapDictionary<T: Hashable, U>(_ transform: (_ key: Key, _ value: Value) throws -> (key: T, U)) rethrows -> [T: U] {
        return Dictionary<T, U>(uniqueKeysWithValues: try map { try transform($0, $1) })
    }
}
