//
//  ALL the Beers.swift
//
//  Created by Jason Affourtit on 2/03/21.
//

import UIKit

struct Beer: Codable {
    var beerID: String
    var flight: Int
    var order: Int
    var beerName: String
    var brewery: String
    var beerStyle: String
    var abv: String
    var ibu: String
    var region: String
}
