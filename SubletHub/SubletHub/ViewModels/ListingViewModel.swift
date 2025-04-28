//
//  ListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
import SwiftUI
import Foundation
import CoreLocation
import Observation
import FirebaseAuth

@Observable
class ListingViewModel {
    var listings: [Listing] = []
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        // Loads any cached listings immediately
        if let cached = PersistenceManager.shared.loadAllListings() {
            DispatchQueue.main.async {
                self.listings = cached
            }
        }
        
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getListings") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network error: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970 // trying seconds directly first
                
                if let rawString = String(data: data, encoding: .utf8) {
                    print("🚀 RAW server response for listings:", rawString)
                }
                
                let decodedListings = try decoder.decode([Listing].self, from: data)
                
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none

                for listing in decodedListings {
                    print("✅ Listing decoded:")
                    print("  Title:", listing.title)
                    print("  StartDate (raw):", listing.startDateAvailible.timeIntervalSince1970)
                    print("  LastDate (raw):", listing.lastDateAvailible.timeIntervalSince1970)
                    print("📅 Formatted StartDate:", formatter.string(from: listing.startDateAvailible))
                    print("📅 Formatted EndDate:", formatter.string(from: listing.lastDateAvailible))
                }

                DispatchQueue.main.async {
                    self.listings = decodedListings
                    PersistenceManager.shared.saveAllListings(decodedListings)
                }
            } catch {
                print("❌ Decoding error:", error)
            }

        }
        .resume()
    }
}
