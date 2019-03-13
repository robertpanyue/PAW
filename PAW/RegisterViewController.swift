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
    })
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    //saveUserInfoFirebase();
  }
  
  fileprivate func saveUserInfoFirebase() {
    let user = Auth.auth().currentUser!
    let uuid = UUID().uuidString
    var ref: DatabaseReference!
    ref = Database.database().reference()
    let newUser = [
      "uuid" : uuid,
      "dogName" : dogName.text!,
      "firstName" : firstName.text!,
      "lastName" : lastName.text!
    ] 
    ref.child("users").child(user.uid).setValue(newUser)
  }
}
