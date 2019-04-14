//
//  RegisterViewController.swift
//  PAW
//
//  Created by Yue Pan on 2/24/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController,UITextFieldDelegate {
  
  @IBOutlet weak var email: UITextField!
  @IBOutlet weak var password: UITextField!
  @IBOutlet weak var dogName: UITextField!
  @IBOutlet weak var firstName: UITextField!
  @IBOutlet weak var lastName: UITextField!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.HideKeyboard();
  }
  
  
  @IBAction func register(_ sender: Any) {
    Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!, completion: {(user, error) in 
      if user != nil {
        print("User Has Signed Up!")
      }
      if error != nil {
        print("error")
      }
      
      var ref: DatabaseReference!
      ref = Database.database().reference().child("users").child((user?.user.uid)!)
      let newUser = [
        "uid": user?.user.uid,
        "phone" : self.dogName.text!,
        "firstName" : self.firstName.text!,
        "lastName" : self.lastName.text!,
        "location": "0 0"
      ] 
      ref.updateChildValues(newUser as [AnyHashable : Any], withCompletionBlock: {(error, ref) in 
        if error != nil {
          print("error")
          return
        }
      })
    })
  }
  

}
