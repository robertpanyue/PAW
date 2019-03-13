//
//  PresentingController.swift
//  PAW
//
//  Created by Yue Pan on 3/13/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit


class PresentingController {
  // making the property lazy will result in the getter code
  // being executed only when asked the first time
  lazy var mapController2 = { () -> UIViewController in
    let mstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    return mstoryboard.instantiateViewController(withIdentifier: "First")
  }
  lazy var mapController = { () -> UIViewController in
    let mstoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    return mstoryboard.instantiateViewController(withIdentifier: "Second")
  }
  
  func moveToMap(viewcont: UIViewController, flag: Int) {
    // simply use the mapController property
    // the property reference will make sure the controller won't
    // get deallocated, so every time you navigate to that screen
    // you'll get the same controller
    if flag == 1 {
      viewcont.present(mapController2(), animated: true, completion: nil)
    }else {
      viewcont.present(mapController(), animated: true, completion: nil)
      
    }
    
  }
}
