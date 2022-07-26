//
//  ReorderTableView.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/18/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import BaseClasses
import UIKit

final class ReorderTableView: TableView {
    
    override var contentSize: CGSize {
        didSet {
//            print("contentSize: \(contentSize)")
        }
    }
    
    override var contentOffset: CGPoint {
        didSet {
            if contentOffset.y - oldValue.y > 50 {
                print("catch!")
            }
//            print("contentOffset: \(contentOffset)")
        }
    }
}
