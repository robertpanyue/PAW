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

class ViewControllerMap: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate{
  @IBOutlet weak var Map: MKMapView!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var centerUserButton: UIButton!
  
  var manager:CLLocationManager!
  var database: DatabaseReference?
  //current location
  var myLocation: [CLLocation] = []
  var myLocations: [CLLocation] = []
  var postData = [User]()
  var startStatus = false
  var annotationsArray: [MKPointAnnotation] = []
  var peeLocations: String = ""
  var poopLocations: String = ""
  var annotationsUser: [String] = []
  var startLati: Double = 0.0
  var startLong: Double = 0.0
  var region = false;
  
  @IBAction func centerUser(_ sender: Any) {
    self.Map.setUserTrackingMode( MKUserTrackingMode.follow, animated: true)
  }
  
  @IBAction func searchButton(_ sender: Any)
  {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.delegate = self
    present(searchController, animated: true, completion: nil)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
  {
    //Ignoring user
    UIApplication.shared.beginIgnoringInteractionEvents()
    
    //Activity Indicator
    let activityIndicator = UIActivityIndicatorView()
    activityIndicator.style = UIActivityIndicatorView.Style.gray
    activityIndicator.center = self.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.startAnimating()
    
    self.view.addSubview(activityIndicator)
    
    //Hide search bar
    searchBar.resignFirstResponder()
    dismiss(animated: true, completion: nil)
    
    //Create the search request
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = searchBar.text
    
    let activeSearch = MKLocalSearch(request: searchRequest)
    
    activeSearch.start { (response, error) in
      
      activityIndicator.stopAnimating()
      UIApplication.shared.endIgnoringInteractionEvents()
      
      if response == nil
      {
        print("ERROR")
      }
      else
      {
        
        //Remove annotations
        let annotations = self.Map.annotations
        self.Map.removeAnnotations(annotations)
        
        //Getting data
        let latitude = response?.boundingRegion.center.latitude
        let longitude = response?.boundingRegion.center.longitude
        
        //Create annotation
        let annotation = MKPointAnnotation()
        annotation.title = searchBar.text
        annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
        self.Map.addAnnotation(annotation)
        
        //Zooming in on annotation
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.Map.setRegion(region, animated: false)
      }
      
    }
  }
  
  
  
  
  @IBAction func peeMarkButton(_ sender: Any) {
    if (myLocation.count > 0 && startStatus){
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      peeLocations = String(myLocation[0].coordinate.latitude) + " " + String(myLocation[0].coordinate.longitude) 
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
  
  
  
  
  
  
  @IBAction func poopMarkButton(_ sender: Any) {
    if (myLocation.count > 0 && startStatus){
      let annotation4 = MKPointAnnotation()
      annotation4.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      poopLocations = String(myLocation[0].coordinate.latitude) + " " + String(myLocation[0].coordinate.longitude) 
      annotation4.title = "POOP"
      Map.addAnnotation(annotation4)
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
    createDirectory();
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
          
          let annotation3 = MKPointAnnotation()
          annotation3.coordinate = CLLocationCoordinate2D.init(latitude: Double(latitude) as! CLLocationDegrees, longitude: Double(longtitude) as! CLLocationDegrees)
          annotation3.title = user.firstName
          self.Map.addAnnotation(annotation3)
          self.annotationsArray.append(annotation3)
          self.annotationsUser.append(user.uid!)
//          print(self.Map.annotations.count)
//          print(self.Map.annotations[0])
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
            
            let index = self.annotationsUser.firstIndex(of: element.uid!)
            self.annotationsArray[index!].coordinate = CLLocationCoordinate2D.init(latitude: Double(latitude) as! CLLocationDegrees, longitude: Double(longtitude) as! CLLocationDegrees)
            checkExist = true
            print("updating ")
            print(self.annotationsArray.count)
            print(self.postData.count)
          } 
        }
        
        if(!checkExist && !user.uid!.isEqual(Auth.auth().currentUser?.uid)){
          self.postData.append(user);
          let fullNameArr = user.location!.components(separatedBy: " ")
          
          let latitude: String = fullNameArr[0]
          let longtitude: String = fullNameArr[1]
          print(latitude)
          print(longtitude)
          print("second third create ++++++++++++++++++++++++++++++++++")
          
          let annotation4 = MKPointAnnotation()
          annotation4.coordinate = CLLocationCoordinate2D.init(latitude: Double(latitude) as! CLLocationDegrees, longitude: Double(longtitude) as! CLLocationDegrees)
          annotation4.title = user.firstName
          self.Map.addAnnotation(annotation4)
          self.annotationsArray.append(annotation4)
          self.annotationsUser.append(user.uid!)
          
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
      region = true;
      startStatus = true
      startButton.setTitle("stop", for: .normal)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation.title = "Start Location"
      Map.addAnnotation(annotation)
      
      startLati = myLocation[0].coordinate.latitude
      startLong = myLocation[0].coordinate.longitude
      
    } else {
      region = false;
      startStatus = false
      startButton.setTitle("start", for: .normal)
      
      let annotation1 = MKPointAnnotation()
      annotation1.coordinate = CLLocationCoordinate2D(latitude: myLocation[0].coordinate.latitude, longitude: myLocation[0].coordinate.longitude)
      annotation1.title = "End Location"
      Map.addAnnotation(annotation1)
      
      //set region
      let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (startLati + myLocation[0].coordinate.latitude) / 2, longitude: (startLong + myLocation[0].coordinate.longitude) / 2), span: MKCoordinateSpan(latitudeDelta: fabs(startLati - myLocation[0].coordinate.latitude) * 1.2, longitudeDelta: fabs(myLocation[0].coordinate.longitude - startLong) * 1.2))
    
      Map.setRegion(newRegion, animated: false)
      
      //same history image
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        let image = self.captureScreenshot();
        self.saveImageDocumentDirectory(image: image)
        print("save to photo")
      }

      //get the current date and time 
      let currentDateTime = Date()
      let formatter = DateFormatter()
      formatter.timeStyle = .medium
      formatter.dateStyle = .long
      let date = formatter.string(from: currentDateTime)
      
      var ref: DatabaseReference!
      ref = Database.database().reference().child("history").child(Auth.auth().currentUser!.uid)
      let newUser = [
        "uid": Auth.auth().currentUser!.uid,
        "startLocationLati": startLati,
        "startLocationLong": startLong,
        "peeLocation": peeLocations,
        "poopLocation": poopLocations,
        "endLocationLati": myLocation[0].coordinate.latitude,
        "endLocationLong": myLocation[0].coordinate.longitude,
        "date": date
      ] as [AnyHashable : Any] 
      ref.updateChildValues(newUser as [AnyHashable : Any], withCompletionBlock: {(error, ref) in 
        if error != nil {
          print("error")
          return
        }
      })
      
      startLati = 0
      startLong = 0
      
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
    
  func captureScreenshot() -> UIImage {
    let layer = UIApplication.shared.keyWindow!.layer
    let scale = UIScreen.main.scale
    // Creates UIImage of same size as view
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    print("----------------")
    print(type(of: screenshot))
    return screenshot
  }
  
  func createDirectory(){
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("customDirectory")
    if !fileManager.fileExists(atPath: paths){
      try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
    }else{
      print("Already dictionary created.")
    }
  }
  
  func getDirectoryPath() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]; 
    return documentsDirectory
  }
  
  func saveImageDocumentDirectory(image:UIImage ){
    let fileManager = FileManager.default
    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("history.jpg")
    print(paths)
    
    let imageData = image.jpegData(compressionQuality: 1.0); 
    fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
  }

  
  
  func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {

    if myLocation.count == 0 {
      myLocation.insert(locations[0], at: 0)
    } else {
      myLocation[0] = locations[0]
    }
    
//    let defaults = UserDefaults(suiteName: "group.PAWIOS")
//    defaults?.set(20.1, forKey: "passingLocation")
//    defaults?.synchronize()
    
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
    if (region){
      let spanX = 0.007
      let spanY = 0.007
      let newRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: spanX, longitudeDelta: spanY))
      Map.setRegion(newRegion, animated: true)
    }

    
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

