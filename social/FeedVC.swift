//
//  FeedVC.swift
//  social
//
//  Created by Mario Fancovic on 18/11/2016.
//  Copyright © 2016 Mario Fancovic. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signOutTapped(_ sender: Any) {
        
        let KeychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("MARIO: key \(KeychainResult) bol zmazaný")
        try! FIRAuth.auth()?.signOut()        
        dismiss(animated: true, completion: nil)
    }
    
}
