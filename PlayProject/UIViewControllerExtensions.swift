//
//  UIViewControllerExtensions.swift
//  TripPlanner
//
//  Created by Mananas on 20/11/25.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showMessage(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func showMessage(message: String) {
        showMessage(title: nil, message: message)
    }
    
}
