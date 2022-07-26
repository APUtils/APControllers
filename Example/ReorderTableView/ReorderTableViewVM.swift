//
//  ReorderTableViewVM.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/18/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

struct ReorderTableViewVM {
    // ******************************* MARK: - Public Properties
    
    static let cellsCount: Int = 10000
    
    // ******************************* MARK: - Public Properties
    
    private var cellVMs: [IndexPath: ReorderTableViewCellVM] = [:]
    
    // ******************************* MARK: - Initialization and Setup
    
    init() {}
    
    // ******************************* MARK: - Public Methods
    
    mutating func getViewModel(indexPath: IndexPath) -> ReorderTableViewCellVM {
        if let vm = cellVMs[indexPath] {
            return vm
        } else {
            let vm = ReorderTableViewCellVM()
            cellVMs[indexPath] = vm
            return vm
        }
    }
    
    mutating func reorderViewModel(from: IndexPath, to: IndexPath) {
        guard let vm = cellVMs[from] else { return }
        if let targetVM = cellVMs[to] {
            cellVMs[from] = targetVM
        }
        cellVMs[to] = vm
    }
    
    mutating func randomize() {
        cellVMs = [:]
    }
}
