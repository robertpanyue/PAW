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

class ViewControllerMap: UIViewController{
  @IBOutlet weak var Map: MKMapView!
  
  let manager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    checkLocationService();
  }
  
  func checkLocationService(){
    if CLLocationManager.locationServicesEnabled(){
      manager.delegate = self
      manager.desiredAccuracy = kCLLocationAccuracyBest
      
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
  
}

extension ViewControllerMap: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
  }
  
}

