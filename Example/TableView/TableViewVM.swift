//
//  TableViewVM.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 1/11/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

struct TableViewVM {
    
    // ******************************* MARK: - Public Properties
    
    static let cellsCount: Int = 1000000
    
    // ******************************* MARK: - Public Properties
    
    private var cellVMs: [IndexPath: TableViewCellVM] = [:]
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {}
    
    // ******************************* MARK: - Public Methods
    
    mutating func getViewModel(indexPath: IndexPath) -> TableViewCellVM {
        if let vm = cellVMs[indexPath] {
            return vm
        } else {
            let vm = TableViewCellVM()
            cellVMs[indexPath] = vm
            return vm
        }
    }
    
    mutating func randomize() {
        cellVMs = [:]
    }
}
