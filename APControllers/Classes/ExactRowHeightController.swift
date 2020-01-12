//
//  ExactRowHeightController.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 1/11/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

/// Controller that improves UITableView scrolling and animation experience.
/// - Note: You should store `ExactRowHeightController` or it'll be deallocated.
public final class ExactRowHeightController<T: UITableViewCell>: ObjectProxy, UITableViewDelegate {
    
    public typealias ConfigureCell = (_ cell: T, _ indexPath: IndexPath) -> Void
    
    // ******************************* MARK: - Properties
    
    private let cell: T
    private weak var tableView: UITableView?
    private let configureCell: ConfigureCell
    
    private weak var originalTableViewDelegate: UITableViewDelegate? {
        return originalObject as? UITableViewDelegate
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public init(cell: T, baseTableViewDelegate: UITableViewDelegate?, configureCell: @escaping ConfigureCell) {
        self.cell = cell
        self.configureCell = configureCell
        
        super.init(originalObject: baseTableViewDelegate as? NSObject)
    }
    
    public init(cell: T, tableView: UITableView?, configureCell: @escaping ConfigureCell) {
        self.cell = cell
        self.tableView = tableView
        self.configureCell = configureCell
        
        super.init(originalObject: tableView?.delegate as? NSObject)
    }
    
    deinit {
        tableView?.delegate = originalTableViewDelegate
    }
    
    // ******************************* MARK: - Private Methods
    
    // ******************************* MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        configureCell(cell, indexPath)
        let size = cell.contentView.systemLayoutSizeFitting(tableView.bounds.size,
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .init(1))
        
        return size.height.roundedUpToPixel
    }
}
