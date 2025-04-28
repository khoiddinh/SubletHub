//
//  UserViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI

// NOTE: STATIC CLASS
struct UserViewModel {
    static func getUserEmail(userID: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getUserEmail?userID=\(userID)") else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode([String: String].self, from: data)
                completion(result["email"])
            } catch {
                print("Error decoding:", error)
                completion(nil)
            }
        }.resume()
    }
    static func getUserName(userID: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/getUserName?userID=\(userID)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }

            do {
                if let rawString = String(data: data, encoding: .utf8) {
                    print("Raw server response for user name:", rawString)
                }
                
                let result = try JSONDecoder().decode([String: String].self, from: data)
                if let name = result["name"] {
                    completion(name)
                } else {
                    print("No name found in response dictionary")
                    completion(nil)
                }
            } catch {
                print("Error decoding:", error)
                completion(nil)
            }
        }.resume()
    }
}


