import Foundation
import UIKit
import MapKit          // for CLLocationCoordinate2D
import FirebaseStorage // for Storage.storage()


struct Listing: Identifiable, Codable, Hashable {
    var id: String?
    var userID: String?
    var storageID: String

    var longitude: Double
    var latitude: Double
    var price: Double
    var numberOfBedroomsAvailable: Int
    var totalNumberOfBedrooms: Int
    var totalNumberOfBathrooms: Int
    var totalSquareFootage: Int
    var description: String
    var title: String
    var address: String

    var createdAt: Date
    var startDateAvailible: Date
    var lastDateAvailible: Date

    var imageURLs: [String]?
    var image: [UIImage] = []

    private enum CodingKeys: String, CodingKey {
        case id, longitude, latitude, price,
             numberOfBedroomsAvailable, totalNumberOfBedrooms,
             totalNumberOfBathrooms, totalSquareFootage,
             description, title, address, userID,
             storageID, createdAt, startDateAvailible, lastDateAvailible
    }
    private enum TimestampKeys: String, CodingKey { case _seconds, _nanoseconds }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id                         = try? c.decode(String.self, forKey: .id)
        longitude                  = try c.decode(Double.self, forKey: .longitude)
        latitude                   = try c.decode(Double.self, forKey: .latitude)
        price                      = try c.decode(Double.self, forKey: .price)
        numberOfBedroomsAvailable  = try c.decode(Int.self,    forKey: .numberOfBedroomsAvailable)
        totalNumberOfBedrooms      = try c.decode(Int.self,    forKey: .totalNumberOfBedrooms)
        totalNumberOfBathrooms     = try c.decode(Int.self,    forKey: .totalNumberOfBathrooms)
        totalSquareFootage         = try c.decode(Int.self,    forKey: .totalSquareFootage)
        description                = try c.decode(String.self, forKey: .description)
        title                      = try c.decode(String.self, forKey: .title)
        address                    = try c.decode(String.self, forKey: .address)
        userID                     = try? c.decode(String.self, forKey: .userID)
        storageID = try c.decodeIfPresent(String.self, forKey: .storageID) ?? ""

        func decodeDate(_ key: CodingKeys) throws -> Date {
            if let epoch = try? c.decode(Double.self, forKey: key) {
                return Date(timeIntervalSince1970: epoch)
            }
            let ts = try c.nestedContainer(keyedBy: TimestampKeys.self, forKey: key)
            let sec  = try ts.decode(Double.self, forKey: ._seconds)
            let nano = try ts.decode(Double.self, forKey: ._nanoseconds)
            return Date(timeIntervalSince1970: sec + nano/1_000_000_000)
        }

        createdAt          = try decodeDate(.createdAt)
        startDateAvailible = try decodeDate(.startDateAvailible)
        lastDateAvailible  = try decodeDate(.lastDateAvailible)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(id, forKey: .id)
        try c.encode(longitude, forKey: .longitude)
        try c.encode(latitude,  forKey: .latitude)
        try c.encode(price,     forKey: .price)
        try c.encode(numberOfBedroomsAvailable, forKey: .numberOfBedroomsAvailable)
        try c.encode(totalNumberOfBedrooms,     forKey: .totalNumberOfBedrooms)
        try c.encode(totalNumberOfBathrooms,    forKey: .totalNumberOfBathrooms)
        try c.encode(totalSquareFootage,        forKey: .totalSquareFootage)
        try c.encode(description, forKey: .description)
        try c.encode(title,       forKey: .title)
        try c.encode(address,     forKey: .address)
        try c.encodeIfPresent(userID, forKey: .userID)
        try c.encode(storageID,   forKey: .storageID)

        try c.encode(createdAt.timeIntervalSince1970,          forKey: .createdAt)
        try c.encode(startDateAvailible.timeIntervalSince1970, forKey: .startDateAvailible)
        try c.encode(lastDateAvailible.timeIntervalSince1970,  forKey: .lastDateAvailible)
    }
    
    
}

extension Listing {
  init(
    id: String? = nil,
    userID: String? = nil,
    title: String,
    price: Double,
    address: String,
    latitude: Double,
    longitude: Double,
    totalNumberOfBedrooms: Int,
    totalNumberOfBathrooms: Int,
    totalSquareFootage: Int,
    numberOfBedroomsAvailable: Int,
    startDateAvailible: Date,
    lastDateAvailible: Date,
    description: String,
    storageID: String,
    createdAt: Date = Date(),
    imageURLs: [String]? = nil,
    image: [UIImage] = []
  ) {
    self.id                        = id
    self.userID                    = userID
    self.storageID                 = storageID
    self.longitude                 = longitude
    self.latitude                  = latitude
    self.price                     = price
    self.totalNumberOfBedrooms     = totalNumberOfBedrooms
    self.totalNumberOfBathrooms    = totalNumberOfBathrooms
    self.totalSquareFootage        = totalSquareFootage
    self.numberOfBedroomsAvailable = numberOfBedroomsAvailable
    self.title                     = title
    self.address                   = address
    self.description               = description
    self.createdAt                 = createdAt
    self.startDateAvailible        = startDateAvailible
    self.lastDateAvailible         = lastDateAvailible
    self.imageURLs                 = imageURLs
    self.image                     = image
  }
}
extension Listing {
  /// A MapKit-friendly coordinate for annotation
  var coordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude,
                           longitude: longitude)
  }

  /// Asynchronously fetches all images under `listings/<storageID>/…`
  /// and returns a copy of self with `image` populated.
  func loadingImages() async -> Listing {
    var copy = self
    let bucket = Storage.storage()
    let folderRef = bucket.reference(withPath: "listings/\(storageID)")
    do {
      // list all image files
      let result = try await folderRef.listAll()
      // download each image in parallel
      let loaded = try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
        for (idx, itemRef) in result.items.enumerated() {
          group.addTask {
            let url = try await itemRef.downloadURL()
            let data = try Data(contentsOf: url)
            guard let uiImage = UIImage(data: data) else {
              throw URLError(.cannotDecodeContentData)
            }
            return (idx, uiImage)
          }
        }
        var temp: [(Int, UIImage)] = []
        for try await img in group {
          temp.append(img)
        }
        // sort by original index
        temp.sort { $0.0 < $1.0 }
        return temp.map { $0.1 }
      }
      copy.image = loaded
    } catch {
      print("⚠️ Error loading images for \(storageID):", error)
    }
    return copy
  }
}

extension Listing {
  static func == (lhs: Listing, rhs: Listing) -> Bool {
    return lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id ?? "")
  }
}
