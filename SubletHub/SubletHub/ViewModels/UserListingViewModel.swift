//
//  UserListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import Observation
import FirebaseStorage

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
    //
    //    func uploadImages(for listingID: String, images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
    //        let storage = Storage.storage()
    //        var uploadedURLs: [String] = []
    //        var uploadCount = 0
    //
    //        for image in images {
    //            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
    //                completion(.failure(URLError(.cannotOpenFile)))
    //                return
    //            }
    //
    //            let filename = UUID().uuidString
    //            let ref = storage.reference().child("listings/\(listingID)/\(filename).jpg")
    //
    //            ref.putData(imageData, metadata: nil) { _, error in
    //                if let error = error {
    //                    print("❌ Upload failed:", error.localizedDescription)
    //                    completion(.failure(error))
    //                    return
    //                }
    //
    //                // 🛠 After upload, retry getting download URL
    //                self.retryGetDownloadURL(ref: ref, attempts: 5) { result in
    //                    switch result {
    //                    case .success(let url):
    //                        uploadedURLs.append(url.absoluteString)
    //                        uploadCount += 1
    //                        if uploadCount == images.count {
    //                            completion(.success(uploadedURLs))
    //                        }
    //                    case .failure(let error):
    //                        completion(.failure(error))
    //                    }
    //                }
    //            }
    //        }
    //    }
    
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
                       completion: @escaping (Result<Void, Error>) -> Void)
    {
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
                await MainActor.run { completion(.failure(error)) }
            }
        }
    }
    
    //    func createListing(for userID: String, listing: Listing, images: [UIImage] = [], completion: @escaping (Result<Void, Error>) -> Void) {
    //        func sendCreateRequest(with imageURLs: [String]?, tempListingID: String?) {
    //            guard let url = URL(string:"https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/createListing") else {
    //                print("Invalid URL")
    //                completion(.failure(URLError(.badURL)))
    //                return
    //            }
    //
    //            var request = URLRequest(url: url)
    //            request.httpMethod = "POST"
    //            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //
    //            var payload: [String: Any] = [
    //                "userID": userID,
    //                "title": listing.title,
    //                "price": listing.price,
    //                "address": listing.address,
    //                "latitude": listing.latitude,
    //                "longitude": listing.longitude,
    //                "totalNumberOfBedrooms": listing.totalNumberOfBedrooms,
    //                "totalNumberOfBathrooms": listing.totalNumberOfBathrooms,
    //                "totalSquareFootage": listing.totalSquareFootage,
    //                "numberOfBedroomsAvailable": listing.numberOfBedroomsAvailable,
    //                "startDateAvailible": listing.startDateAvailible.timeIntervalSince1970,
    //                "lastDateAvailible": listing.lastDateAvailible.timeIntervalSince1970,
    //                "description": listing.description
    //            ]
    //
    //            if let imageURLs = imageURLs {
    //                payload["imageURLs"] = imageURLs
    //            }
    //
    //            if let tempListingID = tempListingID {
    //                payload["storageID"] = tempListingID
    //            }
    //
    //            do {
    //                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
    //            } catch {
    //                print("Failed to serialize JSON:", error)
    //                completion(.failure(error))
    //                return
    //            }
    //
    //            URLSession.shared.dataTask(with: request) { data, _, error in
    //                if let error = error {
    //                    print("Network error: \(error)")
    //                    completion(.failure(error))
    //                    return
    //                }
    //
    //                guard let data = data else {
    //                    print("No response data")
    //                    completion(.failure(URLError(.badServerResponse)))
    //                    return
    //                }
    //
    //                do {
    //                    let response = try JSONDecoder().decode([String: String].self, from: data)
    //                    if let id = response["id"] {
    //                        DispatchQueue.main.async {
    //                            var newListing = listing
    //                            newListing.id = id
    //                            newListing.userID = userID
    //                            newListing.imageURLs = imageURLs
    //                            self.listings.insert(newListing, at: 0)
    //                            completion(.success(()))
    //                        }
    //                    } else {
    //                        print("Missing ID in response")
    //                        completion(.failure(URLError(.cannotParseResponse)))
    //                    }
    //                } catch {
    //                    print("JSON decode failed:", error)
    //                    if let raw = String(data: data, encoding: .utf8) {
    //                        print("Raw response:", raw)
    //                    }
    //                    completion(.failure(error))
    //                }
    //            }.resume()
    //        }
    //
    //        // If there are images, upload them first
    //        if images.isEmpty {
    //            sendCreateRequest(with: nil, tempListingID: nil)
    //        } else {
    //            let tempID = UUID().uuidString
    //            uploadImages(for: tempID, images: images) { result in
    //                switch result {
    //                case .success(let urls):
    //                    sendCreateRequest(with: urls, tempListingID: tempID)
    //                case .failure(let error):
    //                    completion(.failure(error))
    //                }
    //            }
    //        }
    //    }
    func editListing(for userID: String, listing: Listing, images: [UIImage] = [], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let listingID = listing.id else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard listings.contains(where: { $0.id == listingID && $0.userID == userID }) else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            print("Edit denied: Listing does not belong to user.")
            return
        }
        
        func sendEditRequest(with imageURLs: [String]?) {
            guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/updateListing")
            else {
                print("Invalid URL")
                completion(.failure(URLError(.badURL)));
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
                "startDateAvailible": Int(listing.startDateAvailible.timeIntervalSince1970),
                "lastDateAvailible": Int(listing.lastDateAvailible.timeIntervalSince1970),
                "description": listing.description,
            ]
            
//            if let imageURLs = imageURLs {
//                payload["imageURLs"] = imageURLs
//            }
            
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
                    if let i = self.listings.firstIndex(where:{ $0.id == listingID }) {
                            var copy = listing
//                            copy.imageURLs = imageURLs
                            self.listings[i] = copy
                        }
                        completion(.success(()))
                }
            }.resume()
        }
        
        //        if images.isEmpty {
        //            sendEditRequest(with: listing.imageURLs)
        //        } else {
        //            uploadImages(for: listingID, images: images) { result in
        //                switch result {
        //                case .success(let urls):
        //                    sendEditRequest(with: urls)
        //                case .failure(let error):
        //                    completion(.failure(error))
        //                }
        //            }
        //        }
        //    }
    }
}
