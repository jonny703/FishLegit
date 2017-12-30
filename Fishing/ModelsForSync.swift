//
//  ModelsForSync.swift
//  Fishing
//
//  Created by John Nik on 12/29/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import Foundation

struct Infos: Decodable {
    let new_pins: [Info]?
    let edit_pins: [Info]?
}

struct Info: Decodable {
    let exceptions: exceptions?
    let features: features?
    let lakes: lakes?
    let zones_sandle: zones_sandle?
}

struct exceptions: Decodable {
    let id: Int?
    let details: String?
    let zone: String?
    let lon: String?
    let lat: String?
    let lakes: String?
    let townships: String?
}

struct features: Decodable {
    let id: Int?
    let lon: String?
    let lat: String?
    let species: String?
    let zones: String?
    let lakes: String?
    let townships: String?
}

struct lakes: Decodable {
    let id: Int?
    let name: String?
}

struct zones_sandle: Decodable {
    let id: Int?
    let zone: String?
    let species: String?
    let open: String?
    let closing: String?
    let open_close: String?
    let opening_week: String?
    let opening_day: String?
    let opening_month: String?
    let closing_week: String?
    let closing_day: String?
    let closing_month: String?
    let open2: String?
    let closing2: String?
    let open_close2: String?
    let opening_week2: String?
    let opening_day2: String?
    let opening_month2: String?
    let closing_week2: String?
    let closing_day2: String?
    let closing_month2: String?
    let limit1: String?
    let limit2: String?
    let limit3: String?
    let limit12: String?
    let limit22: String?
    let limit32: String?
    let limit4: String?
}
