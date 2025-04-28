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

        // Fetch fresh listings from server
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
                let decodedListings = try JSONDecoder().decode([Listing].self, from: data)
                DispatchQueue.main.async {
                    self.listings = decodedListings
                    PersistenceManager.shared.saveAllListings(decodedListings)
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        .resume()
    }
}
