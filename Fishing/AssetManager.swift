//
//  AssetManager.swift
//  Fishing
//
//  Created by John Nik on 12/8/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit

enum AssetName: String {
    
    case close = "close"
    case more = "more"
    case back = "back_icon"
    case moreSolid = "moreSolid"
    case alertIcon = "alert_icon"
    case done = "done"
    case cancelPicker = "cancelPicker"
    case checked = "checked"
    
}

class AssetManager {
    static let sharedInstance = AssetManager()
    
    static var assetDict = [String : UIImage]()
    
    class func imageForAssetName(name: AssetName) -> UIImage {
        let image = assetDict[name.rawValue] ?? UIImage(named: name.rawValue)
        assetDict[name.rawValue] = image
        return image!
    }
    
}
