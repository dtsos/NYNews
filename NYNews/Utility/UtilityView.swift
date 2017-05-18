//
//  UtilityView.swift
//  NYNews
//
//  Created by David Trivian S on 5/18/17.
//  Copyright © 2017 David Trivian S. All rights reserved.
//

import Foundation
import UIKit
extension UIScrollView {
    
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}
