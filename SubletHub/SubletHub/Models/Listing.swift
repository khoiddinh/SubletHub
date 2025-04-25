//
//  Listing.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Listing: Identifiable, Codable, Hashable {
    var id: String?
    var userID: String?
    var title: String
    var price: Int
    var address: String
    var latitude: Double
    var longitude: Double
    var totalNumberOfBedrooms: Int
    var totalNumberOfBathrooms: Int
    var totalSquareFootage: Int
    var numberOfBedroomsAvailable: Int
    var description: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
