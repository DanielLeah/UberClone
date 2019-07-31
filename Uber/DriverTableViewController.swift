//
//  DriverTableViewController.swift
//  Uber
//
//  Created by David Daniel Leah (BFS EUROPE) on 24/06/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    var rideRequest : [DataSnapshot] = []
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("RideRequest").observe(.childAdded) { (snapshot) in
            if let rideRequestDic = snapshot.value as? [String: AnyObject]{
                if let driverLat = rideRequestDic["driverLat"] as? Double{
                    
                }else {
                    self.rideRequest.append(snapshot)
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func logOutButton(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverLocation = coord
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rideRequest.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rideRequestCell", for: indexPath)
        
        let snapshot = rideRequest[indexPath.row]
        if let rideRequestDic = snapshot.value as? [String: AnyObject]{
            if let email = rideRequestDic["email"] as? String{
                if let lat = rideRequestDic["lat"] as? Double,
                    let lon = rideRequestDic["lon"] as? Double{
                    let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                    let riderClLocation = CLLocation(latitude: lat, longitude: lon)
                    let distance = driverCLLocation.distance(from: riderClLocation) / 1000
                    let roundedDistance = round(distance * 100)/100
                    cell.textLabel?.text = "\(email) - \(roundedDistance)km away"
                }
                
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequest[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? AcceptRequestViewController{
            if let snapshot = sender as? DataSnapshot {
                if let rideRequestDic = snapshot.value as? [String: AnyObject]{
                    if let email = rideRequestDic["email"] as? String,
                        let lat = rideRequestDic["lat"] as? Double,
                        let lon = rideRequestDic["lon"] as? Double{
                        acceptVC.requestEmail = email
                        let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        acceptVC.requestLocation = location
                        acceptVC.driverLocation = driverLocation
                    }
                }
            }
        }
    }
}
