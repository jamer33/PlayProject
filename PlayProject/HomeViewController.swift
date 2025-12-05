//
//  HomeViewController.swift
//  PlayProject
//
//  Created by Mananas on 2/12/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UILabel!
    
    @IBOutlet weak var firstAccesTextField: UILabel!
    
    @IBOutlet weak var lastAccesTextField: UILabel!
    
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadCurrentUserName()
        loadFirstAccess()
        loadLastAccess()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func loadCurrentUserName() {
        // Obtiene el usuario autenticado actual
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[HomeViewController] No hay usuario autenticado")
            return
        }
        // Lee el documento del usuario en la colección "Users"
        db.collection("Users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("[HomeViewController] Error al obtener usuario: \(error.localizedDescription)")
                return
            }
            guard let data = snapshot?.data() else {
                print("[HomeViewController] Documento de usuario no encontrado para uid: \(uid)")
                return
            }
            let nombre = data["firstName"] as? String ?? data["name"] as? String ?? ""
            let apellidos = data["lastName"] as? String ?? data["surname"] as? String ?? ""
            // Determina el saludo según el género: 0 y 2 -> "Bienvenido", 1 -> "Bienvenida". Si no existe el campo, por defecto "Bienvenido".
            let rawGender = data["gender"]
            let genderValue: Int? = {
                if let g = rawGender as? Int { return g }
                if let n = rawGender as? NSNumber { return n.intValue }
                return nil
            }()
            let saludo = (genderValue == 1) ? "Bienvenida" : "Bienvenido"
            let fullName = [saludo, nombre, apellidos].filter { !$0.isEmpty }.joined(separator: " ")

            DispatchQueue.main.async {
                self.userNameTextField.text = fullName.isEmpty ? "" : fullName
                self.saveLastAccess()
            }
        }
    }

    private func loadLastAccess() {
        // Obtiene el usuario autenticado actual
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[HomeViewController] No hay usuario autenticado para cargar último acceso")
            return
        }
        // Lee el documento del usuario en la colección "Users"
        db.collection("Users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("[HomeViewController] Error al obtener último acceso: \(error.localizedDescription)")
                DispatchQueue.main.async { self.lastAccesTextField.text = "" }
                return
            }
            guard let data = snapshot?.data() else {
                print("[HomeViewController] Documento de usuario no encontrado para uid: \(uid)")
                DispatchQueue.main.async { self.lastAccesTextField.text = "" }
                return
            }
            let millisArray = data["lastAccess"] as? [Int64] ?? []
            let millisValue: Int64? = millisArray.last
            // Se espera un timestamp en milisegundos bajo la clave "lastAccess"
            
            //let millisValue: Int64? = {
                //if let v = data["lastAccess"] as? Int64 { return v }
                //if let v = data["lastAccess"] as? Int { return Int64(v) }
                //if let v = data["lastAccess"] as? NSNumber { return v.int64Value }
                //return nil
            //}()
            guard let lastMillis = millisValue else {
                DispatchQueue.main.async { self.lastAccesTextField.text = "" }
                return
            }
            let date = Date(timeIntervalSince1970: TimeInterval(lastMillis) / 1000.0)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "EEEE dd/MM/yyyy HH:mm:ss"
            let lastDateFormatted = dateFormatter.string(from: date)
            
            DispatchQueue.main.async {
                self.lastAccesTextField.text = lastDateFormatted
            }
        }
    }
    
    private func loadFirstAccess() {
        // Obtiene el usuario autenticado actual
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[HomeViewController] No hay usuario autenticado para cargar primer acceso")
            return
        }
        // Lee el documento del usuario en la colección "Users"
        db.collection("Users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("[HomeViewController] Error al obtener primer acceso: \(error.localizedDescription)")
                DispatchQueue.main.async { self.firstAccesTextField.text = "" }
                return
            }
            guard let data = snapshot?.data() else {
                print("[HomeViewController] Documento de usuario no encontrado para uid: \(uid)")
                DispatchQueue.main.async { self.firstAccesTextField.text = "" }
                return
            }
            // Se espera un arreglo de timestamps en milisegundos bajo la clave "lastAccess" y el primero es el primer acceso
            let millisArray = data["lastAccess"] as? [Int64] ?? []
            guard let firstMillis = millisArray.first else {
                DispatchQueue.main.async { self.firstAccesTextField.text = "" }
                return
            }
            let date = Date(timeIntervalSince1970: TimeInterval(firstMillis) / 1000.0)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
            let firstDateFormatted = dateFormatter.string(from: date)
            
            DispatchQueue.main.async {
                self.firstAccesTextField.text = firstDateFormatted
            }
        }
    }
    
    private func saveLastAccess() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[HomeViewController] No hay usuario autenticado para guardar último acceso")
            return
        }
        let currentMillis = Int64(Date().timeIntervalSince1970 * 1000)
        db.collection("Users").document(uid).updateData(["lastAccess": FieldValue.arrayUnion([currentMillis])]) { error in
            if let error = error {
                print("[HomeViewController] Error al guardar último acceso: \(error.localizedDescription)")
            } else {
                print("[HomeViewController] Último acceso guardado con éxito")
            }
        }
    }

}
