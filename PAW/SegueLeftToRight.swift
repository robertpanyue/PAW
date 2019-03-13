//
//  SegueLeftToRight.swift
//  PAW
//
//  Created by Yue Pan on 3/7/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit

class SegueLeftToRight: UIStoryboardSegue {
  override func perform()
  {
    let src = self.source
    let dst = self.destination
    
    src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
    dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
    
    UIView.animate(withDuration: 0.25,
                   delay: 0.0,
                   options: UIView.AnimationOptions.curveEaseInOut,
                   animations: {
                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
    },
                   completion: { finished in
                    src.present(dst, animated: false, completion: nil)
    }
    )
  }
}
