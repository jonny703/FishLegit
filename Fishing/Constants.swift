//
//  Constants.swift
//  Fishing
//
//  Created by John Nik on 02/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

let DEVICE_WIDTH = UIScreen.main.bounds.size.width
let DEVICE_HEIGHT = UIScreen.main.bounds.size.height

//var townships = [Township]()
var zonesKml = [[CLLocationCoordinate2D]]()
var townshipsWithMaxMin = [[String]]()
var townshipKml = [[CLLocationCoordinate2D]]()


let AgreeMessages = "FishLegit has made every attempt to achieve accurate and current information. This is proved on an \"as is\" basis with no guarantees of completeness, accuracy usefulness, or timeliness and without any warranties of any kind whatsoever express or implied. It is your responsibility to be in compliance with current regulations obtained at your local ministry of natural resources. We are not affiliated with them nor endorsed by them. FishLegit assumes no responsibility or liability for any errors or omissions in the content of this site. Use at your own risk."

enum EFHandleType {
    case EFSemiTransparentWhiteCircle
    case EFSemiTransparentBlackCircle
    case EFDoubleCircleWithOpenCenter
    case EFDoubleCircleWithClosedCenter
    case EFBigCircle
}

enum SpeciesViewStatus {
    case show
    case hide
}

enum ParseStatus {
    case Township
    case Zone
}

enum ParseStatusForZone {
    case zone
    case zoneForBorders
}

enum SearchControllerStatus {
    case Distance
    case Species
}

struct SearchStatus {
    static let Lake = "lake"
    static let Township = "township"
    static let Species = "species"
    static let Other = "other"
    static let EditLake = "edit_lake"
}


extension UIView {
    
    func addSubViewWithBounce(theView: UIView) {
        theView.transform = CGAffineTransform.identity
        theView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        
        theView.center = self.center
        self.addSubview(theView)
        
        UIView.animate(withDuration: 0.4 / 1.5, animations: {
            theView.transform = CGAffineTransform.identity
            theView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (finished) in
            UIView.animate(withDuration: 0.4 / 2, animations: {
                theView.transform = CGAffineTransform.identity
                theView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.4 / 2, animations: { 
                    theView.transform = CGAffineTransform.identity
                })
            })
        }
        
    }
    
    func removeFromSuperViewWithBounce() {
        
        UIView.animate(withDuration: 0.4 / 1.5, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (finished) in
            UIView.animate(withDuration: 0.4 / 2, animations: {
                self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.4 / 2, animations: {
                    self.removeFromSuperview()
                })
            })
        }
    }
}
