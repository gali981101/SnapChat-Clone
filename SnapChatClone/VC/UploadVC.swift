//
//  UploadVC.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/28.
//

import UIKit
import PhotosUI
import Firebase

class UploadVC: UIViewController {
    
    var defaultImage: UIImage?
    var changeImage = false
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layOut()
    }
    
}


// MARK: LayOut Setting

extension UploadVC {
    
    private func layOut() {
        navBerSet()
        toolbarSet()
        setUpGesture()
        defaultImageSet()
    }
    
    private func navBerSet() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(postButtonClicked))
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func toolbarSet() {
        let filterMenuButton = UIBarButtonItem(title: "濾鏡", image: nil, target: self, action: nil, menu: filterMenu)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [space, filterMenuButton]
        navigationController?.toolbar.tintColor = .label
    }
    
    private func defaultImageSet() {
        defaultImage = imageView.image
    }
    
}


// MARK: Gesture

extension UploadVC {
    
    private func setUpGesture() {
        imageView.isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
}


// MARK: @Objc Func

extension UploadVC {
    
    @objc func choosePicture() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func postButtonClicked() {
        uploadImage()
    }
    
}


// MARK: Filter Menu

extension UploadVC {
    
    var filterMenuItems: [UIAction] {
        return [
            UIAction(title: "Chrome", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Chrome)
            }),
            UIAction(title: "Fade", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Fade)
            }),
            UIAction(title: "Instant", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Instant)
            }),
            UIAction(title: "Mono", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Mono)
            }),
            UIAction(title: "Noir", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Noir)
            }),
            UIAction(title: "Process", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Process)
            }),
            UIAction(title: "Tonal", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Tonal)
            }),
            UIAction(title: "Transfer", image: nil, handler: { [self] (_) in
                resetFilter()
                imageView.image = defaultImage!.addFilter(filter: .Transfer)
            }),
            UIAction(title: "None", image: nil, handler: { [self] (_) in
                resetFilter()
            }),
        ]
    }
    
    var filterMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: filterMenuItems)
    }
    
}


// MARK: Filter Func

extension UploadVC {
    
    private func resetFilter() {
        imageView.image = defaultImage
    }
    
}


// MARK: Segue

extension UploadVC {
    
    private func backToFeedVC() {
        let feedNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FeedNav") as! UINavigationController
        
        feedNav.modalPresentationStyle = .fullScreen
        self.present(feedNav, animated: true)
    }
    
}


// MARK: Alert

extension UploadVC {
    
    private func noChosenImageAlert() {
        let alert = UIAlertController(title: "Wait!", message: "尚未選擇圖片", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .cancel)
        
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
    
}


// MARK: PHPPicker

extension UploadVC: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let itemProviders = results.map(\.itemProvider)
        
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            let previousImage = self.imageView.image
            
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let self = self, let image = image as? UIImage, self.imageView.image == previousImage else { return }
                    
                    self.defaultImage = image
                    self.imageView.image = image
                    self.changeImage = true
                }
            }
            
        }
        
        picker.dismiss(animated: true)
    }
    
}


// MARK: Storage

extension UploadVC {
    
    private func uploadImage() {
        if changeImage {
            createRef()
        } else {
            noChosenImageAlert()
        }
    }
    
    private func createRef() {
        let mediaRef = Storage.storage().reference().child("media")
        addImageToRef(ref: mediaRef)
    }
    
    private func addImageToRef(ref: StorageReference) {
        if let imageData = imageView.image?.pngData() {
            let uuid = UUID().uuidString
            
            putImageData(imageData: imageData, imageRef: ref.child("\(uuid).png"))
        }
    }
    
    private func putImageData(imageData: Data, imageRef: StorageReference) {
        imageRef.putData(imageData) { [self] metaData, error in
            uploadImageErrorHandler(imageRef: imageRef, metaData: metaData, error: error)
        }
    }
    
    private func uploadImageErrorHandler(imageRef: StorageReference, metaData: StorageMetadata?, error: Error?) {
        if error != nil {
            makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "存儲圖片數據時發生錯錯", vc: self)
        } else {
            downloadUrl(imageRef: imageRef)
        }
    }
    
    private func downloadUrl(imageRef: StorageReference) {
        imageRef.downloadURL { [self] url, error in
            downloadSuccess(url: url, error: error)
        }
    }
    
    private func downloadSuccess(url: URL?, error: Error?) {
        if error == nil {
            // 查找是否已上傳過 ImageUrlArray
            filterEmail(url: url!.absoluteString)
        }
    }
    
}


// MARK: FireStore

extension UploadVC {
    
    private func filterEmail(url: String) {
        let db = Firestore.firestore()
        
        db.collection("Snaps").whereField("ownerID", isEqualTo: Auth.auth().currentUser!.uid).getDocuments { [self] snapshot, error in
            
            filterErrorHandle(db: db, url: url, snapshot: snapshot, error: error)
        }
    }
    
    private func filterErrorHandle(db: Firestore, url: String, snapshot: QuerySnapshot?, error: Error?) {
        if error != nil {
            makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "查找過程發生錯誤", vc: self)
        } else {
            checkSnapshot(db: db, url: url, snapshot: snapshot)
        }
    }
    
    private func checkSnapshot(db: Firestore, url: String, snapshot: QuerySnapshot?) {
        if snapshot != nil && snapshot?.isEmpty == false {
            loopForSnapshot(db: db, url: url, snapshot: snapshot!)
        } else {
            saveInFireStore(db: db, url: url)
        }
    }
    
    private func loopForSnapshot(db: Firestore, url: String, snapshot: QuerySnapshot) {
        for document in snapshot.documents {
            arrayAppend(db: db, url: url, document: document)
        }
    }
    
    private func arrayAppend(db: Firestore, url: String, document: QueryDocumentSnapshot) {
        if var imageUrlArray = document.get("imageUrlArray") as? [String] {
            imageUrlArray.append(url)
            
            mergeImageUrlArray(db: db, url: url, document: document, imageUrlArray: imageUrlArray)
        }
    }
    
    private func mergeImageUrlArray(db: Firestore, url: String, document: QueryDocumentSnapshot, imageUrlArray: [String]) {
        db.collection("Snaps").document(document.documentID).setData(["imageUrlArray": imageUrlArray] as [String : Any], merge: true) { [self] error in
            backToFeedVC()
        }
    }
    
    // 新增
    private func saveInFireStore(db: Firestore, url: String) {
        let snapDictionary = [
            "imageUrlArray": [url],
            "snapOwner": UserModel.sharedUserInfo.username,
            "ownerID": Auth.auth().currentUser!.uid,
            "date": FieldValue.serverTimestamp()
        ] as [String : Any]
        
        db.collection("Snaps").addDocument(data: snapDictionary) { [self] error in
            saveInErrorHandle(error: error)
        }
    }
    
    private func saveInErrorHandle(error: Error?) {
        if error != nil {
            makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "儲存圖片至 Firestore 過程發生錯誤", vc: self)
        } else {
            backToFeedVC()
        }
    }
    
}
