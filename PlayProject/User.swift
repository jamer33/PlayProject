//
//  User.swift
//  TripPlanner
//
//  Created by Mananas on 25/11/25.
//

import Foundation

struct User: Codable {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let gender: Int
    let birthDate: Int64?
}
