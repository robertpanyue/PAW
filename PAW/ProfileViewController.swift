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
  
  @IBAction func backButton(_ sender: Any)
  {
    self.dismiss(animated: true, completion: nil)
  }
  
}
