//
//  UserModel.swift
//  SnapChatClone
//
//  Created by Terry Jason on 2023/8/29.
//

import Foundation

class UserModel {
    
    static let sharedUserInfo = UserModel()
    
    var email = ""
    var username = ""
    
    private init() {}
    
}
