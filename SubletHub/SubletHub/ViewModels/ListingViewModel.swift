//
//  ListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//
import SwiftUI
import Foundation
import CoreLocation
import Observation
import FirebaseAuth

@Observable
class ListingViewModel {
    var listings: [Listing] = []

    func fetchData() {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getListings") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let raw = String(data: data, encoding: .utf8) {
                    print("📦 Raw response:", raw) 
                }
                do {
                    let decodedListings = try JSONDecoder().decode([Listing].self, from: data)
                    DispatchQueue.main.async {
                        self.listings = decodedListings
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else if let error = error {
                print("Network error: \(error)")
            }
        }.resume()
    }
}
