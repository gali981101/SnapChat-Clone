//
//  FeedVC.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/28.
//

import UIKit
import Firebase
import Kingfisher

class FeedVC: UIViewController {
    
    let db = Firestore.firestore()
    
    var snapArray = [Snap]()
    var chosenSnap: Snap?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setAll()
    }
    
}


// MARK: Setting

extension FeedVC {
    
    private func setAll() {
        tableViewDelegateSet()
        layOut()
        getSnapsFromFirebase()
        getUserInfo()
    }
    
}


// MARK: LayOut

extension FeedVC {
    
    private func layOut() {
        navbarSet()
        toolbarSet()
    }
    
    private func navbarSet() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "LogOut", style: .done, target: self, action: #selector(logOutButtonClicked))
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func toolbarSet() {
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonClicked))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        navigationController?.toolbar.tintColor = .label
        //  navigationController?.toolbarItems = [space, plusButton]
        
        toolbarItems = [space, plusButton]  // 有點奇怪
    }
    
}


// MARK: @Objc Func

extension FeedVC {
    
    @objc func logOutButtonClicked() {
        userLogOut()
    }
    
    @objc func plusButtonClicked() {
        goToUploadVC()
    }
    
}


// MARK: Segue

extension FeedVC {
    
    private func userLogOut() {
        do {
            try Auth.auth().signOut()
            backToSignInPage()
        } catch {
            print("登出失敗")
        }
    }
    
    private func backToSignInPage() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyBoard.instantiateViewController(withIdentifier: "signInVC") as! SignInVC
        
        signInVC.modalPresentationStyle = .fullScreen
        
        self.present(signInVC, animated: true, completion: nil)
    }
    
    private func goToUploadVC() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let uploadVC = storyBoard.instantiateViewController(withIdentifier: "uploadVC") as! UploadVC
        
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSnapVC" {
            let destinationVC = segue.destination as! SnapVC
            
            destinationVC.selectedSnap = chosenSnap
        }
    }
    
}


// MARK: TableView Delegate

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    
    private func tableViewDelegateSet() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
        cell.feedUserNameLabel.text = snapArray[indexPath.row].username
        cell.feedImageView.kf.setImage(with: URL(string: snapArray[indexPath.row].imageUrlArray[0]))
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenSnap = snapArray[indexPath.row]
        performSegue(withIdentifier: "toSnapVC", sender: nil)
    }
    
}


// MARK: Get Data

extension FeedVC {
    
    private func getSnapsFromFirebase() {
        db.collection("Snaps").order(by: "date", descending: true).addSnapshotListener { [self] snapshot, error in
            errorHandle(snapshot: snapshot, error: error, getInfo: false)
        }
    }
    
    private func loopForSnapshotDocuments(snapshot: QuerySnapshot) {
        snapArray.removeAll()
        
        for document in snapshot.documents {
            processData(document: document)
        }
    }
    
    private func processData(document: QueryDocumentSnapshot) {
        if let username = document.get("snapOwner") as? String {
            imageUrlArrayCheck(document: document, username: username)
        }
    }
    
    private func imageUrlArrayCheck(document: QueryDocumentSnapshot, username: String) {
        if let imageUrlArray = document.get("imageUrlArray") as? [String] {
            dateCheck(document: document, username: username, imageUrlArray: imageUrlArray)
        }
    }
    
    private func dateCheck(document: QueryDocumentSnapshot, username: String, imageUrlArray: [String]) {
        if let date = document.get("date") as? Timestamp {
            timeFlies(document: document, username: username, imageUrlArray: imageUrlArray, date: date)
        }
    }
    
}


// MARK: User Info

extension FeedVC {
    
    private func getUserInfo() {
        db.collection("UserInfo").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { [self] snapshot, error in
            errorHandle(snapshot: snapshot, error: error, getInfo: true)
        }
    }
    
    private func loopForDocuments(snapshot: QuerySnapshot) {
        for document in snapshot.documents {
            getUsername(document: document)
        }
    }
    
    private func getUsername(document: QueryDocumentSnapshot) {
        if let username = document.get("username") as? String {
            UserModel.sharedUserInfo.email = Auth.auth().currentUser!.email!
            UserModel.sharedUserInfo.username = username
        }
        
        self.tableView.reloadData()
    }
    
}


// MARK: Date

extension FeedVC {
    
    private func timeFlies(document: QueryDocumentSnapshot, username: String, imageUrlArray: [String], date: Timestamp) {
        if let difference = Calendar.current.dateComponents([.hour], from: date.dateValue(), to: Date()).hour {
            if difference >= 24 {
                deleteSnap(document: document)
            } else {
                snapArray.append(Snap(username: username, imageUrlArray: imageUrlArray, date: date.dateValue(), timeDifference: 24 - difference))
            }
        }
        
        self.tableView.reloadData()
    }
    
}


// MARK: Firebase Func（共用函式）

extension FeedVC {
    
    private func errorHandle(snapshot: QuerySnapshot?, error: Error?, getInfo: Bool) {
        if error != nil {
            makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "過程發生錯誤", vc: self)
        } else {
            snapshotCheck(snapshot: snapshot, getInfo: getInfo)
        }
    }

    private func snapshotCheck(snapshot: QuerySnapshot?, getInfo: Bool) {
        if snapshot != nil && snapshot?.isEmpty == false {
            if getInfo {
                loopForDocuments(snapshot: snapshot!)
            } else {
                loopForSnapshotDocuments(snapshot: snapshot!)
            }
        }
    }

}


// MARK: Delete

extension FeedVC {
    
    private func deleteSnap(document: QueryDocumentSnapshot) {
        db.collection("Snaps").document(document.documentID).delete { error in
            print(error?.localizedDescription ?? "刪除過程發生錯誤")
        }
    }
    
}




















