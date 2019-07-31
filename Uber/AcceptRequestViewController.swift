//
//  AcceptRequestViewController.swift
//  Uber
//
//  Created by David Daniel Leah (BFS EUROPE) on 24/06/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
class AcceptRequestViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    var driverLocation = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        map.addAnnotation(annotation)
    }
    
    
    @IBAction func acceptTapped(_ sender: Any) {
        Database.database().reference().child("RideRequest").queryOrdered(byChild: "email").queryEqual(toValue: requestEmail).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            Database.database().reference().child("RideRequest").removeAllObservers()
        }
        
        let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.requestEmail
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                    
                }
            }
        }
    }
    
}
