//
//  ReorderTableViewVC.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/18/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import APControllers
import APExtensions
import UIKit
import SwiftReorder

final class ReorderTableViewVC: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // ******************************* MARK: - Private Properties
    
    private var vm: ReorderTableViewVM = ReorderTableViewVM()
    
    // ******************************* MARK: - Initialization and Setup
    
    deinit {
        print("deinit \(self)")
    }
    
    override func viewDidLoad() {
        setup()
        super.viewDidLoad()
    }
    
    private func setup() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(class: ReorderTableViewCell.self)
        tableView.setDefaultReorderBehaviour(delegate: self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.optimizeCellHeightComputations(cell: ReorderTableViewCell.instantiateFromXib()) { [weak self] cell, indexPath in
            self?.configureCell(cell, indexPath: indexPath)
        }
    }
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension ReorderTableViewVC: InstantiatableFromStoryboard {}

// ******************************* MARK: - UITableViewDelegate, UITableViewDataSource

extension ReorderTableViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReorderTableViewVM.cellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Getting cell for: \(indexPath)")
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        
        let cell = tableView.dequeue(ReorderTableViewCell.self, for: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: ReorderTableViewCell, indexPath: IndexPath) {
        let cellVM = vm.getViewModel(indexPath: indexPath)
        cell.configure(vm: cellVM)
    }
}

// ******************************* MARK: - TableViewReorderDelegate

extension ReorderTableViewVC: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.reorderViewModel(from: sourceIndexPath, to: destinationIndexPath)
    }
}

// ******************************* MARK: - Extensions

private extension UITableView {
    func setDefaultReorderBehaviour(delegate: TableViewReorderDelegate) {
        reorder.delegate = delegate
        reorder.cellScale = 1.05
        reorder.shadowOpacity = 0.5
        reorder.shadowRadius = 20
        reorder.autoScrollThreshold = 80
        reorder.autoScrollMinVelocity = 60
        reorder.autoScrollMaxVelocity = 500
    }
}
