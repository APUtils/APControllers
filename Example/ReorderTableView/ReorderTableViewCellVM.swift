//
//  ReorderTableViewCellVM.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/18/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import APExtensions
import UIKit

private var maxStringLength: Int { Int.random(in: 0...200) }

struct ReorderTableViewCellVM {
    
    // ******************************* MARK: - Public Properties
    
    var text: String = .random(length: maxStringLength, averageWordLength: 5)
    var backgroundColor: UIColor = .init(hex: .random(in: 0...0xFFFFFF))
    
    // ******************************* MARK: - Initialization and Setup
    
}
