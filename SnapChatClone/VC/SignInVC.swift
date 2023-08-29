//
//  ViewController.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/28.
//

import UIKit
import Firebase

class SignInVC: UIViewController {
    
    var myColor: UIColor = .gray
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        textFieldDelegateSet()
        self.hideKeyboardWhenTappedAround()
    }
    
    // 實時偵測明暗模式
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        
        if userInterfaceStyle == .light {
            lightMode()
        } else {
            darkMode()
        }
    }
    
    @IBAction func logInClicked(_ sender: Any) {
        userSignIn(userExist: true)
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        userSignIn(userExist: false)
    }
    
}


// MARK: Setting LayOut

extension SignInVC {
    
    private func setUI() {
        settingTextField()
        settingButton()
    }
    
    private func settingTextField() {
        emailTextSet()
        usernNameTextSet()
        passwordTextSet()
    }
    
    private func emailTextSet() {
        detectUIStyle()
        
        emailText.layer.borderWidth = 0.7
        emailText.layer.borderColor = myColor.cgColor
        
        emailText.tintColor = .label
        
        emailText.layer.cornerRadius = 15.0
        emailText.layer.masksToBounds = true
    }
    
    private func usernNameTextSet() {
        detectUIStyle()
        
        userNameText.layer.borderWidth = 0.7
        userNameText.layer.borderColor = myColor.cgColor
        
        userNameText.tintColor = .label
        
        userNameText.layer.cornerRadius = 15.0
        userNameText.layer.masksToBounds = true
    }
    
    private func passwordTextSet() {
        detectUIStyle()
        
        passwordText.layer.borderWidth = 0.7
        passwordText.layer.borderColor = myColor.cgColor
        
        passwordText.tintColor = .label
        
        passwordText.layer.cornerRadius = 15.0
        passwordText.layer.masksToBounds = true
    }
    
    private func settingButton()  {
        logInButtonSet()
        signUpButtonSet()
    }
    
    private func logInButtonSet() {
        logInButton.tintColor = .white
        logInButton.backgroundColor = .systemMint
        
        // 將按鈕設置為圓弧狀
        logInButton.layer.cornerRadius = 15.0
        logInButton.layer.masksToBounds = true
    }
    
    private func signUpButtonSet() {
        signUpButton.tintColor = .white
        signUpButton.backgroundColor = .systemMint
        
        signUpButton.layer.cornerRadius = 15.0
        signUpButton.layer.masksToBounds = true
    }
    
}


// MARK: Light & Dark Mode LayOut

extension SignInVC {
    
    // 深色模式 設定 placeholder 文字屬性
    private func placeholderTextDarkMode() {
        emailSecondary()
        userNameSecondary()
        passwordSecondary()
    }
    
    private func emailSecondary() {
        emailText.attributedPlaceholder = NSAttributedString(
            string: "email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
        )
    }
    
    private func userNameSecondary() {
        userNameText.attributedPlaceholder = NSAttributedString(
            string: "username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
        )
    }
    
    private func passwordSecondary() {
        passwordText.attributedPlaceholder = NSAttributedString(
            string: "password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
        )
    }
    
    // 淺色模式 設定 placeholder 文字屬性
    private func placeholderTextlightMode() {
        emailGray()
        userNameGray()
        passwordGray()
    }
    
    private func emailGray() {
        emailText.attributedPlaceholder = NSAttributedString(
            string: "email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    private func userNameGray() {
        userNameText.attributedPlaceholder = NSAttributedString(
            string: "username",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    private func passwordGray() {
        passwordText.attributedPlaceholder = NSAttributedString(
            string: "password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    // viewDidload 明暗模式，切換 myColor 顏色
    private func detectUIStyle() {
        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            myColor = .black
            placeholderTextlightMode()
        case .dark:
            myColor = .white
            placeholderTextDarkMode()
        default:
            fatalError()
        }
    }
    
    // 實時偵測 light mode
    private func lightMode() {
        myColor = .black
        placeholderTextlightMode()
        
        emailText.layer.borderColor = myColor.cgColor
        userNameText.layer.borderColor = myColor.cgColor
        passwordText.layer.borderColor = myColor.cgColor
    }
    
    // 實時偵測 dark mode
    private func darkMode() {
        myColor = .white
        placeholderTextDarkMode()
        
        emailText.layer.borderColor = myColor.cgColor
        userNameText.layer.borderColor = myColor.cgColor
        passwordText.layer.borderColor = myColor.cgColor
    }
    
}


// MARK: Sign Up Methods

extension SignInVC {
    
    private func userSignIn(userExist: Bool) {
        blankfieldCheck(userExist: userExist)
    }
    
    private func blankfieldCheck(userExist: Bool) {
        if emailText.text != "" && userNameText.text != "" && passwordText.text != "" {
            logInOrSignUp(userExist: userExist)
        } else {
            makeAlert(titleInput: "Error", messageInput: "Username/Password/Email ?", vc: self)
        }
    }
    
    private func logInOrSignUp(userExist: Bool) {
        if userExist {
            logIn(userExist: userExist)
        } else {
            signUp(userExist: userExist)
        }
    }
    
    private func logIn(userExist: Bool) {
        Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!) { [self] auth, error in
            errorHandle(userExist: userExist, error: error)
        }
    }
    
    private func signUp(userExist: Bool) {
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!) { [self] auth, error in
            errorHandle(userExist: userExist, error: error)
        }
    }
    
    private func errorHandle(userExist: Bool, error: Error?) {
        if error != nil {
            makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Auth 過程發生錯誤", vc: self)
        } else {
            createUserOrNot(userExist: userExist)
        }
    }
    
    private func createUserOrNot(userExist: Bool) {
        if userExist == false {
            saveUserInfo()
        }
        self.performSegue(withIdentifier: "toFeedVC", sender: nil)
    }
    
    private func saveUserInfo() {
        let userDictionary = ["email": emailText.text!, "username": userNameText.text!] as! [String: Any]
        
        Firestore.firestore().collection("UserInfo").addDocument(data: userDictionary)
    }
    
}


// MARK: TextField Delegate

extension SignInVC: UITextFieldDelegate {
    
    private func textFieldDelegateSet() {
        emailText.delegate = self
        userNameText.delegate = self
        passwordText.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (string.containsValidCharacter)
    }
    
}
