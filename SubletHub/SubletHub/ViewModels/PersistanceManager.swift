//
//  PersistanceManager.swift
//  SubletHub
//
//  Created by Krishav Singla on 4/28/25.
//

import Foundation

class PersistenceManager {
  static let shared = PersistenceManager()
  private init() {}

  private func url(for filename: String) -> URL {
    let docs = FileManager.default
      .urls(for: .documentDirectory, in: .userDomainMask)[0]
    return docs.appendingPathComponent(filename)
  }

  // Generic save
  func save(_ listings: [Listing], to filename: String) {
    do {
      let data = try JSONEncoder().encode(listings)
      try data.write(to: url(for: filename), options: .atomic)
    } catch {
      print("Persistence save error:", error)
    }
  }

  // Generic load
  func load(from filename: String) -> [Listing]? {
    let fileURL = url(for: filename)
    guard FileManager.default.fileExists(atPath: fileURL.path) else {
      return nil
    }
    do {
      let data = try Data(contentsOf: fileURL)
      return try JSONDecoder().decode([Listing].self, from: data)
    } catch {
      print("Persistence load error:", error)
      return nil
    }
  }

  // Convenience wrappers
  func saveAllListings(_ listings: [Listing]) {
    save(listings, to: "allListings.json")
  }
  func loadAllListings() -> [Listing]? {
    load(from: "allListings.json")
  }

  func saveUserListings(_ listings: [Listing], for uid: String) {
    save(listings, to: "userListings_\(uid).json")
  }
  func loadUserListings(for uid: String) -> [Listing]? {
    load(from: "userListings_\(uid).json")
  }
}
