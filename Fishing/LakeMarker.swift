//
//  LakeMarker.swift
//  Fishing
//
//  Created by John Nik on 14/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class LakeMarker: GMSMarker {
    
    let place: LakePlace
    
    init(place: LakePlace, type: String, isDraggable: Bool) {
        self.place = place
        super.init()
        
        position = place.coordinate
        
        if type == LakeType.opportunity.rawValue {
            icon = UIImage(named: "pin_lake")
            groundAnchor = CGPoint(x: 0, y: 1)
        } else {
            icon = UIImage(named: "pin_red")
            groundAnchor = CGPoint(x: 1, y: 1)
        }
        appearAnimation = .pop
        self.isDraggable = isDraggable
    }
    
}


