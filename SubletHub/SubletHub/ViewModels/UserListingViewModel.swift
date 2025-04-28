//
//  UserListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI
import Foundation
import Observation
import FirebaseStorage

@Observable
class UserListingViewModel {
    
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
    
    private func uploadImages(images: [UIImage], storageID: String) async throws {
        let bucket = Storage.storage()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for (index, uiImage) in images.enumerated() {
                guard let data = uiImage.jpegData(compressionQuality: 0.80) else { continue }
                let path = "listings/\(storageID)/photo_\(index).jpg"
                group.addTask {
                    try await bucket.reference(withPath: path)
                        .putDataAsync(data, metadata: nil)
                }
            }
            try await group.waitForAll()
        }
    }
    
    private func retryGetDownloadURL(ref: StorageReference, attempts: Int, completion: @escaping (Result<URL, Error>) -> Void) {
        ref.downloadURL { url, error in
            if let url = url {
                completion(.success(url))
            } else if attempts > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // wait 300ms
                    self.retryGetDownloadURL(ref: ref, attempts: attempts - 1, completion: completion)
                }
            } else {
                completion(.failure(error ?? URLError(.fileDoesNotExist)))
            }
        }
    }
    func createListing(for uid: String,
                       listing: Listing,
                       images: [UIImage],
                       completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            do {
                if !images.isEmpty {
                    try await uploadImages(images: images,
                                           storageID: listing.storageID!)
                }
                
                let body: [String: Any] = [
                    "userID":                     uid,
                    "title":                      listing.title,
                    "price":                      listing.price,
                    "address":                    listing.address,
                    "latitude":                   listing.latitude,
                    "longitude":                  listing.longitude,
                    "totalNumberOfBedrooms":      listing.totalNumberOfBedrooms,
                    "totalNumberOfBathrooms":     listing.totalNumberOfBathrooms,
                    "totalSquareFootage":         listing.totalSquareFootage,
                    "numberOfBedroomsAvailable":  listing.numberOfBedroomsAvailable,
                    "startDateAvailible":         Int(listing.startDateAvailible.timeIntervalSince1970 * 1_000),
                    "lastDateAvailible":          Int(listing.lastDateAvailible.timeIntervalSince1970 * 1_000),
                    "description":                listing.description,
                    "storageID":                  listing.storageID!
                ]
                guard let url = URL(string:
                                        "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/createListing")
                else { throw URLError(.badURL) }
                
                var req = URLRequest(url: url)
                req.httpMethod = "POST"
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                req.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, _) = try await URLSession.shared.data(for: req)
                let resp = try JSONDecoder().decode([String:String].self, from: data)
                guard let docID = resp["id"] else {
                    throw URLError(.cannotParseResponse)
                }
                await MainActor.run {
                    var newListing = listing
                    newListing.id      = docID
                    newListing.userID  = uid
                    self.listings.insert(newListing, at: 0)
                    completion(.success(()))
                }
            } catch {
                
            }
        }
    }
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
                        self.listings.insert(newListing, at: 0)
                        PersistenceManager.shared.saveUserListings(self.listings, for: userID)
                        completion(.success(()))
                    }
                } else {
                    print("Missing ID in createListing response")
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                print("JSON decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
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
        
        guard listings.contains(where: { $0.id == listingID && $0.userID == userID }) else {
            print("Edit denied: Listing does not belong to user.")
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }
        
        func sendEditRequest(with imageURLs: [String]?) {
            guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/updateListing") else {
                print("Invalid URL")
                completion(.failure(URLError(.badURL)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var payload: [String: Any] = [
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
                "description": listing.description,
            ]
            
            if let imageURLs = imageURLs {
                payload["imageURLs"] = imageURLs
            }
            
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
                    if let index = self.listings.firstIndex(where: { $0.id == listingID }) {
                        var updatedListing = listing
                        updatedListing.imageURLs = imageURLs // ✅ set images
                        self.listings[index] = updatedListing
                    }
                    completion(.success(()))
                }
            }.resume()
        }
    }
}
