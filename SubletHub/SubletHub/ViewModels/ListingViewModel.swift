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

@Observable
class ListingViewModel {
    let PROJECT_ID: String = "sublet-hub-52e99"
    var listings: [Listing] = []

    func fetchData() {
        guard let url = URL(string: "https://us-central1-\(PROJECT_ID).cloudfunctions.net/getListings") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
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
    func createListing(_ listing: Listing, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-\(PROJECT_ID).cloudfunctions.net/createListing") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(listing)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode([String: String].self, from: data)
                if let id = response["id"] {
                    completion(.success(id))
                } else {
                    completion(.failure(URLError(.cannotParseResponse)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
