//
//  Extension.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/28.
//

import UIKit
import Firebase

// MARK: Filter Type

enum FilterType : String {
    case Chrome = "CIPhotoEffectChrome"
    case Fade = "CIPhotoEffectFade"
    case Instant = "CIPhotoEffectInstant"
    case Mono = "CIPhotoEffectMono"
    case Noir = "CIPhotoEffectNoir"
    case Process = "CIPhotoEffectProcess"
    case Tonal = "CIPhotoEffectTonal"
    case Transfer =  "CIPhotoEffectTransfer"
    case None = ""
}

// MARK: Keyboard Dismiss

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


// MARK: Character Check

extension String {
    
    var containsValidCharacter: Bool {
        guard self != "" else { return true }
        let hexSet = CharacterSet(charactersIn: "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz@.") //可輸入 textfield 的字元
        let newSet = CharacterSet(charactersIn: self)
        return hexSet.isSuperset(of: newSet)
    }
    
}


// MARK: Image Quailty

extension UIImage {
    
    func resizeImageWithAspect(image: UIImage,scaledToMaxWidth width:CGFloat,maxHeight height :CGFloat)->UIImage? {
        let oldWidth = image.size.width;
        let oldHeight = image.size.height;
        
        let scaleFactor = (oldWidth > oldHeight) ? width / oldWidth : height / oldHeight;
        
        let newHeight = oldHeight * scaleFactor;
        let newWidth = oldWidth * scaleFactor;
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize,false,UIScreen.main.scale);
        
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height));
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
}


// MARK: Image filter

extension UIImage {
    
    func addFilter(filter : FilterType) -> UIImage {
        let filter = CIFilter(name: filter.rawValue)
        
        let ciInput = CIImage(image: self)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        
        return UIImage(cgImage: cgImage!)
    }
    
}


// MARK: Download Image

extension FeedVC {
    
}

// MARK: Reuse Func

// 警告提醒（供重複利用）
func makeAlert(titleInput: String, messageInput: String, vc: UIViewController) {
    let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "OK", style: .default)
    
    alert.addAction(okButton)
    
    vc.present(alert, animated: true)
}


// 選擇濾鏡
//func filterSwitch(image: UIImage, type: String) -> UIImage {
//    switch type {
//    case "Chrome":
//        return image.addFilter(filter: .Chrome)
//    case "Fade":
//        return image.addFilter(filter: .Fade)
//    case "Instant":
//        return image.addFilter(filter: .Instant)
//    case "Mono":
//        return image.addFilter(filter: .Mono)
//    case "Noir":
//        return image.addFilter(filter: .Noir)
//    case "Process":
//        return image.addFilter(filter: .Process)
//    case "Tonal":
//        return image.addFilter(filter: .Tonal)
//    case "Transfer":
//        return image.addFilter(filter: .Transfer)
//    case "None":
//        return image
//    default:
//        return UIImage(named: "selectImage")!
//    }
//}

