//
//  UserData.swift
//  UserData
//
//  Created by Philipp on 05.08.21.
//

import Foundation

@MainActor
class UserData: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var ticketReference = ""

    var identfier: String {
        firstName + lastName + ticketReference
    }

    var isValid: Bool {
        !(firstName.isEmpty || lastName.isEmpty || ticketReference.isEmpty)
    }
}
