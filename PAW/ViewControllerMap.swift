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
  var postData = [User]()
  var startStatus = false
  var annotations: [MKPointAnnotation] = []
  var annotationsUser: [String] = []
  
  @IBAction func peeMarkButton(_ sender: Any) {
    if (myLocation.count > 0 && startStatus){
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation.title = "PEE"
      Map.addAnnotation(annotation)
    } else {
      Toast(text: "You need to start record the traveling path!", delay:0, duration: 3).show()
      let appearence = ToastView.appearance()
      appearence.backgroundColor = UIColor.gray
      appearence.textColor = UIColor.black
      appearence.font = UIFont.boldSystemFont(ofSize: 14)
      appearence.cornerRadius = 15
    }
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
    

    checkLocationService();
    
    //get other users location
    let database = Database.database().reference();
//    database.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
//        for child in snapshot.children{
//          print(child as Any)
//        }
//    })

    database.child("users").observe(.childChanged, with: { (snapshot) in
      if let dictionary = snapshot.value as? [String: AnyObject] {
        let user = User()
        user.firstName = dictionary["firstName"] as? String
        user.lastName = dictionary["lastName"] as? String
        user.location = dictionary["location"] as? String
        user.phone = dictionary["phone"] as? String
        user.uid = dictionary["uid"] as? String

        if (self.postData.count < 1 && !user.uid!.isEqual(Auth.auth().currentUser?.uid)) {

          self.postData.append(user);
          let fullNameArr = user.location!.components(separatedBy: " ")
          
          let latitude: String = fullNameArr[0]
          let longtitude: String = fullNameArr[1]
          print(latitude)
          print(longtitude)
          print("first create ++++++++++++++++++++++++++++++++++")
          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2D.init(latitude: Double(latitude) as! CLLocationDegrees, longitude: Double(longtitude) as! CLLocationDegrees)
          annotation.title = user.firstName
          self.annotations.append(annotation)
          self.Map.addAnnotation(annotation)
        }
        
        var checkExist = false
        
        for element in self.postData{
          if(user.uid!.isEqual(element.uid) && !user.uid!.isEqual(Auth.auth().currentUser?.uid)){
            element.location = user.location;
            let fullNameArr = user.location!.components(separatedBy: " ")
            
            let latitude: String = fullNameArr[0]
            let longtitude: String = fullNameArr[1]
            print(latitude)
            print(longtitude)
            print("updata create +_+_+_+_+_+_+_+_+_+_+_+__+_+")
            
            self.annotations[0].coordinate = CLLocationCoordinate2D.init(latitude: Double(latitude) as! CLLocationDegrees, longitude: Double(longtitude) as! CLLocationDegrees)
            checkExist = true
            print("updating ")
          } 
        }
        
        if(!checkExist && !user.uid!.isEqual(Auth.auth().currentUser?.uid)){
          self.postData.append(user);
        }
      }      
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
      
      let annotation1 = MKPointAnnotation()
      annotation1.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation1.title = "End Location"
      Map.addAnnotation(annotation1)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        self.Map.removeAnnotations(self.Map.annotations)
        self.Map.removeOverlays(self.Map.overlays)
        print("Removing all staff on the map")
      }
      
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
    myLocations.append(locations[0] as CLLocation)
    
    //show friends location
    var ref: DatabaseReference!
    ref = Database.database().reference()
    let usersRef = ref.child("users")
    let uid = (Auth.auth().currentUser?.uid)!
    let location = myLocations[myLocations.count-1]
    let latitute = location.coordinate.latitude.description
    let longitude = location.coordinate.longitude.description
    let stringLocation = latitute + " " + longitude
    usersRef.child(uid).updateChildValues(["location": stringLocation])
    
    
    
    //travelling path
    let spanX = 0.007
    let spanY = 0.007
    let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
    Map.setRegion(newRegion, animated: true)
    
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
