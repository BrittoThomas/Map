//
//  MapCarAnnotation.swift
//  Map
//
//  Created by Britto Thomas on 24/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import UIKit
import MapKit


class MapCarAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}


class CarAnnotationView : MKAnnotationView {
    var btnInfo: UIButton!
}

