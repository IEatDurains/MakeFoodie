//
//  LoginViewController.swift
//  MakeFoodie
//
//  Created by ITP312Grp2 on 1/7/20.
//  Copyright © 2020 ITP312. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    var errory: Int = 0;
    
    @IBOutlet weak var emaily: UITextField!
    
    @IBOutlet weak var passwordy: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let myColor = UIColor.black
        emaily.layer.borderColor = myColor.cgColor
        emaily.layer.borderWidth = 1.0
        passwordy.layer.borderColor = myColor.cgColor
        passwordy.layer.borderWidth = 1.0

        // Do any additional setup after loading the view.
    }
    public func validateEmailId(emailID: String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let trimmedString = emailID.trimmingCharacters(in: .whitespaces)
       let validateEmail = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       let isValidateEmail = validateEmail.evaluate(with: trimmedString)
       return isValidateEmail
    }
    public func validatePassword(password: String) -> Bool {
       //Minimum 8 characters at least 1 Alphabet and 1 Number:
       let passRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
       let trimmedString = password.trimmingCharacters(in: .whitespaces)
       let validatePassord = NSPredicate(format:"SELF MATCHES %@", passRegEx)
       let isvalidatePass = validatePassord.evaluate(with: trimmedString)
       return isvalidatePass
    }

    @IBAction func onLogin(_ sender: Any) {
        errory = 0;
        guard let email = emaily.text, let password = passwordy.text
        else {
           return
        }
        if emaily.text == "" || passwordy.text == ""{
            let alert = UIAlertController(
             title: "Please enter all input fields", message: "",
            preferredStyle:
            .alert)
             alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))

             self.present(alert, animated: true, completion: nil)
             return
        }
        
        let isValidateEmail = validateEmailId(emailID: email)
        if (isValidateEmail == false){
           print("Incorrect Email")
            let alert = UIAlertController(
             title: "Please enter all input fields", message: "",
            preferredStyle:
            .alert)
             alert.addAction(UIAlertAction(title: "OK", style:.default, handler: nil))

             self.present(alert, animated: true, completion: nil)
            errory = errory + 1;
           return
        }
        let isValidatePass = validatePassword(password: password)
        if (isValidatePass == false) {
           print("Minimum 8 characters at least 1 Alphabet and 1 Number")
            errory = errory + 1;
           return
        }
        if errory == 0{
            Auth.auth().signIn(withEmail: emaily.text!, password: passwordy.text!) { (result, error) in
                if error != nil{
                    print("Login Failed!")
                }
                else{
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Profile", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "tabbar")
                            self.present(newViewController, animated: true, completion: nil)
                }
                
                
            }
        }
        
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
