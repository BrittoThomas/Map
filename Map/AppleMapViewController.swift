//
//  AppleMapViewController.swift
//  Map
//
//  Created by Britto Thomas on 24/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AppleMapViewController: UIViewController {

    var locationManager: CLLocationManager = CLLocationManager()

    
    //The range (meter) of how much we want to see arround the user's location
    let distanceSpan: Double = 500
    
    var firstCordinate:CLLocationCoordinate2D?
    var secondCordinate:CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view = mapView
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
    
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        guard let mapView = self.view as? MKMapView,
            let _ = mapView.userLocation.location?.coordinate else {
            return
        }
        
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            if firstCordinate == nil {
                firstCordinate = locationOnMap
                return
            }else{
                if secondCordinate != nil {
                    firstCordinate = secondCordinate
                }
                secondCordinate = locationOnMap
            }
            
            self.showRouteOnMap(pickupCoordinate: firstCordinate!, destinationCoordinate: secondCordinate!)
        }
    }
    
    
    
}

extension AppleMapViewController:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let mapView = self.view as? MKMapView,
            let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        }
        self.locationManager.stopUpdatingLocation()
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        guard let mapView = self.view as? MKMapView else {
            return
        }
        
        let allAnnotations = mapView.annotations
        let allOverlay = mapView.overlays
        mapView.removeAnnotations(allAnnotations)
        mapView.removeOverlays(allOverlay)
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

}


// MARK: - MKMapViewDelegate
extension AppleMapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}
