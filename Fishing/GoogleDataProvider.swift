//
//  GoogleDataProvider.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.

import Foundation
import UIKit
import CoreLocation

enum LakeType: String {
    case opportunity = "Opportunity"
    case exception = "Exception"
}

class GoogleDataProvider {
    
    func fetchLakesWithKind(kind: String, id: Int, currentTownship: String, coordinate: CLLocationCoordinate2D, radius: Double, completion: @escaping (([LakePlace]) -> Void)) -> () {
        
        let mylocation = coordinate
        var placesArray = [LakePlace]()
        var places = [[String: Any]]()
        
        SCSQLite.initWithDatabase("fishy.sqlite3")
        
        var opportunityQuery = ""
        var exceptionQuery = ""
        
        if kind == SearchStatus.Lake || kind == SearchStatus.EditLake {
            opportunityQuery = String(format: "SELECT a.id, a.lon, a.lat, a.species, a.townships, b.name FROM features a INNER JOIN lakes b ON a.lakes=b.id where a.lakes=%d", id)
            
            exceptionQuery = String(format: "SELECT a.id, a.lon, a.lat, a.details, a.townships, b.name FROM exceptions a INNER JOIN lakes b ON a.lakes=b.id where a.lakes=%d", id)
        } else if kind == SearchStatus.Township {
            opportunityQuery = String(format: "SELECT a.id, a.lon, a.lat, a.species, a.townships, b.name FROM features a INNER JOIN lakes b ON a.lakes=b.id where a.townships=%d", id)
            
            exceptionQuery = String(format: "SELECT a.id, a.lon, a.lat, a.details, a.townships, b.name FROM exceptions a INNER JOIN lakes b ON a.lakes=b.id where a.townships=%d", id)
        } else if kind == SearchStatus.Species {
            opportunityQuery = String(format: "SELECT a.id, a.lon, a.lat, a.species, a.townships, b.name FROM features a INNER JOIN lakes b ON a.lakes=b.id where a.species=%d", id)
        } else if kind == SearchStatus.Other {
            opportunityQuery = "SELECT a.id, a.lon, a.lat, a.species, a.townships, b.name FROM features a INNER JOIN lakes b ON a.lakes=b.id"
            
            exceptionQuery = "SELECT a.id, a.lon, a.lat, a.details, a.townships, b.name FROM exceptions a INNER JOIN lakes b ON a.lakes=b.id"
        }
        
        let opportunityArray: NSArray = SCSQLite.selectRowSQL(opportunityQuery)! as NSArray
        let exceptionArray: NSArray = SCSQLite.selectRowSQL(exceptionQuery)! as NSArray
        
        
        
        for i in 0  ..< (opportunityArray.count)  {
            
            let dictionary = opportunityArray[i] as! NSDictionary
            let lon = dictionary.value(forKey: "lon") as? String
            let lat = dictionary.value(forKey: "lat") as? String
            let lakeName = dictionary.value(forKey: "name") as? String
            let specyId = dictionary.value(forKey: "species") as? String
            let townshipStr = dictionary.value(forKey: "townships") as? String
            guard let typeId = dictionary.value(forKey: "id") as? Int else { return }
            
            if lon != "" {
                if let lon = lon, let lat = lat {
                    if let lonNumber = Double(lon), let latNumber = Double(lat) {
                        let lonNumber3 = self.getLocationDegreeWith(number: lonNumber)
                        let latNumber3 = self.getLocationDegreeWith(number: latNumber)
                        
                        let dis = self.getDistanceBetweenLakesWith(lat: latNumber3, lon: lonNumber3, myLoation: mylocation)
                        let place: [String: Any] = self.getPlaceWith(townshipStr: townshipStr, specyId: specyId, detail: "", lakeName: lakeName!, latNumber3: latNumber3, lonNumber3: lonNumber3, dis: dis, type: LakeType.opportunity.rawValue, typeId: String(typeId))
                        
                        if kind == SearchStatus.EditLake {
                            places.append(place)
                        } else {
                            if dis <= radius {
                                places.append(place)
                            }
                        }
                        
                    }
                }
            } else {
                
                let place: [String: Any] = self.getPlaceWith(townshipStr: townshipStr, specyId: specyId, detail: "", lakeName: lakeName!, latNumber3: 0, lonNumber3: 0, dis: 40000, type: LakeType.opportunity.rawValue, typeId: String(typeId))
                if kind == SearchStatus.EditLake {
                    places.append(place)
                } else {
                    if townshipStr == currentTownship {
                        places.append(place)
                    }
                }
                
            }
        
        }
        
        for i in 0  ..< (exceptionArray.count)  {
            
            let dictionary = exceptionArray[i] as! NSDictionary
            
            let lon = dictionary.value(forKey: "lon") as? String
            let lat = dictionary.value(forKey: "lat") as? String
            let lakeName = dictionary.value(forKey: "name") as? String
            let detail = dictionary.value(forKey: "details") as? String
            let townshipStr = dictionary.value(forKey: "townships") as? String
            guard let typeId = dictionary.value(forKey: "id") as? Int else { return }
            
            if lon != "" {
                if let lon = lon, let lat = lat {
                    if let lonNumber = Double(lon), let latNumber = Double(lat) {
                        let lonNumber3 = self.getLocationDegreeWith(number: lonNumber)
                        let latNumber3 = self.getLocationDegreeWith(number: latNumber)
                        
                        let dis = self.getDistanceBetweenLakesWith(lat: latNumber3, lon: lonNumber3, myLoation: mylocation)
                        let place: [String: Any] = self.getPlaceWith(townshipStr: townshipStr, specyId: "", detail: detail, lakeName: lakeName!, latNumber3: latNumber3, lonNumber3: lonNumber3, dis: dis, type: LakeType.exception.rawValue, typeId: String(typeId))
                        if kind == SearchStatus.EditLake {
                            places.append(place)
                        } else {
                            if dis <= radius {
                                places.append(place)
                            }
                        }
                    }
                }
            } else {
                let place: [String: Any] = self.getPlaceWith(townshipStr: townshipStr, specyId: "", detail: detail, lakeName: lakeName!, latNumber3: 0, lonNumber3: 0, dis: 40000, type: LakeType.exception.rawValue, typeId: String(typeId))
                if kind == SearchStatus.EditLake {
                    places.append(place)
                } else {
                    if townshipStr == currentTownship {
                        places.append(place)
                    }
                }
            }
        }
        
        for var place: [String: Any] in places {
            
            let lakePlace = LakePlace(lakeName: place["lakeName"] as! String, townshipName: place["townshipName"] as! String, opportunity: place["opportunity"] as! String, exception: place["exception"] as! String, coordinate: place["coordinate"] as! CLLocationCoordinate2D, distance: place["distance"] as! Double, type: place["type"] as! String, typeId: place["typeId"] as! String, species: place["species"] as? String)
            
            placesArray.append(lakePlace)
        }

        placesArray.sort { (lakePlace1, lakePlace2) -> Bool in
            
            return lakePlace1.distance < lakePlace2.distance
            
        }
        
        DispatchQueue.main.async {
            completion(placesArray)
        }
    }
    
    func getPlaceWith(townshipStr: String?, specyId: String?, detail: String?, lakeName: String, latNumber3: Double, lonNumber3: Double, dis: Double, type: String, typeId: String) -> [String: Any] {
        
        var townshipName = ""
        if let townshipId = townshipStr {
            townshipName = self.getTownshipNameWith(townshipId: townshipId)
        }
        
        var specyName = ""
        if let specyId = specyId {
            specyName = self.getSpecyNameWith(specyId: specyId)
        }
        
        if type == LakeType.opportunity.rawValue {
            let opportunity = self.getOpportunityWith(specyName: specyName, lat: latNumber3, lan: lonNumber3)
            
            let place: [String: Any] = ["lakeName":  lakeName, "townshipName": townshipName, "coordinate": CLLocationCoordinate2D(latitude: CLLocationDegrees(latNumber3), longitude: CLLocationDegrees(lonNumber3)), "specyName": specyName, "distance": dis, "opportunity": opportunity, "exception": "", "type": type, "typeId": typeId, "species": specyName]
            return place
        } else {
            let exception = self.getExceptionWith(detail: detail!, townshipName: townshipName)
            
            let place: [String: Any] = ["lakeName":  lakeName, "townshipName": townshipName, "coordinate": CLLocationCoordinate2D(latitude: CLLocationDegrees(latNumber3), longitude: CLLocationDegrees(lonNumber3)), "specyName": specyName, "distance": dis, "opportunity": "", "exception": exception, "type": type, "typeId": typeId, "species": ""]
            return place
        }
    }
    
    func getDistanceBetweenLakesWith(lat: Double, lon: Double, myLoation: CLLocationCoordinate2D) -> Double {
        let lakeLocation = CLLocation(latitude: lat, longitude: lon)
        let myCLlocation = CLLocation(latitude: myLoation.latitude, longitude: myLoation.longitude)
        
        let dis = myCLlocation.distance(from: lakeLocation) / 1000
        
        return dis
    }
    
    func getLocationDegreeWith(number: Double) -> Double {
        
        let lonNumber1 = Int(number)
        let lonNumber2 = number - Double(lonNumber1)
        let lonNumber3 = Double(lonNumber1) + Double(lonNumber2) * 100.0 / 60.0
        
        return lonNumber3
    }
    
    func getExceptionWith(detail: String, townshipName: String) -> String {
        
        var exception = ""
        exception += "Exception: " + (detail.replacingOccurrences(of: "\\r\\n", with: " "))
        if townshipName != "" {
            exception += " of the " + townshipName
        }
        return exception
        
    }
    
    func getOpportunityWith(specyName: String, lat: Double, lan: Double) -> String {
        
        let latStr = lat.clean
        let lonStr = lan.clean
        
        var opportunity = ""
        
        if specyName != "" {
            
            if latStr == "0.00" {
                opportunity += "Opportunity: " + "You can fish for " + specyName
            } else {
                opportunity += "Opportunity: " + "You can fish for " + specyName + " at " + latStr + ", " + lonStr
            }
            
            
        }
        return opportunity
        
    }
    
    func getSpecyNameWith(specyId: String) -> String {
        var specyName = ""
        let query3 = String(format: "SELECT name FROM species where id=%@", specyId)
        let array3 = SCSQLite.selectRowSQL(query3)! as NSArray
        if array3.count > 0 {
            let dictionary = array3[0] as! NSDictionary
            specyName = dictionary.value(forKey: "name") as! String
        }
        return specyName
    }
    
    func getTownshipNameWith(townshipId: String) -> String {
        
        var townshipName = ""
        
        let query3 = String(format: "SELECT name FROM townships where id=%@", townshipId)
        let array3 = SCSQLite.selectRowSQL(query3)! as NSArray
        if array3.count > 0 {
            let dictionary = array3[0] as! NSDictionary
            townshipName = dictionary.value(forKey: "name") as! String

        }

        
        return townshipName
        
    }
    
    func getTownshipCoordinatesWith(townshipId: String, type: String) -> String {
        
        var average = ""
        
        let query = String(format: "SELECT name FROM townships where id=%d", Int(townshipId)!)
        let array = SCSQLite.selectRowSQL(query)! as NSArray
        if array.count > 0 {
            let dictionary = array[0] as! NSDictionary
            var townshipName = dictionary.value(forKey: "name") as! String
            
            if townshipName.count > 9 {
                let endIndex = townshipName.index(townshipName.endIndex, offsetBy: -9)
//                townshipName = townshipName.substring(to: endIndex)
                townshipName = String(townshipName[..<endIndex])
                townshipName = townshipName.replacingOccurrences(of: " ", with: "")
                townshipName = townshipName.uppercased()
            }
            
            for i in 0 ..< townshipsWithMaxMin.count {
                if townshipName == townshipsWithMaxMin[i][0].replacingOccurrences(of: "\"", with: "") {
                    
                    if type == "lon" {
                        
                        average = String((Double(townshipsWithMaxMin[i][1])! + Double(townshipsWithMaxMin[i][2])!) / 2)
                        
                    } else {
                        average = String((Double(townshipsWithMaxMin[i][4])! + Double(townshipsWithMaxMin[i][3])!) / 2)
                    }
                    
                }
                
            }

        }
        return average
    }
    
    func deg2rad(deg:Double) -> Double {
        return deg * Double.pi / 180
    }
    
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / Double.pi
    }
    
    func distance(lat1:Double, lon1:Double, lat2:Double, lon2:Double, unit:String) -> Double {
        let theta = lon1 - lon2
        var dist = sin(deg2rad(deg: lat1)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        
        if unit == "K" {
            dist = dist * 1.609344
        }
        else if unit == "N" {
            dist = dist * 0.8684
        }
        
        
        return dist
    }

    
}
