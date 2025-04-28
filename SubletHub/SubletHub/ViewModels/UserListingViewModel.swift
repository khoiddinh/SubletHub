//
//  UserListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI
import Foundation
import Observation

@Observable
class UserListingViewModel {
    // The listings it already has
    var listings: [Listing] = []

    // Load listings: first from cache, then from server
    func loadListings(for userID: String) {
        // Load cached user listings
        if let cached = PersistenceManager.shared.loadUserListings(for: userID) {
            DispatchQueue.main.async {
                self.listings = cached
            }
        }

        // Get from network
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getUserListings?userID=\(userID)") else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network error fetching user listings: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned for user listings")
                return
            }
            do {
                let decoded = try JSONDecoder().decode([Listing].self, from: data)
                DispatchQueue.main.async {
                    // update the UI
                    self.listings = decoded
                    // cache fresh results
                    PersistenceManager.shared.saveUserListings(decoded, for: userID)
                }
            } catch {
                print("Decoding user listings error: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response: \(raw)")
                }
            }
        }.resume()
    }

    // Create a new listing and update cache
    func createListing(for userID: String,
                       listing: Listing,
                       completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/createListing") else {
            print("Invalid URL for createListing")
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Build payload
        let payload: [String: Any] = [
            "userID": userID,
            "title": listing.title,
            "price": listing.price,
            "address": listing.address,
            "latitude": listing.latitude,
            "longitude": listing.longitude,
            "totalNumberOfBedrooms": listing.totalNumberOfBedrooms,
            "totalNumberOfBathrooms": listing.totalNumberOfBathrooms,
            "totalSquareFootage": listing.totalSquareFootage,
            "numberOfBedroomsAvailable": listing.numberOfBedroomsAvailable,
            "startDateAvailible": listing.startDateAvailible.timeIntervalSince1970,
            "lastDateAvailible": listing.lastDateAvailible.timeIntervalSince1970,
            "description": listing.description
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to serialize JSON for createListing: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Network error on createListing: \(error)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No response data for createListing")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            do {
                let response = try JSONDecoder().decode([String: String].self, from: data)
                if let id = response["id"] {
                    DispatchQueue.main.async {
                        var newListing = listing
                        newListing.id = id
                        newListing.userID = userID
                        // Insert locally
                        self.listings.insert(newListing, at: 0)
                        // Update cache
                        PersistenceManager.shared.saveUserListings(self.listings, for: userID)
                        completion(.success(()))
                    }
                } else {
                    print("Missing ID in createListing response")
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                print("JSON decode failed for createListing: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response: \(raw)")
                }
                completion(.failure(error))
            }
        }.resume()
    }

    // Edit an existing listing and update cache
    func editListing(for userID: String,
                     listing: Listing,
                     completion: @escaping (Result<Void, Error>) -> Void) {
        guard let listingID = listing.id else {
            completion(.failure(URLError(.badURL)))
            return
        }
        // Confirm ownership
        guard listings.contains(where: { $0.id == listingID && $0.userID == userID }) else {
            print("Edit denied: Listing does not belong to user.")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/updateListing") else {
            print("Invalid URL for updateListing")
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "id": listingID,
            "userID": userID,
            "title": listing.title,
            "price": listing.price,
            "address": listing.address,
            "latitude": listing.latitude,
            "longitude": listing.longitude,
            "totalNumberOfBedrooms": listing.totalNumberOfBedrooms,
            "totalNumberOfBathrooms": listing.totalNumberOfBathrooms,
            "totalSquareFootage": listing.totalSquareFootage,
            "numberOfBedroomsAvailable": listing.numberOfBedroomsAvailable,
            "startDateAvailible": listing.startDateAvailible.timeIntervalSince1970,
            "lastDateAvailible": listing.lastDateAvailible.timeIntervalSince1970,
            "description": listing.description
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to serialize JSON for updateListing: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("Network error on updateListing: \(error)")
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                // Update in-memory
                if let index = self.listings.firstIndex(where: { $0.id == listingID }) {
                    self.listings[index] = listing
                    // Update cache
                    PersistenceManager.shared.saveUserListings(self.listings, for: userID)
                }
                completion(.success(()))
            }
        }.resume()
    }
}
