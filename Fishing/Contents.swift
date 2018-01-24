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
    var typeId: String?
    var species: String?
    var latitude: Double?
    var longitude: Double?
    var detail: String?
}

struct Pin: Decodable {
    let id: String?
    let user_id: String?
    let lake_id: String?
    let name: String?
    let lon: String?
    let lat: String?
    let created: String?
    let active: String?
    let edit_new: String?
    let type: String?
    let zone: String?
    let township: String?
    let detail: String?
    
    let id2: String?
    let user_id2: String?
    let lake_id2: String?
    let name2: String?
    let lon2: String?
    let lat2: String?
    let created2: String?
    let active2: String?
    let edit_new2: String?
    let type2: String?
    let zone2: String?
    let township2: String?
    let detail2: String?
}

/*
id: "92",
user_id: "24",
lake_id: "0",
name: "1369",
lon: "-79.925414",
lat: "43.243765",
created: "2018-01-24 02:00:16",
active: "-1",
type: "Opportunity",
edit_new: "New",
zone: "16",
township: "747",
detail: "Aaaa",
id2: "92",
user_id2: "24",
lake_id2: "0",
name2: "1369",
lon2: "",
lat2: "",
created2: "2018-01-24 02:00:16",
active2: "-1",
type2: "Opportunity",
zone2: "",
township2: "",
detail2: "Aaaa"
*/

//    {"id":"17","user_id":"13","name":"lake","lon":"12.32","lat":"332.32","created":"0000-00-00 00:00:00","active":"1","type":"opportunity","zone":"15","township":"town","detail":"detail"}

