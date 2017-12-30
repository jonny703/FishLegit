//
//  StyleGuideManager.swift
//  Fishing
//
//  Created by John Nik on 12/8/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit



public class StyleGuideManager {
    private init(){}
    
    static let sharedInstance : StyleGuideManager = {
        let instance = StyleGuideManager()
        return instance
    }()
    
    //fishing default color
    static let fishLegitDefultBlueColor = UIColor(r: 89, g: 108, b: 190)
    static let fishLegitDefultGreenColor = UIColor(r: 65, g: 249, b: 1)
    static let fishLegitDefultAlphaGreenColor = UIColor(r: 175, g: 251, b: 153)
    static let keyboardBackgroundColor = UIColor(r: 204, g: 210, b: 215)
    
    static let fishLegitBartintColor = UIColor(r: 63, g: 81, b: 181)
    
    
    static let signinButtonColor = UIColor(r: 0, g: 81, b: 86)
    
    //Buttons Colors
    static let signupButtonColor = UIColor(r: 1, g: 128, b: 255, a: 1)
    static let editProfileButtonColor = UIColor(r: 105, g: 140, b: 208)
    
    //dateView colors
    static let dateViewColor = UIColor(r: 60, g: 62, b: 74)
    static let profileBackgroundColor = UIColor(r: 67, g: 91, b: 119)
    static let profileControllerBackgroundColor = UIColor(r: 77, g: 136, b: 194, a: 0.7)
    
    //setting colors
    static let sectionColor = UIColor(r: 37, g: 39, b: 51)
    
    //scrollview color
    static let profileScrollViewColor = UIColor(r: 129, g: 172, b: 212)
    
    //dateLabel color
    static let dateLabelColor = UIColor(r: 0, g: 116, b: 240)
    
    //Login
    static let floatingSpaceinLabelFont = UIFont(name: "Helvetica-Bold", size: 72)
    

    
    
    //Fonts
    func loginFontLarge() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 30)!

    }
    
    func loginPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 15)!
    }
    
    func loginPageSmallFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 13)!
    }
    
    func askLocationViewFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    //MARK: - Forgot Password
    
    func forgotPasswordPageFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 17)!
    }
    
    //MARK: - Profile
    func profileNameLabelFont() -> UIFont {
        return UIFont(name: "Helvetica", size: 20)!
    }
    
    func profileSublabelFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 16)!
    }
    
    func profileBioFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 14)!
    }
    
    func profileNotificationsFont() -> UIFont {
        return UIFont(name: "Helvetica Light", size: 10)!
    }
}


