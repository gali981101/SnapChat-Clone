//
//  SnapVC.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/28.
//

import UIKit
import Firebase
import ImageSlideshow

class SnapVC: UIViewController {

    var selectedSnap: Snap?
    var inputArray = [KingfisherSource]()
    
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUp()
    }
    
}


// MARK: Setting

extension SnapVC {
    
    private func setUp() {
        layOut()
        snapSet()
    }
    
}


// MARK: LayOut

extension SnapVC {
    
    private func layOut() {
        navbarSet()
        toolbarSet()
        labelSet()
    }
    
    private func navbarSet() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", image: UIImage(systemName: "ellipsis"), target: self, action: nil, menu: deleteMenu)
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func toolbarSet() {
        navigationController?.isToolbarHidden = true
    }
    
    private func labelSet() {
        timeLabel.text = "Time Left: \(selectedSnap?.timeDifference ?? 0)"
    }
    
}


// MARK: Menu

extension SnapVC {
    
    var deleteMenuItems: [UIAction] {
        return [
            UIAction(title: "Delete Current", image: nil, handler: { [self] (_) in
                deleteAlert(all: false)
            }),
            UIAction(title: "Delete All", image: nil, handler: { [self] (_) in
                deleteAlert(all: true)
            })
        ]
    }
    
    var deleteMenu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: deleteMenuItems)
    }
    
}

// MARK: @Objc

extension SnapVC {}


// MARK: Snap

extension SnapVC {
    
    private func snapSet() {
        if let snap = selectedSnap {
            createImageSlideShow(snap: snap)
        }
    }
    
    private func createImageSlideShow(snap: Snap) {
        for imageUrl in snap.imageUrlArray {
            inputArray.append(KingfisherSource(urlString: imageUrl)!)
        }
        
        let imageSlideShow = ImageSlideshow(frame: CGRect(x: 0, y: 10, width: self.view.frame.width, height: self.view.frame.height))
        
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = .lightGray
        pageIndicator.pageIndicatorTintColor = .darkGray
        
        imageSlideShow.pageIndicator = pageIndicator
        
        imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
        imageSlideShow.setImageInputs(inputArray)
        
        self.view.addSubview(imageSlideShow)
        self.view.bringSubviewToFront(timeLabel)
    }
    
}


// MARK: Alert

extension SnapVC {
    
    private func deleteAlert(all: Bool) {
        let alert = UIAlertController(title: "Are you Sure ?", message: "刪除後，將無法挽回", preferredStyle: .alert)
        
        let sureButton = UIAlertAction(title: "確定", style: .default) { _ in
            print("尚未開通")
        }
        let cancel = UIAlertAction(title: "等等", style: .cancel)
        
        alert.addAction(sureButton)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
    
}
