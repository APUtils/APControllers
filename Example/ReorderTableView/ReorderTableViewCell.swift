//
//  ReorderTableViewCell.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/18/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import APExtensions
import UIKit

final class ReorderTableViewCell: UITableViewCell, InstantiatableFromXib {
    
    // ******************************* MARK: - @IBOutlets
    
    @IBOutlet private var label: UILabel!
    
    // ******************************* MARK: - Initialization and Setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        
    }
    
    // ******************************* MARK: - Configuration
    
    func configure(vm: ReorderTableViewCellVM) {
        label.text = vm.text
        backgroundColor = vm.backgroundColor
    }
}
