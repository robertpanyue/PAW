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
  @IBOutlet weak var startButton: UIButton!
  
  var manager:CLLocationManager!
  var database: DatabaseReference?
  var myLocation: [CLLocation] = []
  var myLocations: [CLLocation] = []
  var postData = [String]()
  var startStatus = false
  
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
    Map.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    Map.showsUserLocation = true
    Map.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    manager.requestAlwaysAuthorization()
    manager.startUpdatingLocation()
    Map.showsUserLocation = true
    

    //checkLocationService();
    
//    database = Database.database().reference();
//    _ = database?.child("user").observe(.childChanged, with: { (snapshot) in
//      let postDict = snapshot.value as? String
//      self.postData.append(postDict!)  
//      print(self.postData)
//    })
    
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
  @IBAction func startTracking(_ sender: Any) {
    if (!startStatus){
      startStatus = true
      startButton.setTitle("stop", for: .normal)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation.title = "Start Location"
      Map.addAnnotation(annotation)
      
    } else {
      startStatus = false
      startButton.setTitle("start", for: .normal)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation.title = "End Location"
      Map.addAnnotation(annotation)
      //Toast Message
      Toast(text: "Your route is saving to the history", delay:0, duration: 3).show()
      let appearence = ToastView.appearance()
      appearence.backgroundColor = UIColor.gray
      appearence.textColor = UIColor.black
      appearence.font = UIFont.boldSystemFont(ofSize: 14)
      appearence.cornerRadius = 15
      
    }
  }
  
  func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {

    if myLocation.count == 0 {
      myLocation.insert(locations[0], at: 0)
    } else {
      myLocation[0] = locations[0]
    }
    //show friends location
    var ref: DatabaseReference!
    ref = Database.database().reference()
    let users = ref.child("users")
    
    //travelling path
    let spanX = 0.007
    let spanY = 0.007
    let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
    Map.setRegion(newRegion, animated: true)
    myLocations.append(locations[0] as CLLocation)
    if (myLocations.count > 1 && startStatus){
      let sourceIndex = myLocations.count - 1
      let destinationIndex = myLocations.count - 2
      let c1 = myLocations[sourceIndex].coordinate
      let c2 = myLocations[destinationIndex].coordinate
      var a = [c1, c2]
      let polyline = MKPolyline(coordinates: &a, count: a.count)
      Map.addOverlay(polyline)
    }
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    
    if overlay is MKPolyline {
      let polylineRenderer = MKPolylineRenderer(overlay: overlay)
      polylineRenderer.strokeColor = UIColor.blue
      polylineRenderer.lineWidth = 4
      return polylineRenderer
    }
    return MKPolylineRenderer();
  }
  
}
