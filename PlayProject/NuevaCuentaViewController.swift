//
//  NuevaCuentaViewController.swift
//  PlayProject
//
//  Created by Mananas on 21/11/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NuevaCuentaViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func NuevoUsuario(_ sender: UIButton) {
        sender.isEnabled = false
        if (!validateData()) {
            sender.isEnabled = true
            return
        }

        let firstName = firstNameTextField.text ?? ""
        let lastName = lastNameTextField.text ?? ""
        let gender = genderSegmentedControl.selectedSegmentIndex
        let birthDate = birthDatePicker.date
        let email = usernameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let lastAccess = [Int64(Date().millisecondsSince1970)]
        
        Auth.auth().createUser(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print(error.localizedDescription)
                self.showMessage(message: error.localizedDescription)
                sender.isEnabled = true
                return
            }
            
            let userId = authResult!.user.uid
            
            let user = User(id: userId, firstName: firstName, lastName: lastName, email: email, gender: gender, birthDate: birthDate.millisecondsSince1970, lastAccess: lastAccess)
            
            do {
                let db = Firestore.firestore()
                try db.collection("Users").document(userId).setData(from: user)
            } catch let error {
                print("Error writing user to Firestore: \(error)")
                self.showMessage(message: error.localizedDescription)
                sender.isEnabled = true
                return
            }
            
            print("User created account successfully")
            self.showMessage(title: "Create account", message: "Account created successfully")
            sender.isEnabled = true
        }
    }

    func validateData() -> Bool {
        if firstNameTextField.text?.isEmpty ?? true {
            showMessage(message: "Debes introducir un nombre")
            return false
        }
        if lastNameTextField.text?.isEmpty ?? true {
            showMessage(message: "Debes introducir un apellido")
            return false
        }
        
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
