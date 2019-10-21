//
//  AppleMapCarViewController.swift
//  Map
//
//  Created by Britto Thomas on 28/05/19.
//  Copyright © 2019 Britto Thomas. All rights reserved.
//

import UIKit
import MapKit

class AppleMapCarViewController: UIViewController {
    
    
    //The range (meter) of how much we want to see arround the user's location
    let distanceSpan: Double = 500
    var firstCordinate:CLLocationCoordinate2D?
    var secondCordinate:CLLocationCoordinate2D?
    
    //Car Annotation
    var arr: [MapCarAnnotation] = []
    var arrayCSV: Array<Dictionary<AnyHashable,Any>> = []
    var index: Int = 0
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view = mapView
        
        self.setUpAnnotation()
    }
    
    
    func setUpAnnotation() {
        arr = [MapCarAnnotation]()
        arrayCSV = fillCSV() ?? []
        
        let latitude = CLLocationDegrees(convertString(toFloat: arrayCSV[0]["\"Latitude\""] as? String))
        let longitude = CLLocationDegrees(convertString(toFloat: arrayCSV[0]["\"Longitude\""] as? String))
        let location = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        
        let span = MKCoordinateSpan.init(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        let mapAnnot = MapCarAnnotation(coordinate: location, title: "Hello", subtitle: "New Hello")
        
        arr.append(mapAnnot)
        
        let regionInfo = MKCoordinateRegion.init(center: location, span: span)
        print("Latitude : \(longitude), Longitude : \(location)")
        
        if let mapView = self.view as? MKMapView {
            mapView.addAnnotation(mapAnnot)
            mapView.setRegion(regionInfo, animated: true)
        }
        
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateLocation), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateLocation() {
        
        let myAnnotation: MapCarAnnotation? = arr[0]
        
        let oldLocation: CLLocationCoordinate2D
        var newLocation: CLLocationCoordinate2D
        
        if index == 350 {
            timer?.invalidate()
        } else if index > 0 {
            
            let latitude = CLLocationDegrees(convertString(toFloat: arrayCSV[index - 1]["\"Latitude\""] as? String ))
            let longitude = CLLocationDegrees(convertString(toFloat: arrayCSV[index - 1]["\"Longitude\""] as? String))
            oldLocation = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
            
            let newLatitude = CLLocationDegrees(convertString(toFloat: arrayCSV[index]["\"Latitude\""] as? String))
            let newLongitude = CLLocationDegrees(convertString(toFloat: arrayCSV[index]["\"Longitude\""] as? String))
            newLocation = CLLocationCoordinate2D.init(latitude: newLatitude, longitude: newLongitude)
            
            let getAngle = angle(fromCoordinate: oldLocation, toCoordinate: newLocation)
            
            UIView.animate(withDuration: 2, animations: {
                myAnnotation?.coordinate = newLocation
                if let mapView = self.view as? MKMapView,
                    let annotation = myAnnotation {
                    let annotationView = mapView.view(for: annotation) as? CarAnnotationView
                    annotationView?.transform = CGAffineTransform(rotationAngle: CGFloat(getAngle))
                }
            })
        }
        
        index += 1
    }
}

// MARK: - MKMapViewDelegate
extension AppleMapCarViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
        } else {
            
            let annotationIdentifier = "CustomViewAnnotation"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? CarAnnotationView
            
            if annotationView == nil {
                
                annotationView = CarAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                let pinIcon = UIImage(named: "carIcon")
                annotationView?.btnInfo = UIButton()
                annotationView?.frame = CGRect(x: 0.0, y: 0.0, width: pinIcon?.size.width ?? 0.0, height: pinIcon?.size.height ?? 0.0)
                annotationView?.btnInfo.frame = annotationView?.frame ?? .zero
                annotationView?.btnInfo.setBackgroundImage(pinIcon, for: .normal)
                if let btnInfo = annotationView?.btnInfo {
                    annotationView?.addSubview(btnInfo)
                }
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
    }
    
}
