//
//  ViewController.swift
//  social
//
//  Created by Mario Fancovic on 16/11/2016.
//  Copyright © 2016 Mario Fancovic. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper


class SignInVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: FancyTextField!
    @IBOutlet var pwdField: FancyTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // nasledujúce tri riadky sú pre opustenie klavesnice po texte
        emailField.delegate = self
        pwdField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard)))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let keych = KeychainWrapper.standard.string(forKey: KEY_UID) {
            self.performSegue(withIdentifier: "goToFeed", sender: nil)
            print("MARIO: Našiel sa keychain \(keych)")
        }
    }

    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            if error != nil {
                print("MARIO: Nebolo sa možné pripojiť k facebooku - \(error)")
            } else if result?.isCancelled == true {
                print("MARIO: Používateľ zrušil autentifikáciu na Facebooku")
            } else {
                print("MARIO: Autentifikásia u facebooku úspešná")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("MARIO: Nebolo sa možné pripojiť k firebase - \(error)")
            } else {
                print("MARIO: Autentifikásia u firebase je úspešná")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pasw = pwdField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pasw, completion: { (user, error) in
                if error == nil {
                    print("MARIO: Autentifikásia u firebase úspešná")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pasw, completion: { (user, error) in
                        if error == nil {
                            print("MARIO: Vytvorené nové konto pre usera \(email) u Firebase")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                        } else {
                            print("MARIO: Nebolo možné vytvoriť nové konto u firebase - \(error)")
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String){
        print("idem ulozit keych \(id)")
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("MARIO: data boli uložené do keychain")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    // Nasledujúce dve funkcie sú pre opustenie klávesnice, nezabudnúť delegate
    func dismissKeyboard() {
        pwdField.resignFirstResponder()
        emailField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pwdField.resignFirstResponder()
        emailField.resignFirstResponder()
        return true
    }
}

