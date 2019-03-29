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
import Firebase

class ViewControllerMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
  @IBOutlet weak var Map: MKMapView!
  
  
  var manager:CLLocationManager!
  var database: DatabaseReference?
  var myLocation: [CLLocation] = []
  var postData = [String]()
  
  @IBAction func peeMarkButton(_ sender: Any) {
    let annotation = MKPointAnnotation()
    annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
    annotation.title = "PEE"
    Map.addAnnotation(annotation)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    Map.showsUserLocation = true
    checkLocationService();
    
    database = Database.database().reference();
    _ = database?.child("user").observe(.childChanged, with: { (snapshot) in
      let postDict = snapshot.value as? String
      self.postData.append(postDict!)  
      print(self.postData)
    })
    
  }
  
  func checkLocationService(){
    if CLLocationManager.locationServicesEnabled(){
      manager.startUpdatingLocation()
      Map.mapType = MKMapType.standard
    
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
    print("=-=============================================")
    if myLocation.count == 0 {
      myLocation.insert(locations[0], at: 0)
    } else {
      myLocation[0] = locations[0]
    }
    
    print(myLocation)
    print("=----------------------------------------------")
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
