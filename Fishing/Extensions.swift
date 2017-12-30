//
//  Extensions.swift
//  Fishing
//
//  Created by John Nik on 09/06/2017.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        
        self.init(red: r/255, green: g/255, blue: b/255, alpha: a)
        
    }
    
}

extension UIApplication {
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
}

extension Double {
//    var clean: String { return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.2f", self) : String(self) }
    
    var clean: String {
        return  String(format: "%.2f", self)
    }
    
    var cleanKm: String {
        return  String(format: "%d", self)
    }
    
}
