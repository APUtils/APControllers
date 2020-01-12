//
//  TableViewVC.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 1/11/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import APControllers
import APExtensions
import UIKit

final class TableViewVC: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // ******************************* MARK: - Private Properties
    
    private var vm: TableViewVM = TableViewVM()
    
    // ******************************* MARK: - Initialization and Setup
    
    deinit {
        print("deinit \(self)")
    }
    
    private var didLoadDate: Date!
    override func viewDidLoad() {
        print("viewDidLoad \(self)")
        setup()
        super.viewDidLoad()
        didLoadDate = Date()
    }
    
    private func setup() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(class: TableViewCell.self)
        tableView.optimizeCellHeightComputations(cell: TableViewCell.instantiateFromXib()) { [weak self] in
            self?.configureCell($0, indexPath: $1)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLog("******** First load %f", Date().timeIntervalSince(didLoadDate))
    }
    
    // ******************************* MARK: - Actions
    
    @IBAction private func onDebugTap(_ sender: Any) {
        let date1 = Date()
        vm.randomize()
        NSLog("******** Randomize %f", Date().timeIntervalSince(date1))
        
        let date2 = Date()
        tableView.reloadRows(at: tableView.visibleIndexPaths, with: .automatic)
        NSLog("******** Reload %f", Date().timeIntervalSince(date2))
    }
}

// ******************************* MARK: - InstantiatableFromStoryboard

extension TableViewVC: InstantiatableFromStoryboard {}

// ******************************* MARK: - UITableViewDelegate, UITableViewDataSource

extension TableViewVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewVM.cellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TableViewCell.self, for: indexPath)
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: TableViewCell, indexPath: IndexPath) {
        let cellVM = vm.getViewModel(indexPath: indexPath)
        cell.configure(vm: cellVM)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let cellVM = vm.cellVMs[indexPath.row]
    }
}
