//
//  SegueRightToLeft.swift
//  PAW
//
//  Created by Yue Pan on 2/20/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit

class SegueRightToLeft: UIStoryboardSegue {
  override func perform() {
    let src = self.source
    let dst = self.destination
    
    src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
    dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y:0)
    
    UIView.animate(withDuration: 0.25, 
                   animations: {
                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
    })
  }
}
