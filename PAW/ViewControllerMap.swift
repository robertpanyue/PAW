//
//  ViewControllerMap.swift
//  PAW
//
//  Created by Yue Pan on 2/20/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewControllerMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
  @IBOutlet weak var Map: MKMapView!
  
  
  var manager:CLLocationManager!

  var myLocation: [CLLocation] = []
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    //manager = CLLocationManager()
    
    //checkLocationService();
  }
  
  func checkLocationService(){
    if CLLocationManager.locationServicesEnabled(){
      manager.delegate = self
      manager.desiredAccuracy = kCLLocationAccuracyBest
      manager.startUpdatingLocation()
      Map.mapType = MKMapType.standard
      
//      let newRegion = MKCoordinateRegion(center: Map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
//      
//      Map.setRegion(newRegion, animated: true)
      
      switch CLLocationManager.authorizationStatus(){
      case .authorizedWhenInUse:
        Map.showsUserLocation = true
        break
      case .notDetermined:
        manager.requestWhenInUseAuthorization()
      case .restricted:
        break
      case .denied:
        break
      case .authorizedAlways:
        break
      }
    } else {
      
    }
  }
  
  
  func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
    
    myLocation.append(locations[0] )
    
    let spanX = 0.007
    
    let spanY = 0.007
    
    let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
    
    Map.setRegion(newRegion, animated: true)
    
    if (myLocation.count > 1){
      
      let sourceIndex = myLocation.count - 1
      
      let destinationIndex = myLocation.count - 2
      
      let c1 = myLocation[sourceIndex].coordinate
      
      let c2 = myLocation[destinationIndex].coordinate
      
      var a = [c1, c2]
      
      let polyline = MKPolyline(coordinates: &a, count: a.count)
      
      Map.addOverlay(polyline)
      
    }
  }
}
