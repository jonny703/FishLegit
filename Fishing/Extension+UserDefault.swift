//
//  Extension+UserDefault.swift
//  Fishing
//
//  Created by John Nik on 11/11/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
extension UserDefaults {
    
    
    enum UserDefaultsKeys: String {
        case isLoggedIn
        case agreed
        case userId
        case fullname
        case username
        case firstname
        case lastname
        case email
        case password
        case isShownZoneBorders
    }
    
    //MARK: check login
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: show border
    
    func setIsShownZoneBorders(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isShownZoneBorders.rawValue)
        synchronize()
    }
    
    func isShownZoneBorders() -> Bool {
        return bool(forKey: UserDefaultsKeys.isShownZoneBorders.rawValue)
    }
    
    //MARK: agree disclaimar?
    
    func setAgreed(_ value: Bool) {
        set(value, forKey: UserDefaultsKeys.agreed.rawValue)
    }
    
    func isAgreed() -> Bool {
        return bool(forKey: UserDefaultsKeys.agreed.rawValue)
    }
    
    //MARK: save userid
    
    func setUserId(_ userId: String) {
        set(userId, forKey: UserDefaultsKeys.userId.rawValue)
        synchronize()
    }
    
    func getUserId() -> String? {
        if let userId = string(forKey: UserDefaultsKeys.userId.rawValue) {
            return userId
        }
        return nil
    }
    
    //MARK: save user full name
    func setUserFullName(_ fullname: String) {
        set(fullname, forKey: UserDefaultsKeys.fullname.rawValue)
        synchronize()
    }
    
    func getFullname() -> String? {
        if let fullname = string(forKey: UserDefaultsKeys.fullname.rawValue) {
            return fullname
        }
        return nil
    }
    
    //MARK: save username
    func setUsername(_ username: String) {
        set(username, forKey: UserDefaultsKeys.username.rawValue)
        synchronize()
    }
    
    func getUsername() -> String? {
        if let username = string(forKey: UserDefaultsKeys.username.rawValue) {
            return username
        }
        return nil
    }
    
    //MARK: save firstname
    func setFirstname(_ firstname: String) {
        set(firstname, forKey: UserDefaultsKeys.firstname.rawValue)
        synchronize()
    }
    
    func getFirstname() -> String? {
        if let firstname = string(forKey: UserDefaultsKeys.firstname.rawValue) {
            return firstname
        }
        return nil
    }
    
    //MARK: save lastname
    func setLastname(_ lastname: String) {
        set(lastname, forKey: UserDefaultsKeys.lastname.rawValue)
        synchronize()
    }
    
    func getLastname() -> String? {
        if let lastname = string(forKey: UserDefaultsKeys.lastname.rawValue) {
            return lastname
        }
        return nil
    }
    
    //MARK: save email
    func setEmail(_ email: String) {
        set(email, forKey: UserDefaultsKeys.email.rawValue)
        synchronize()
    }
    
    func getEmail() -> String? {
        if let email = string(forKey: UserDefaultsKeys.email.rawValue) {
            return email
        }
        return nil
    }
    
    //MARK: save user password
    func setPassword(_ password: String) {
        set(password, forKey: UserDefaultsKeys.password.rawValue)
        synchronize()
    }
    
    func getPassword() -> String? {
        if let password = string(forKey: UserDefaultsKeys.password.rawValue) {
            return password
        }
        return nil
    }
    
}
