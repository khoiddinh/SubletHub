//
//  EditListingView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/26/25.
//


import SwiftUI

struct EditListingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserListingViewModel.self) var userListingViewModel
    @Environment(AuthViewModel.self) var authViewModel
    
    var listing: Listing

    @State private var title: String
    @State private var price: String
    @State private var address: String
    @State private var totalBedrooms: String
    @State private var totalBathrooms: String
    @State private var squareFootage: String
    @State private var availableBedrooms: String
    @State private var descriptionText: String
    @State private var startDateAvailable: Date
    @State private var lastDateAvailable: Date
    
    @State private var isSaving = false
    @State private var errorMessage: String?

    init(listing: Listing) {
        self.listing = listing
        _title = State(initialValue: listing.title)
        _price = State(initialValue: "\(listing.price)")
        _address = State(initialValue: listing.address)
        _totalBedrooms = State(initialValue: "\(listing.totalNumberOfBedrooms)")
        _totalBathrooms = State(initialValue: "\(listing.totalNumberOfBathrooms)")
        _squareFootage = State(initialValue: "\(listing.totalSquareFootage)")
        _availableBedrooms = State(initialValue: "\(listing.numberOfBedroomsAvailable)")
        _descriptionText = State(initialValue: listing.description)
        _startDateAvailable = State(initialValue: listing.startDateAvailible)
        _lastDateAvailable = State(initialValue: listing.lastDateAvailible)
    }

    var body: some View {
        Form {
            Section(header: Text("Listing Details")) {
                TextField("Title", text: $title)
                TextField("Price", text: $price)
                    .keyboardType(.numberPad)
                TextField("Address", text: $address)
                TextField("Total Bedrooms", text: $totalBedrooms)
                    .keyboardType(.numberPad)
                TextField("Total Bathrooms", text: $totalBathrooms)
                    .keyboardType(.numberPad)
                TextField("Square Footage", text: $squareFootage)
                    .keyboardType(.numberPad)
                TextField("Available Bedrooms", text: $availableBedrooms)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Availability Dates")) {
                DatePicker("Start Date", selection: $startDateAvailable, displayedComponents: .date)
                DatePicker("End Date", selection: $lastDateAvailable, displayedComponents: .date)
            }

            Section(header: Text("Description")) {
                TextEditor(text: $descriptionText)
                    .frame(height: 150)
            }

            if let errorMessage = errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Button(isSaving ? "Saving..." : "Save Changes") {
                    saveChanges()
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Edit Listing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveChanges() {
        guard let userID = authViewModel.user?.uid else {
            errorMessage = "User not logged in."
            return
        }
        guard let listingID = listing.id else {
            errorMessage = "Invalid listing ID."
            return
        }

        isSaving = true
        errorMessage = nil

        // Build updated Listing object
        let updatedListing = Listing(
            id: listingID,
            userID: userID,
            title: title,
            price: Int(price) ?? 0,
            address: address,
            latitude: listing.latitude, // reuse original lat/lng unless editing
            longitude: listing.longitude,
            totalNumberOfBedrooms: Int(totalBedrooms) ?? 0,
            totalNumberOfBathrooms: Int(totalBathrooms) ?? 0,
            totalSquareFootage: Int(squareFootage) ?? 0,
            numberOfBedroomsAvailable: Int(availableBedrooms) ?? 0,
            startDateAvailible: startDateAvailable,
            lastDateAvailible: lastDateAvailable,
            description: descriptionText,
            storageID: listing.storageID ?? ""
        )

        userListingViewModel.editListing(for: userID, listing: updatedListing) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    print("Successfully edited listing!")
                    dismiss()
                case .failure(let error):
                    print("Failed to edit listing:", error.localizedDescription)
                    errorMessage = "Failed to save changes. Try again."
                }
            }
        }
    }
}
