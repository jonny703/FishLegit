//
//  LakePlace.swift
//  Fishing
//
//  Created by John Nik on 14/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LakePlace {
    
    let lakeName: String
    let townshipName: String
    let coordinate: CLLocationCoordinate2D
    let opportunity: String
    let exception: String
    let distance: Double
    let type: String
    let typeId: String
    let species: String?
    
    init(lakeName: String, townshipName: String, opportunity: String, exception: String, coordinate: CLLocationCoordinate2D, distance: Double, type: String, typeId: String, species: String?) {
        self.lakeName = lakeName
        self.townshipName = townshipName
        self.opportunity = opportunity
        self.coordinate = coordinate
        self.exception = exception
        self.distance = distance
        self.type = type
        self.typeId = typeId
        self.species = species
    }
    
    
}
