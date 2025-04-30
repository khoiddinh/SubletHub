import Foundation

protocol Persistence {
  func save<T: Codable>(_ object: T, to filename: String)
  func load<T: Codable>(_ type: T.Type, from filename: String) -> T?
}

final class PersistenceManager: Persistence {
  static let shared = PersistenceManager()
  private init() {}

  private func url(for filename: String) -> URL {
    let docs = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
    return docs.appendingPathComponent(filename)
  }

  func save<T: Codable>(_ object: T, to filename: String) {
    do {
      let encoder = JSONEncoder()
      // Encode Date as seconds since 1970
      encoder.dateEncodingStrategy = .secondsSince1970
      let data = try encoder.encode(object)
      try data.write(
        to: url(for: filename),
        options: Data.WritingOptions.atomic
      )
    } catch {
      print("📁 Persistence save error for \(filename):", error)
    }
  }

  func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
    let fileURL = url(for: filename)
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return nil
    }
    do {
      let data = try Data(contentsOf: fileURL)
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .secondsSince1970
      return try decoder.decode(type, from: data)
    } catch {
      print("📁 Persistence load error for \(filename):", error)
      return nil
    }
  }

  func saveAllListings(_ listings: [Listing]) {
    save(listings, to: "allListings.json")
  }
  func loadAllListings() -> [Listing]? {
    load([Listing].self, from: "allListings.json")
  }

  func saveUserListings(_ listings: [Listing], for uid: String) {
    save(listings, to: "userListings_\(uid).json")
  }
  func loadUserListings(for uid: String) -> [Listing]? {
    load([Listing].self, from: "userListings_\(uid).json")
  }
}
