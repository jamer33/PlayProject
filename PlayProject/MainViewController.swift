//
//  ViewController.swift
//  PlayProject
//
//  Created by Mananas on 20/11/25.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signIn(_ sender: Any) {
        let email = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            let usuario = authResult?.user.uid
            
            print("User signed in successfully \(String(describing: usuario))")
            self.performSegue(withIdentifier: "Navigate To Home", sender: usuario)
            
        }

    }
    
}
