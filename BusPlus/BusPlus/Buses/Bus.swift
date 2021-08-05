//
//  Bus.swift
//  Bus
//
//  Created by Philipp on 05.08.21.
//

import Foundation

struct Bus: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    let location: String
    let destination: String
    let passengers: Int
    let fuel: Int
    let image: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let example = Bus(
        id: 0,
        name: "Bussy Bear", location: "Forest", destination: "Honey Pot",
        passengers: 1, fuel: 23,
        image: URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/78/EVAG_O530_3413_Holthuser_Tal.jpg")!
    )
}
