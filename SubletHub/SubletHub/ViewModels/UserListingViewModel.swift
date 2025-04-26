//
//  UserListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import Observation

@Observable
class UserListingViewModel {

    var listings: [Listing] = []
    
    func loadListings(for userID: String) {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getUserListings?userID=\(userID)") else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode([Listing].self, from: data)
                DispatchQueue.main.async {
                    self.listings = decoded
                }
            } catch {
                print("Decoding error:", error)
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response:", raw)
                }
            }
        }.resume()
    }
    
    func createListing(for userID: String, listing: Listing, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/createListing") else {
            print("Invalid URL")
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Correct full payload
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
            "startDateAvailible": listing.startDateAvailible.timeIntervalSince1970, // 🛠 send as seconds since 1970
            "lastDateAvailible": listing.lastDateAvailible.timeIntervalSince1970,   // 🛠 send as seconds
            "description": listing.description
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("Failed to serialize JSON: \(error)")
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Network error: \(error)")
                completion(.failure(error))
                return
            }

            guard let data = data else {
                print("No response data")
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
                        self.listings.insert(newListing, at: 0) // insert at 0th index
                        completion(.success(()))
                        print("SUCCESS: Created listing")
                    }
                } else {
                    print("Missing ID in response")
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                print("JSON decode failed: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("Raw response:", raw)
                }
                completion(.failure(error))
            }
        }.resume()
    }
    func editListing(for userID: String, listing: Listing, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let listingID = listing.id else {
            completion(.failure(URLError(.badURL)))
            return
        }

        // Check if the listing belongs to the user
        guard listings.contains(where: { $0.id == listingID && $0.userID == userID }) else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            print("Edit denied: Listing does not belong to user.")
            return
        }

        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/updateListing") else {
            print("Invalid URL")
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
            print("Failed to serialize JSON:", error)
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Network error editing listing:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            DispatchQueue.main.async {
                // update in-memory listing
                if let index = self.listings.firstIndex(where: { $0.id == listingID }) {
                    self.listings[index] = listing
                }
                completion(.success(()))
            }
        }.resume()
    }
}
