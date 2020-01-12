//
//  ObjectProxy.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/12/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import Foundation

class ObjectProxy: NSObject {
    
    // ******************************* MARK: - Properties
    
    private var cachedSelectors: [Selector: Bool] = [:]
    private var cachedForwardingTargets: [Selector: Any?] = [:]
    private(set) weak var originalObject: NSObject?
    
    // ******************************* MARK: - Initialization and Setup
    
    private override init() { fatalError("Use init(originalObject:) instead") }
    
    init(originalObject: NSObject?) {
        self.originalObject = originalObject
        super.init()
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        if let responds = cachedSelectors[aSelector] {
            return responds
        }
        
        var responds = super.responds(to: aSelector)
        
        if let originalObject = originalObject {
            responds = responds || originalObject.responds(to: aSelector)
        }
        
        cachedSelectors[aSelector] = responds
        
        return responds
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let forwardingTarget = cachedForwardingTargets[aSelector] {
            return forwardingTarget
            
        } else if let forwardingTarget = super.forwardingTarget(for: aSelector) {
            cachedForwardingTargets[aSelector] = forwardingTarget
            return forwardingTarget
            
        } else {
            cachedForwardingTargets[aSelector] = originalObject
            return originalObject
        }
    }
}
