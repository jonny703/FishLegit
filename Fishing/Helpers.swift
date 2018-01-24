//
//  Helpers.swift
//  Fishing
//
//  Created by John Nik on 27/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.

import UIKit

func getIdWithName(name: String, tableName: String) -> Int {
    SCSQLite.initWithDatabase("fishy.sqlite3")
    let query = "SELECT id, name FROM " + tableName + " where name=" + "\"" + name + "\""
    let array = SCSQLite.selectRowSQL(query)! as NSArray
    let dictionary = array[0] as! NSDictionary
    let id = dictionary.value(forKey: "id") as! Int
    return id
}

func getIdStringWithName(name: String, tableName: String) -> String {
    SCSQLite.initWithDatabase("fishy.sqlite3")
    let query = "SELECT id, name FROM " + tableName + " where name like" + "\"%" + name + "%\""
    let array = SCSQLite.selectRowSQL(query)! as NSArray
    
    if array.count > 0 {
        let dictionary = array[0] as! NSDictionary
        let id = dictionary.value(forKey: "id") as! Int
        return String(id)
    } else {
        return "0"
    }
}

func convertDateFormatWith(dateStr: String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd"
    let date = dateFormatter.date(from: dateStr)
    dateFormatter.dateFormat = "MMMM d"
    return dateFormatter.string(from: date!)
    
}

func convertDayofWeek(dateStr: String) -> String? {
    
    let dateString = "2017 " + dateStr
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy MMMM d"
    guard let date = formatter.date(from: dateString) else { return nil }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: date)
    let weekMonth = myCalendar.component(.weekOfMonth, from: date)
    
    var weekDayStr: String
    var weekMonthStr: String
    
    if weekDay == 2 {
        weekDayStr = "Monday"
    } else if weekDay == 3 {
        weekDayStr = "Tuesday"
    } else if weekDay == 4 {
        weekDayStr = "Wednesday"
    } else if weekDay == 5 {
        weekDayStr = "Thursday"
    } else if weekDay == 6 {
        weekDayStr = "Friday"
    } else if weekDay == 7 {
        weekDayStr = "Saturday"
    } else if weekDay == 1 {
        weekDayStr = "Sunday"
    } else {
        weekDayStr = ""
    }
    
    if weekMonth == 1 {
        weekMonthStr = "First "
    } else if weekMonth == 2 {
        weekMonthStr = "Second "
    } else if weekMonth == 3 {
        weekMonthStr = "Third "
    } else if weekMonth == 4 {
        weekMonthStr = "Fourth "
    } else if weekMonth == 5 {
        weekMonthStr = "Fifth "
    } else {
        weekMonthStr = ""
    }
        
    
    
    return weekMonthStr + weekDayStr
}

func fetchZoneInfoWith(selectedZone: String, selectedSpecies: String) -> String {
    
    SCSQLite.initWithDatabase("fishy.sqlite3")
    let query = String(format: "SELECT * FROM zones_sandl where zone=%@ AND species=%@", selectedZone, selectedSpecies)
    let array = SCSQLite.selectRowSQL(query)! as NSArray
    
    var open = ""
    var closing = ""
    var open_close = ""
    var opening_day = ""
    var opening_month = ""
    var opening_day2 = ""
    var opening_month2 = ""
    var open2 = ""
    var closing2 = ""
    var limit1 = ""
    var limit2 = ""
    var limit3 = ""
    var limit12 = ""
    var limit22 = ""
    var limit32 = ""
    
    if array.count > 0 {
        let dictionary = array[0] as! NSDictionary
        open = dictionary.value(forKey: "open") as! String
        closing = dictionary.value(forKey: "closing") as! String
        open_close = dictionary.value(forKey: "open_close") as! String
        opening_day = dictionary.value(forKey: "opening_day") as! String
        opening_month = dictionary.value(forKey: "opening_month") as! String
        opening_day2 = dictionary.value(forKey: "opening_day2") as! String
        opening_month2 = dictionary.value(forKey: "opening_month2") as! String
        open2 = dictionary.value(forKey: "open2") as! String
        closing2 = dictionary.value(forKey: "closing2") as! String
        limit1 = dictionary.value(forKey: "limit1") as! String
        limit2 = dictionary.value(forKey: "limit2") as! String
        limit3 = dictionary.value(forKey: "limit3") as! String
        limit12 = dictionary.value(forKey: "limit12") as! String
        limit22 = dictionary.value(forKey: "limit22") as! String
        limit32 = dictionary.value(forKey: "limit32") as! String
    }
    
    
    if open != "" {
        open = convertDateFormatWith(dateStr: open)
    }
    if closing != "" {
        closing = convertDateFormatWith(dateStr: closing)
    }
    if open2 != "" {
        open2 = convertDateFormatWith(dateStr: open2)
    }
    if closing2 != "" {
        closing2 = convertDateFormatWith(dateStr: closing2)
    }
    
    
    var zoneInfo = ""
    if opening_day != "" {
        zoneInfo += "Open Seasons: "
        
        
        
//        zoneInfo += opening_day + " in " + opening_month + " "
//        if open != "" {
//            zoneInfo += open + " to " + closing + " "
//        }
        
        if open != "" {
            zoneInfo += convertDayofWeek(dateStr: open)! + " in " + opening_month + " "
            zoneInfo += " to " + closing + " "
        }
        
        
        if opening_day2 != "" {
            if open != "" {
                zoneInfo += " & ";
//                zoneInfo += opening_day2 + " in " + opening_month2 + " "
                
                zoneInfo += convertDayofWeek(dateStr: open2)! + " in " + opening_month2 + " "
            }
        }
    } else {
        if open != "" {
            zoneInfo += "Open Seasons: "
            zoneInfo += open + " to " + closing + " "
            if opening_day2 != "" {
                if open != "" {
                    zoneInfo += " & ";
//                    zoneInfo += opening_day2 + " in " + opening_month2 + " "
                    zoneInfo += convertDayofWeek(dateStr: open2)! + " in " + opening_month2 + " "
                }
            }
        }
    }
    if open_close != "" && zoneInfo == "" {
        zoneInfo += "Open Seasons: "
    }
    zoneInfo += open_close
    
    if open2 != "" {
        
        if opening_day2 != "" {
            zoneInfo += " to " + closing2 + " "
        } else {
            zoneInfo += open2 + " to " + closing2 + " "
        }
        
        
    }
    
    if limit1 != "" {
        zoneInfo += "\nLimits : "
        
        zoneInfo += limit1 + "-" + limit2 + "; " + limit3
        if limit12 != "" {
            zoneInfo += limit12 + "-" + limit22 + "; " + limit32 + "\n"
        }
    } else {
        
        if limit12 != "" {
            zoneInfo += "\nLimits : "
            zoneInfo += limit12 + "-" + limit22 + "; " + limit32 + "\n"
        }
    }
    
    if zoneInfo == "" {
        zoneInfo = "No Data"
    }
    
    return zoneInfo
}
