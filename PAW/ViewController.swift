//
//  ViewController.swift
//  PAW
//
//  Created by Yue Pan on 2/21/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITextFieldDelegate{
  
  @IBOutlet weak var ScrollView: UIScrollView!
  @IBOutlet weak var EmailTextField: UITextField!
  @IBOutlet weak var PasswordTextField: UITextField!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    self.HideKeyboard()
    if Auth.auth().currentUser != nil {
      Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
        self.performSegue(withIdentifier: "GotoMain", sender: nil)
      }
    }
  }
  @IBAction func login(_ sender: Any) {
    Auth.auth().signIn(withEmail: self.EmailTextField.text!, password: self.PasswordTextField.text!, completion: {(user, error) in 
      if user != nil {
        self.performSegue(withIdentifier: "GotoMain", sender: self)
      } 
      if error != nil {
        print("error")
        let alertController = UIAlertController(title: "Login in failed", message:
          "Incorrect Password!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
      }
    })
  }
  
  override open var shouldAutorotate: Bool {
    return false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool{
    if textField == EmailTextField {
      PasswordTextField.becomeFirstResponder()
    } else {
      PasswordTextField.resignFirstResponder()
    }
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    ScrollView.setContentOffset(CGPoint(x:0,y:80), animated: true)
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    ScrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
  }
  
}

extension UIViewController {
  func HideKeyboard(){
     let Tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
    
    view.addGestureRecognizer(Tap)
  }
  
  @objc func DismissKeyboard(){
    view.endEditing(true)
  }
}
