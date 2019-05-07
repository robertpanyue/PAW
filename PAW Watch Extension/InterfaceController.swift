//
//  InterfaceController.swift
//  PAW Watch Extension
//
//  Created by Yue Pan on 4/19/19.
//  Copyright © 2019 Yue Pan. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import HealthKit
import MapKit

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate, HKWorkoutSessionDelegate {

   var manager:CLLocationManager!
  
  @IBOutlet weak var mapView: WKInterfaceMap!
  
  @IBOutlet weak var heart: WKInterfaceImage!
  @IBOutlet weak var bpmLabel: WKInterfaceLabel!
  @IBOutlet weak var startStopButton: WKInterfaceButton!
  @IBOutlet weak var speedLabel: WKInterfaceLabel!
  
  var locationManager: CLLocationManager = CLLocationManager()
  var currentLocation = CLLocation()
  var lat:Double = 0.0
  var long:Double = 0.0
  
  let healthStore = HKHealthStore()
  
  //State of the app - is the workout activated
  var workoutActive = false
  
  // define the activity type and location
  var session : HKWorkoutSession?
  let heartRateUnit = HKUnit(from: "count/min")
  //var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
  var currenQuery : HKQuery?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    // Configure interface objects here.
    manager = CLLocationManager()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestAlwaysAuthorization()
    manager.startUpdatingLocation()
    
    let defaults = UserDefaults(suiteName: "group.PAWIOS")
    let location = defaults?.double(forKey: "passingLocation")
    print(location!)
  }
    
  func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
    switch toState {
    case .running:
      workoutDidStart(date)
    case .ended:
      workoutDidEnd(date)
    default:
      print("Unexpected state \(toState)")
    }
  }
  
  func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    print("Workout error")
  }
  
  //update and get the location
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if locations.count == 0 {
      return;
    }
    
    self.currentLocation = locations[0]
    self.speedLabel.setText(String(locations[0].speed) + "mps")
    
    self.mapView.addAnnotation(locations[0].coordinate, with: .red)
    //set region
    self.mapView.setRegion(MKCoordinateRegion.init(center: locations[0].coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.001, longitudeDelta: 0.001)))
    
  }
  
  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    
    
    guard HKHealthStore.isHealthDataAvailable() == true else {
      bpmLabel.setText("not available")
      return
    }
    
    guard let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
      displayNotAllowed()
      return
    }
    
    let dataTypes = Set(arrayLiteral: quantityType)
    healthStore.requestAuthorization(toShare: nil, read: dataTypes) { (success, error) -> Void in
      if success == false {
        self.displayNotAllowed()
      }
    }
  }
    
  override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
      super.didDeactivate()
    self.mapView.removeAllAnnotations();
  }
  
  @IBAction func startStopTapped() {
    if (self.workoutActive) {
      //finish the current workout
      self.workoutActive = false
      self.startStopButton.setTitle("Start")
      if let workout = self.session {
        healthStore.end(workout)
      }
    } else {
      //start a new workout
      self.workoutActive = true
      self.startStopButton.setTitle("Stop")
      startWorkout()
    }
  }
  
  func displayNotAllowed() {
    bpmLabel.setText("not allowed")
  }
  
  func workoutDidStart(_ date : Date) {
    if let query = createHeartRateStreamingQuery(date) {
      self.currenQuery = query
      healthStore.execute(query)
    } else {
      bpmLabel.setText("cannot start")
    }
  }
  
  func workoutDidEnd(_ date : Date) {
    healthStore.stop(self.currenQuery!)
    bpmLabel.setText("---")
    session = nil
  }
  
  func startWorkout() {
    // If we have already started the workout, then do nothing.
    if (session != nil) {
      return
    }
    
    // Configure the workout session.
    let workoutConfiguration = HKWorkoutConfiguration()
    workoutConfiguration.activityType = .crossTraining
    workoutConfiguration.locationType = .indoor
    
    do {
      session = try HKWorkoutSession(configuration: workoutConfiguration)
      //session = try HKWorkoutSession.init(healthStore: healthStore, configuration: workoutConfiguration)
      session?.delegate = self as! HKWorkoutSessionDelegate
    } catch {
      fatalError("Unable to create the workout session!")
    }
    
    healthStore.start(self.session!)
  }
  
  func createHeartRateStreamingQuery(_ workoutStartDate: Date) -> HKQuery? {
    guard let quantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else { return nil }
    let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictEndDate )
    //let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates:[datePredicate])
    
    
    let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: predicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
      //guard let newAnchor = newAnchor else {return}
      //self.anchor = newAnchor
      self.updateHeartRate(sampleObjects)
    }
    
    heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
      //self.anchor = newAnchor!
      self.updateHeartRate(samples)
    }
    return heartRateQuery
  }
  
  func updateHeartRate(_ samples: [HKSample]?) {
    guard let heartRateSamples = samples as? [HKQuantitySample] else {return}
    
    DispatchQueue.main.async {
      guard let sample = heartRateSamples.first else{return}
      let value = sample.quantity.doubleValue(for: self.heartRateUnit)
      self.bpmLabel.setText(String(UInt16(value)))
      
    }
  }


}
