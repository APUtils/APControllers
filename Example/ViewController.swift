//
//  ViewController.swift
//  APControllers-Example
//
//  Created by Anton Plebanovich on 01/12/2020.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    // ******************************* MARK: - @IBOutlets
    
    // ******************************* MARK: - Initialization and Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction private func onTableViewTap(_ sender: Any) {
        let vc = TableViewVC.instantiateFromStoryboard()
        navigationController?.pushViewController(vc)
    }
    
    @IBAction private func onReorderTableViewTap(_ sender: Any) {
        let vc = ReorderTableViewVC.instantiateFromStoryboard()
        navigationController?.pushViewController(vc)
    }
}
