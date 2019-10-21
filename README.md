# Map


Google Map
-----------------


Map
    import GoogleMaps
    
    let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 14.0)
    let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
    self.view = mapView

Styling

  Map Style Creation
    Create JSON for Map style from google map 
    https://mapstyle.withgoogle.com
    
  Example - Uber like Style
    https://snazzymaps.com/style/90982/uber-2017
  
  How to use Style.json on Map 
     do {
      // Set the map style by passing the URL of the local file.
      if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }
