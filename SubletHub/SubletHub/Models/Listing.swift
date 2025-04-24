//
//  Listing.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation

struct Listing: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var title: String
    var price: Int
    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
