//
//  RiderViewController.swift
//  Uber
//
//  Created by David Daniel Leah (BFS EUROPE) on 21/06/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth
import FirebaseDatabase
class RiderViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var callAnUber: UIButton!
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.uberHasBeenCalled = true
                self.callAnUber.setTitle("Cancel Uber", for: .normal)
                Database.database().reference().child("RideRequest").removeAllObservers()
                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double,
                        let driverLon = rideRequestDictionary["driverLon"] as? Double {
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                        self.driverOnTheWay = true
                        self.displayDriverAndRider()
                        
                        if let email = Auth.auth().currentUser?.email{
                            Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                                    if let driverLat = rideRequestDictionary["driverLat"] as? Double,
                                        let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                        self.driverOnTheWay = true
                                        self.displayDriverAndRider()
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func displayDriverAndRider(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100)/100
        callAnUber.setTitle("\(roundedDistance)km away!", for: .normal)
        map.removeAnnotations(map.annotations)
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        let riderAnnp = MKPointAnnotation()
        riderAnnp.coordinate = userLocation
        riderAnnp.title = "Your location"
        map.addAnnotation(riderAnnp)
        
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Driver location"
        map.addAnnotation(driverAnno)
    }
    
    //Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate{
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
  
            if uberHasBeenCalled{
                displayDriverAndRider()
            }else{
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "You"
                map.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func logOutButton(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func uberTapped(_ sender: Any) {
        if !driverOnTheWay{
            if let email = Auth.auth().currentUser?.email{
                if uberHasBeenCalled {
                    uberHasBeenCalled = false
                    callAnUber.setTitle("Call an uber", for: .normal)
                    Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                        snapshot.ref.removeValue()
                        Database.database().reference().child("RideRequest").removeAllObservers()
                    }
                }else{
                    let rideRequestDic : [String:Any] = ["email" : email, "lat" : userLocation.latitude, "lon" : userLocation.longitude]
                    Database.database().reference().child("RideRequest").childByAutoId().setValue(rideRequestDic)
                    uberHasBeenCalled = true
                    callAnUber.setTitle("Cancel Uber", for: .normal)
                }
                
            }
        }
    }
}
