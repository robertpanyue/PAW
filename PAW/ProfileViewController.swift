//
//  ProfileViewController.swift
//  PAW
//
//  Created by Yue Pan on 3/13/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController{
  @IBOutlet weak var nameLabel: UILabel!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.    
    var ref: DatabaseReference!
    ref = Database.database().reference()
    
    let userID = Auth.auth().currentUser?.uid
    ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
      // Get user value
      let value = snapshot.value as? NSDictionary
      let firstname = value?["firstName"] as? String ?? ""
      let lastname = value?["firstName"] as? String ?? ""
      self.nameLabel.text = firstname + lastname

    }) { (error) in
      print(error.localizedDescription)
    }
  }
  
  
  @IBAction func logout(_ sender: Any) {
    do {
      try Auth.auth().signOut()
    } catch let error {
      print(error)
    }
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let login = storyboard.instantiateViewController(withIdentifier: "LoginPage")
    self.present(login, animated: true, completion: nil)
    
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
