//
//  ViewController.swift
//  Uber
//
//  Created by David Daniel Leah (BFS EUROPE) on 21/06/2019.
//  Copyright © 2019 David Daniel Leah (BFS EUROPE). All rights reserved.
//

import UIKit
import FirebaseAuth
class ViewController: UIViewController {
    @IBOutlet weak var emailInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var raiderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var raiderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
 
    var signUpMode = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    
    @IBAction func topTapped(_ sender: Any) {
        if emailInput.text == "" || passwordInput.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both email and password")
        }else{
            if let email = emailInput.text,
                let password = passwordInput.text{
                if signUpMode {
                    //sign up
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        }else{
                            if self.raiderDriverSwitch.isOn {
                                //driver
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Driver"
                                req?.commitChanges(completion: { (error) in
                                    if let error = error{
                                      print(error)
                                    }
                                })
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            }else{
                                //rider
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Rider"
                                req?.commitChanges(completion: { (error) in
                                    if let error = error{
                                        print(error)
                                    }
                                })
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                            
                        }
                    }
                }else {
                    //log in
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Error", message: error!.localizedDescription)
                        }else{
                            if user?.user.displayName == "Driver"{
                                //driver
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            }else{
                                //rider
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                            
                        }
                    })
                }
            }
        }
    }
    @IBAction func bottomTapped(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log in", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            raiderLabel.isHidden = true
            driverLabel.isHidden = true
            raiderDriverSwitch.isHidden = true
            signUpMode = false
        }else{
            topButton.setTitle("Sigh up", for: .normal)
            bottomButton.setTitle("Switch to Log in", for: .normal)
            raiderLabel.isHidden = false
            driverLabel.isHidden = false
            raiderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }
    
    func displayAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

