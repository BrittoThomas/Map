//
//  GoogleMapViewController.swift
//  Map
//
//  Created by Britto Thomas on 23/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation


class GoogleMapViewController: UIViewController {
    
    // You don't need to modify the default init(nibName:bundle:) method.
    var locationManager = CLLocationManager()
    var firstCordinate:CLLocationCoordinate2D?
    var secondCordinate:CLLocationCoordinate2D?
    
    override func loadView() {
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        
        //Map Style
        
        
        do {
          // Set the map style by passing the URL of the local file.
          if let styleURL = Bundle.main.url(forResource: "Style", withExtension: "json") {
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
            NSLog("Unable to find style.json")
          }
        } catch {
          NSLog("One or more of the map styles failed to load. \(error)")
        }

        view = mapView
        
        
        /*
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
         */
        
        //Location Manager code to fetch current location
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()

    }
    
}

extension GoogleMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        print("long tap")
        if firstCordinate == nil {
            firstCordinate = coordinate
            return
        }else{
            if secondCordinate != nil {
                firstCordinate = secondCordinate
            }
            secondCordinate = coordinate
        }
        self.fetchRoute(from: firstCordinate!, to: secondCordinate!)
    }
}

extension GoogleMapViewController: CLLocationManagerDelegate {
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let mapView = self.view as? GMSMapView,
            let location = locations.last {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15.0)
            mapView.animate(to: camera)
        }
        
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        
        let session = URLSession.shared
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=AIzaSyCEU91SqjFqLPcQqQfvFQ8Y0bLmWgPibWU")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            let path = Bundle.main.path(forResource: "SampleGoogleDirectionAPIResponse", ofType: "json")!
            let dataJSON = try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            //let json = try! JSON.init(data: data)
            
            guard let jsonResult = try? JSONSerialization.jsonObject(with: dataJSON, options: .allowFragments) as? [String: Any], let jsonResponse = jsonResult else {
                print("error in JSONSerialization")
                return
            }
            
            guard let routes = jsonResponse["routes"] as? [Any] else {
                return
            }
            
            guard let route = routes.first as? [String: Any] else {
                return
            }
            
            guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
                return
            }
            
            guard let polyLineString = overview_polyline["points"] as? String else {
                return
            }
            
            //Call this method to draw path on map
            self.drawPath(from: polyLineString)
        })
        task.resume()
    }
    
    func drawPath(from polyStr: String){
        
        guard let mapView = self.view as? GMSMapView else {
            return
        }
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3.0
        polyline.map = mapView // Google MapView
    }
}
