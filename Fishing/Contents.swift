//
//  Contents.swift
//  Fishing
//
//  Created by John Nik on 11/6/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

class Contents: NSObject {
    var id: String?
    var lakeName: String?
    var zoneName: String?
    var townshipName: String?
    var kind: String?
    var species: String?
    var latitude: Double?
    var longitude: Double?
    var detail: String?
}

struct Pin: Decodable {
    let id: String?
    let user_id: String?
    let name: String?
    let lon: String?
    let lat: String?
    let created: String?
    let active: String?
    let type: String?
    let zone: String?
    let township: String?
    let detail: String?
}

//    {"id":"17","user_id":"13","name":"lake","lon":"12.32","lat":"332.32","created":"0000-00-00 00:00:00","active":"1","type":"opportunity","zone":"15","township":"town","detail":"detail"}

