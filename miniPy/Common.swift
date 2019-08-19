//
//  Common.swift
//  miniPy
//
//  Created by Gui Andrade on 6/15/19.
//  Copyright © 2019 Gui Andrade. All rights reserved.
//

import Foundation
import UIKit

var statusBarHeight: CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return min(statusBarSize.width, statusBarSize.height)
}
