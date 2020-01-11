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
open class ExactRowHeightController<T: UITableViewCell>: NSObject, UITableViewDelegate {
    
    public typealias ConfigureCell = (_ cell: T, _ indexPath: IndexPath) -> Void
    
    // ******************************* MARK: - Properties
    
    private let cell: T
    private weak var tableView: UITableView?
    open weak var originalTableViewDelegate: UITableViewDelegate?
    private let configureCell: ConfigureCell
    
    // ******************************* MARK: - Initialization and Setup
    
    private override init() { fatalError("Use init(tableView:) instead") }
    
    public init(cell: T, baseTableViewDelegate: UITableViewDelegate?, configureCell: @escaping ConfigureCell) {
        self.cell = cell
        self.originalTableViewDelegate = baseTableViewDelegate
        self.configureCell = configureCell
        
        super.init()
    }
    
    init(cell: T, tableView: UITableView?, configureCell: @escaping ConfigureCell) {
        self.cell = cell
        self.tableView = tableView
        self.originalTableViewDelegate = tableView?.delegate
        self.configureCell = configureCell
        
        super.init()
    }
    
    deinit {
        tableView?.delegate = originalTableViewDelegate
    }
    
    // ******************************* MARK: - NSObject Methods
    
    override open func responds(to aSelector: Selector!) -> Bool {
        var responds = super.responds(to: aSelector)
        
        if let originalTableViewDelegate = originalTableViewDelegate {
            responds = responds || originalTableViewDelegate.responds(to: aSelector)
        }
        
        return responds
    }
    
    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let target = super.forwardingTarget(for: aSelector) {
            return target
        } else if let originalTableViewDelegate = originalTableViewDelegate, originalTableViewDelegate.responds(to: aSelector) {
            return originalTableViewDelegate
        } else {
            return nil
        }
    }
    
    
    // ******************************* MARK: - Private Methods
    
    // ******************************* MARK: - UITableViewDelegate
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        configureCell(cell, indexPath)
        let size = cell.systemLayoutSizeFitting(tableView.bounds.size,
                                                withHorizontalFittingPriority: .required,
                                                verticalFittingPriority: .init(1))
        
        return size.height.roundedUpToPixel
    }
}

// ******************************* MARK: - UITableView Extension

private var c_exactRowHeightControllerAssociationKey = 0

public extension UITableView {
    
    /// Just retainer for a convenience
    private var exactRowHeightController: Any? {
        get {
            return objc_getAssociatedObject(self, &c_exactRowHeightControllerAssociationKey)
        }
        set {
            objc_setAssociatedObject(self, &c_exactRowHeightControllerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Calculates exact cell size using providded cell and cell configuration closure.
    /// - warning: Replaces and proxies tableView's `delegate` property
    /// so be sure to call this method when tableView's `delegate` is already set.
    func computeRowHeightAutomatically<T: UITableViewCell>(cell: T, configureCell: @escaping (_ cell: T, _ indexPath: IndexPath) -> Void) {
        let controller = ExactRowHeightController<T>(cell: cell, tableView: self, configureCell: configureCell)
        
        // Capture
        exactRowHeightController = controller
        
        delegate = controller
    }
    
    /// Stops rows automatic computation.
    func stopComputeRowHeightAutomatically() {
        exactRowHeightController = nil
    }
}
