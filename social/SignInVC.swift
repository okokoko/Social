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

class SignInVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MARIO: Nebolo sa možné pripojiť k facebooku - \(error)")
            } else if result?.isCancelled == true {
                print("MARIO: Používateľ zrušil autentifikáciu na Facebooku")
            } else {
                print("MARIO: Autentifikásia úspešná")
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

            }
        })
    }
}

