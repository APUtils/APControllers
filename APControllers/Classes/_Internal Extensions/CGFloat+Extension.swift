//
//  CGFloat+Extension.swift
//  APControllers
//
//  Created by Anton Plebanovich on 1/12/20.
//  Copyright © 2020 Anton Plebanovich. All rights reserved.
//

import UIKit

extension CGFloat {
    
    /// Returns value raunded to a nearest pixel
    var roundedToPixel: CGFloat {
        let scale = UIScreen.main.scale
        return (self * scale).rounded() / scale
    }
    
    /// Returns value raunded to a nearest up pixel
    var roundedUpToPixel: CGFloat {
        let scale = UIScreen.main.scale
        return (self * scale).rounded(.up) / scale
    }
}
