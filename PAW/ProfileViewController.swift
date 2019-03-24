//
//  ProfileViewController.swift
//  PAW
//
//  Created by Yue Pan on 3/13/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController{
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.    
  }
  
  @IBAction func backButton(_ sender: Any){
    let transition: CATransition = CATransition()
    transition.duration = 0.25
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.reveal
    transition.subtype = CATransitionSubtype.fromLeft
    self.view.window!.layer.add(transition, forKey: nil)
    self.dismiss(animated: true, completion: nil)
  }
  
}
