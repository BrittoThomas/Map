//
//  MapBoxViewController.swift
//  Map
//
//  Created by Britto Thomas on 24/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapBoxViewController: UIViewController {
    
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "mapbox://styles/mapbox/streets-v11")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 59.31, longitude: 18.06), zoomLevel: 9, animated: false)
        self.view = mapView
        
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    }
}


extension MapBoxViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let mapView = self.view as? MGLMapView,
            let location = locations.last {
            mapView.setCenter(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), zoomLevel: 15, animated: true)
            mapView.showsUserLocation = true
        }
        self.locationManager.stopUpdatingLocation()
    }
}
