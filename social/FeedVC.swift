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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var imageAddTapped: CircleView!
    @IBOutlet var captionField: FancyTextField!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    //static var imageCache: CachedURLResponse!
    static var imageCache = NSCache<NSString, UIImage>()
    var imageSelected = false

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with:  {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            if let img = FeedVC.imageCache.object(forKey: post.imageURL as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post, img: nil)
                return cell
            }
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAddTapped.image = image
            imageSelected = true
        } else {
            
            print("MARIO: Nebol zvolený platný obrázok")
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("MARIO: Musí byť vložený nejaký text")
            return
        }
        
        guard let img = imageAddTapped.image, imageSelected == true else {
            print("MARIO: Musí byť vložený nejaký obrázok")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) {(metadata, error) in
                if error != nil {
                    print("MARIO: Obrazok sa nepodarilo uploadnuť")
                } else {
                    print("MARIO: Obrazok sa podarilo uploadnuť")
                    let downloadLink = metadata?.downloadURL()?.absoluteString
                    
                }
            }
            
        }
        
        
    }
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let KeychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MARIO: key \(KeychainResult) bol zmazaný")
        try! FIRAuth.auth()?.signOut()        
        dismiss(animated: true, completion: nil)
    }
    
}
