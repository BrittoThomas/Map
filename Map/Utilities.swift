//
//  Utilities.swift
//  Map
//
//  Created by Britto Thomas on 24/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import Foundation
import CoreLocation

func fillCSV() -> Array<Dictionary<AnyHashable,Any>>? {
    
    let file = Bundle.main.path(forResource: "LAT-LONG", ofType: "csv")
    
    var content: String? = nil
    do {
        content = try String(contentsOfFile: file ?? "", encoding: .utf8)
    } catch {
        return nil
    }
    let rows = content?.components(separatedBy: CharacterSet(charactersIn: "\n"))
    let trimStr = "\n\r "
    let character = ","
    let keys = trimComponents(rows?[0].components(separatedBy: CharacterSet(charactersIn: character)), withCharacters: trimStr)
    var array : Array<Dictionary<AnyHashable,Any>> = []
    for i in 1..<(rows?.count ?? 0) - 1 {
        
        if let objects = trimComponents(rows?[i].components(separatedBy: CharacterSet(charactersIn: character)), withCharacters: trimStr),
            let keys = keys as? [NSCopying] {
            let dicationary = NSDictionary.init(objects: objects, forKeys: keys)
            array.append(dicationary as! Dictionary<AnyHashable, Any>)
        }
    }
    return array
}


func trimComponents(_ array: [Any]?, withCharacters characters: String?) -> [Any]? {
    var marray = [AnyHashable](repeating: 0, count: array?.count ?? 0)
    (array as NSArray?)?.enumerateObjects({ obj, idx, stop in
        marray.append((obj as AnyObject).trimmingCharacters(in: CharacterSet(charactersIn: characters ?? "")))
    })
    return marray
}


func convertString(toFloat str: String?) -> Float {
    return Float(str?.components(separatedBy: CharacterSet(charactersIn: "\"\"")).joined(separator: "") ?? "") ?? 0.0
}

func angle(fromCoordinate first: CLLocationCoordinate2D, toCoordinate second: CLLocationCoordinate2D) -> Float {
    
    let deltaLongitude = Float(second.longitude - first.longitude)
    let deltaLatitude = Float(second.latitude - first.latitude)
    let angle: Float = (.pi * 0.5) - atan(deltaLatitude / deltaLongitude)
    
    if deltaLongitude > 0 {
        return angle
    } else if deltaLongitude < 0 {
        return angle + .pi
    } else if deltaLatitude < 0 {
        return .pi
    }
    
    return 0.0
}




