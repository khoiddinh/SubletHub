//
//  Listing.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import FirebaseStorage

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
    var startDateAvailible: Date
    var lastDateAvailible: Date
    var imageURLs: [String]?
    var image: [UIImage] = []
    var description: String
    var storageID: String? // prefix for storage in cloud
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
           case id, userID, title, price, address,
                latitude, longitude,
                totalNumberOfBedrooms, totalNumberOfBathrooms, totalSquareFootage,
                numberOfBedroomsAvailable,
                startDateAvailible, lastDateAvailible,
                storageID, description
       }
    func loadingImages() async -> Listing {
        guard let sid = storageID else { return self }

        let folderRef = Storage.storage()
                               .reference(withPath: "listings/\(sid)")
        var copy = self                                  

        do {
            let result = try await folderRef.listAll()
            let sorted = result.items.sorted { $0.name < $1.name }

            for ref in sorted {
                if let data = try? await ref.data(maxSize: 4 * 1024 * 1024),
                   let img  = UIImage(data: data) {
                    copy.image.append(img)
                }
            }
        } catch {
            print("image error:", error.localizedDescription)
        }
        return copy
    }
}
