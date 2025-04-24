//
//  ListingViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//
import SwiftUI
import Foundation
import FirebaseFirestore
import Observation

@Observable
class ListingViewModel {
    var listings: [Listing] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private var listenerRegistration: ListenerRegistration?

    deinit {
        unregister()
    }

    func unregister() {
        if listenerRegistration != nil {
            listenerRegistration?.remove()
        }
    }
    
    
    func fetchData() {
        unregister()
        listenerRegistration = db.collection("listings").addSnapshotListener { (querySnapshot, error) in
          guard let documents = querySnapshot?.documents else {
              print("No documents")
              return
          }

          self.listings = documents.compactMap { queryDocumentSnapshot -> Listing? in
              return try? queryDocumentSnapshot.data(as: Listing.self)
          }
        }
    }
}
