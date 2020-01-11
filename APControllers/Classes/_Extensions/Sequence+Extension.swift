//
//  Sequence+Extension.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/12/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

// ******************************* MARK: - Operations

extension Sequence where Element: BinaryFloatingPoint {
    
    /// Returns averge value of all elements in a sequence.
    func average() -> Element {
        var i: Element = 0
        var total: Element = 0
        
        for value in self {
            total = total + value
            i += 1
        }
        
        if i == 0 {
            return 0
        } else {
            return total / i
        }
    }
}
