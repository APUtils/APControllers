//
//  EstimatedRowHeightController.swift
//  APExtensions
//
//  Created by Anton Plebanovich on 8/2/18.
//  Copyright © 2019 Anton Plebanovich. All rights reserved.
//

import UIKit

/// Controller that improves UITableView scrolling and animation experience.
/// - Note: You should assign tableView's `delegate` first and then create
/// and store `EstimatedRowHeightController`. Everything else is automatic.
public final class EstimatedRowHeightController: ObjectProxy, UITableViewDelegate {
    
    // ******************************* MARK: - Private Properties
    
    private weak var tableView: UITableView?
    private var estimatedHeights: [IndexPath: CGFloat] = [:]
    private var averageHeights: [Int: CGFloat] = [:]
    
    private weak var originalTableViewDelegate: UITableViewDelegate? {
        return originalObject as? UITableViewDelegate
    }
    
    // ******************************* MARK: - Initialization and Setup
    
    public init(tableView: UITableView) {
        UITableView._setupOnce
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView = tableView
        super.init(originalObject: tableView.delegate as? NSObject)
        tableView.delegate = self
        tableView.onUpdateFinish = { [weak self] in self?.onIndexPathChange() }
    }
    
    deinit {
        tableView?.delegate = originalTableViewDelegate
    }
    
    // ******************************* MARK: - Notifications
    
    @objc private func onIndexPathChange() {
        guard let tableView = tableView else { return }
        
        // -- func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
        // When this method is called in an animation block defined by the beginUpdates()
        // and endUpdates() methods, it behaves similarly to deleteRows(at:with:).
        // The indexes that UITableView passes to the method are specified in the state
        // of the table view prior to any updates. This happens regardless of ordering of the
        // insertion, deletion, and reloading method calls within the animation block.
        
        // -- func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
        // Deletes are processed before inserts in batch operations.
        // This means the indexes for the deletions are processed relative
        // to the indexes of the table view’s state before the batch operation,
        // and the indexes for the insertions are processed relative
        // to the indexes of the state after all the deletions in the batch operation.
        
        // -- func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation)
        // When this method is called in an animation block defined by the beginUpdates() and endUpdates()
        // methods, UITableView defers any insertions of rows or sections until after it has handled
        // the deletions of rows or sections. This order is followed regardless of how the insertion
        // and deletion method calls are ordered. This is unlike inserting or removing an item in
        // a mutable array, in which the operation can affect the array index used for the successive
        // insertion or removal operation.
        
        // Let's ignore moves for now since there isn't enough of how it behave and when to apply it
        
        // estimatedHeights.keys.map { $0.row }.sorted().forEach { print($0) }
        
        // First, no sense to invalidate values for reload it'll be requested when needed anyway
        // and what we have is the best possible approximation since height might not be changed on update.
        
        // Second, let's handle deletions.
        // We need to clear actual deleted index paths and then process all others
        // decreasing their row number if they have higher row index.
        tableView.deleteIndexPaths.forEach { deleteIndexPath in
            estimatedHeights[deleteIndexPath] = nil
            estimatedHeights = estimatedHeights.mapDictionary { indexPath, value in
                guard indexPath.section == deleteIndexPath.section, indexPath.row > deleteIndexPath.row else {
                    return (indexPath, value)
                }
                
                let newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
                return (newIndexPath, value)
            }
        }
        
        // Third, let's handle insertions.
        // We need to increase all index path's row value that are placed higher or equal in index
        tableView.insertIndexPaths.forEach { insertIndexPath in
            estimatedHeights = estimatedHeights.mapDictionary { indexPath, value in
                guard indexPath.section == insertIndexPath.section, indexPath.row >= insertIndexPath.row else {
                    return (indexPath, value)
                }
                
                let newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                return (newIndexPath, value)
            }
        }
        
        // Welp, wasn't hard after all just need to recheck everything.
    }
    
    // ******************************* MARK: - UITableViewDelegate
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let estimatedHeight = estimatedHeights[indexPath] {
            return estimatedHeight
        } else {
            
            return averageHeights[indexPath.section]?.roundedToPixel ?? UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Prevent cell stuck in zero size.
        // Table view won't queue for actual height if 0 is returned for estimated.
        if cell.bounds.height > 0 {
            if let _ = estimatedHeights[indexPath] {
                // Just update height
                estimatedHeights[indexPath] = cell.frame.height
            } else {
                // Update estimated height and average height
                processHeight(cell.frame.height, indexPath: indexPath)
            }
            
        } else {
            estimatedHeights[indexPath] = nil
        }
        
        originalTableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        estimatedHeights[indexPath] = cell.bounds.height
        originalTableViewDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    private func processHeight(_ height: CGFloat, indexPath: IndexPath) {
        let previousCount = CGFloat(estimatedHeights.count)
        let nextCount = CGFloat(previousCount + 1)
        let currentAverage = averageHeights[indexPath.section] ?? 0
        averageHeights[indexPath.section] = (currentAverage * previousCount + height ) / nextCount
        estimatedHeights[indexPath] = height
    }
}

// ******************************* MARK: - Swizzle Functions

private func swizzleClassMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getClassMethod(`class`, originalSelector)!
    let swizzledMethod = class_getClassMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
    guard !class_isMetaClass(`class`) else { return }
    
    let originalMethod = class_getInstanceMethod(`class`, originalSelector)!
    let swizzledMethod = class_getInstanceMethod(`class`, swizzledSelector)!
    
    swizzleMethods(class: `class`, originalSelector: originalSelector, originalMethod: originalMethod, swizzledSelector: swizzledSelector, swizzledMethod: swizzledMethod)
}

private func swizzleMethods(class: AnyClass, originalSelector: Selector, originalMethod: Method, swizzledSelector: Selector, swizzledMethod: Method) {
    let didAddMethod = class_addMethod(`class`, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
    
    if didAddMethod {
        class_replaceMethod(`class`, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

// ******************************* MARK: - Load

private extension UITableView {
    static let _setupOnce: Void = {
        
        if #available(iOS 11.0, *) {
            swizzleMethods(class: UITableView.self, originalSelector: #selector(performBatchUpdates(_:completion:)), swizzledSelector: #selector(_apextensions_performBatchUpdates(_:completion:)))
        }
        
        swizzleMethods(class: UITableView.self, originalSelector: #selector(beginUpdates), swizzledSelector: #selector(_apextensions_beginUpdates))
        swizzleMethods(class: UITableView.self, originalSelector: #selector(endUpdates), swizzledSelector: #selector(_apextensions_endUpdates))
        swizzleMethods(class: UITableView.self, originalSelector: #selector(insertRows(at:with:)), swizzledSelector: #selector(_apextensions_insertRows(at:with:)))
        swizzleMethods(class: UITableView.self, originalSelector: #selector(deleteRows(at:with:)), swizzledSelector: #selector(_apextensions_deleteRows(at:with:)))
        swizzleMethods(class: UITableView.self, originalSelector: #selector(reloadRows(at:with:)), swizzledSelector: #selector(_apextensions_reloadRows(at:with:)))
        swizzleMethods(class: UITableView.self, originalSelector: #selector(moveRow(at:to:)), swizzledSelector: #selector(_apextensions_moveRow(at:to:)))
    }()
}

// ******************************* MARK: - UITableView Methods Listening

private var c_isUpdatingAssociationKey = 0
private var c_onUpdateFinishAssociationKey = 0
private var c_insertIndexPathsAssociationKey = 0
private var c_deleteIndexPathsAssociationKey = 0
private var c_reloadIndexPathsAssociationKey = 0
private var c_moveIndexPathsAssociationKey = 0

private extension UITableView {
    
    var isUpdating: Bool {
        get {
            return objc_getAssociatedObject(self, &c_isUpdatingAssociationKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &c_isUpdatingAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var onUpdateFinish: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, &c_onUpdateFinishAssociationKey) as? (() -> Void)
        }
        set {
            objc_setAssociatedObject(self, &c_onUpdateFinishAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var insertIndexPaths: [IndexPath] {
        get {
            return objc_getAssociatedObject(self, &c_insertIndexPathsAssociationKey) as? [IndexPath] ?? []
        }
        set {
            objc_setAssociatedObject(self, &c_insertIndexPathsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var deleteIndexPaths: [IndexPath] {
        get {
            return objc_getAssociatedObject(self, &c_deleteIndexPathsAssociationKey) as? [IndexPath] ?? []
        }
        set {
            objc_setAssociatedObject(self, &c_deleteIndexPathsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var reloadIndexPaths: [IndexPath] {
        get {
            return objc_getAssociatedObject(self, &c_reloadIndexPathsAssociationKey) as? [IndexPath] ?? []
        }
        set {
            objc_setAssociatedObject(self, &c_reloadIndexPathsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    typealias MoveTuple = (from: IndexPath, to: IndexPath)
    var moveIndexPaths: [MoveTuple] {
        get {
            return objc_getAssociatedObject(self, &c_moveIndexPathsAssociationKey) as? [MoveTuple] ?? []
        }
        set {
            objc_setAssociatedObject(self, &c_moveIndexPathsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @available(iOS 11.0, *)
    @objc private func _apextensions_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        
        isUpdating = true
        _apextensions_performBatchUpdates(updates, completion: { success in
            self.onUpdateFinish?()
            self.insertIndexPaths = []
            self.deleteIndexPaths = []
            self.reloadIndexPaths = []
            self.moveIndexPaths = []
            
            completion?(success)
            self.isUpdating = false
        })
    }
    
    @objc private func _apextensions_beginUpdates() {
        isUpdating = true
        _apextensions_beginUpdates()
    }
    
    @objc private func _apextensions_endUpdates() {
        onUpdateFinish?()
        insertIndexPaths = []
        deleteIndexPaths = []
        reloadIndexPaths = []
        moveIndexPaths = []
        
        _apextensions_endUpdates()
        isUpdating = false
    }
    
    @objc private func _apextensions_insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertIndexPaths.append(contentsOf: indexPaths)
        if !isUpdating {
            onUpdateFinish?()
            insertIndexPaths = []
        }
        
        _apextensions_insertRows(at: indexPaths, with: animation)
    }
    
    @objc private func _apextensions_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        deleteIndexPaths.append(contentsOf: indexPaths)
        if !isUpdating {
            onUpdateFinish?()
            deleteIndexPaths = []
        }
        
        _apextensions_deleteRows(at: indexPaths, with: animation)
    }
    
    @objc private func _apextensions_reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadIndexPaths.append(contentsOf: indexPaths)
        if !isUpdating {
            onUpdateFinish?()
            reloadIndexPaths = []
        }
        
        _apextensions_reloadRows(at: indexPaths, with: animation)
    }
    
    @objc private func _apextensions_moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        moveIndexPaths.append((from: indexPath, to: newIndexPath))
        if !isUpdating {
            onUpdateFinish?()
            moveIndexPaths = []
        }
        
        _apextensions_moveRow(at: indexPath, to: newIndexPath)
    }
}
