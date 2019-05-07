//
//  HistoryTableViewController.swift
//  PAW
//
//  Created by Yue Pan on 4/26/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation

class HistoryTableViewController: UIViewController, UITableViewDelegate{
  
  var hasImage = false;

  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var historyImage: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.   
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    let userID = Auth.auth().currentUser?.uid
    ref.child("history").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      let value = snapshot.value as? NSDictionary
      let date = value?["date"] as? String ?? ""
      self.dateLabel.text = date
      
    }) { (error) in
      print(error.localizedDescription)
    }
    
    historyImage.image = getImage();
  }

  
  func getImage() -> UIImage{
    let fileManager = FileManager.default
    let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent("history.jpg")
    if fileManager.fileExists(atPath: imagePath){
      hasImage = true;
      return UIImage(contentsOfFile: imagePath)!
    }else{
      print("No Image")
      return UIImage()
    }
  }
  
  func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]; 
    return documentsDirectory
  }
  
  @IBAction func backButton(_ sender: Any) {
    let transition: CATransition = CATransition()
    transition.duration = 0.25
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.reveal
    transition.subtype = CATransitionSubtype.fromRight
    self.view.window!.layer.add(transition, forKey: nil)
    self.dismiss(animated: true, completion: nil)
  }
  
}
