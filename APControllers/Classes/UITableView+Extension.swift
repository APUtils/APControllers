//
//  UITableView+Extension.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/12/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

// ******************************* MARK: - Estimated Heights

private var c_estimatedRowHeightControllerAssociationKey = 0

extension UITableView {
    var estimatedRowHeightController: Any? {
        get {
            return objc_getAssociatedObject(self, &c_estimatedRowHeightControllerAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, &c_estimatedRowHeightControllerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var _handleEstimatedSizeAutomatically: Bool {
        return estimatedRowHeightController != nil
    }
}

public extension UITableView {
    
    /// Store cells' sizes and uses them on recalculation.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to assing this property when tableView's `delegate` already is set.
    var handleEstimatedSizeAutomatically: Bool {
        set {
            guard newValue != _handleEstimatedSizeAutomatically else { return }
            
            if newValue {
                estimatedRowHeightController = EstimatedRowHeightController(tableView: self)
            } else {
                estimatedRowHeightController = nil
            }
        }
        get {
            return _handleEstimatedSizeAutomatically
        }
    }
}

// ******************************* MARK: - Exact Heights

private var c_exactRowHeightControllerAssociationKey = 0

extension UITableView {
    
    /// Just retainer for a convenience
    var exactRowHeightController: Any? {
        get {
            return objc_getAssociatedObject(self, &c_exactRowHeightControllerAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, &c_exactRowHeightControllerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public protocol CellConfigurator: AnyObject {
    func configureCell(_ cell: UITableViewCell, forRowAt indexPath: IndexPath)
}

public extension UITableView {
    
    /// Calculates exact cell size using providded cell and cell configuration closure.
    /// - parameter cell: Cell which will be used for height measurement.
    /// - parameter configureCell: Cell which will be used for height measurement.
    /// - parameter cell: Cell that requires configuration.
    /// - parameter indexPath: Index path for cell that requires configuration.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to call this method when tableView's `delegate` is already set.
    func computeRowHeightAutomatically<T: UITableViewCell>(cell: T, configureCell: @escaping (_ cell: T, _ indexPath: IndexPath) -> Void) {
        let controller = ExactRowHeightController<T>(cell: cell, tableView: self, configureCell: configureCell)
        
        // Capture
        exactRowHeightController = controller
        
        delegate = controller
    }
    
    /// Calculates exact cell size using providded cell and cell configuration closure.
    /// - parameter cell: Cell which will be used for height measurement.
    /// - parameter cellConfigurator: Cell configurator which will be captured weakly.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to call this method when tableView's `delegate` is already set.
    func computeRowHeightAutomatically(cell: UITableViewCell, cellConfigurator: CellConfigurator?) {
        let controller = ExactRowHeightController<UITableViewCell>(cell: cell, tableView: self, configureCell: { [weak cellConfigurator] cell, indexPath in
            cellConfigurator?.configureCell(cell, forRowAt: indexPath)
        })
        
        // Capture
        exactRowHeightController = controller
        
        delegate = controller
    }
    
    /// Stops rows automatic computation.
    func stopComputeRowHeightAutomatically() {
        exactRowHeightController = nil
    }
}

// ******************************* MARK: - Optimize everything

public extension UITableView {
    
    /// Optimizes both estimated and exact height computations.
    /// - parameter cell: Cell which will be used for height measurement.
    /// - parameter configureCell: Cell which will be used for height measurement.
    /// - parameter cell: Cell that requires configuration.
    /// - parameter indexPath: Index path for cell that requires configuration.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to call this method when tableView's `delegate` is already set.
    func optimizeCellHeightComputations<T: UITableViewCell>(cell: T, configureCell: @escaping (_ cell: T, _ indexPath: IndexPath) -> Void) {
        computeRowHeightAutomatically(cell: cell, configureCell: configureCell)
        handleEstimatedSizeAutomatically = true
    }
    
    /// Optimizes both estimated and exact height computations.
    /// - parameter cell: Cell which will be used for height measurement.
    /// - parameter cellConfigurator: Cell configurator which will be captured weakly.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to call this method when tableView's `delegate` is already set.
    func optimizeCellHeightComputations(cell: UITableViewCell, cellConfigurator: CellConfigurator?) {
        computeRowHeightAutomatically(cell: cell, cellConfigurator: cellConfigurator)
        handleEstimatedSizeAutomatically = true
    }
    
}
