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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        DataService.ds.REF_POSTS.observe(.value, with:  {(snapshot) in
            print(snapshot.value!)
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let KeychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("MARIO: key \(KeychainResult) bol zmazaný")
        try! FIRAuth.auth()?.signOut()        
        dismiss(animated: true, completion: nil)
    }
    
}
