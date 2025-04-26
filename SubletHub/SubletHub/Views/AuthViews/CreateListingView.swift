//
//  CreateListingView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import CoreLocation
import MapKit
import FirebaseCore

struct CreateListingView: View {
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var address: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var totalBedrooms: String = ""
    @State private var totalBathrooms: String = ""
    @State private var squareFootage: String = ""
    @State private var availableBedrooms: String = ""
    @State private var listingDescription: String = ""
    @State private var startDateAvailable: Date = Date()
    @State private var lastDateAvailable: Date = Date()

    @State private var error: String?
    @State private var isLoading: Bool = false
    @State private var suppressAutocomplete = false
    @State private var addressVM = AddressAutocompleteViewModel() // use distinct address vm
    
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(UserListingViewModel.self) var userListingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            listingDetailsSection
            dateSection
            addressSection
            descriptionSection
            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            createButtonSection
        }

        .navigationTitle("New Listing")
    }


    private var listingDetailsSection: some View {
        Section(header: Text("Listing Details")) {
            TextField("Title", text: $title)
            TextField("Price", text: $price)
                .keyboardType(.numberPad)
            TextField("Total Bedrooms", text: $totalBedrooms)
                .keyboardType(.numberPad)
            TextField("Total Bathrooms", text: $totalBathrooms)
                .keyboardType(.numberPad)
            TextField("Square Footage", text: $squareFootage)
                .keyboardType(.numberPad)
            TextField("Available Bedrooms", text: $availableBedrooms)
                .keyboardType(.numberPad)
        }
    }

    private var dateSection: some View {
            Section(header: Text("Availability Dates")) {
                DatePicker("Start Date Available", selection: $startDateAvailable, displayedComponents: .date)
                DatePicker("Last Date Available", selection: $lastDateAvailable, displayedComponents: .date)
            }
        }
    
    private var addressSection: some View {
        Section(header: Text("Address")) {
            VStack(alignment: .leading, spacing: 0) {
                TextField("Enter address", text: $address)
                    .onChange(of: address) {
                        if suppressAutocomplete {
                            suppressAutocomplete = false
                            return
                        }
                        addressVM.updateSearch(query: address)
                    }
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !addressVM.searchResults.isEmpty && !address.isEmpty {
                    List(addressVM.searchResults.prefix(4), id: \.uniqueID) { completion in
                        Button(action: {
                            handleAddressSelection(completion)
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(completion.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                    .padding(.top, 2)
                                    .padding(.bottom, 1)
                                Text(completion.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.bottom, 0.5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .opacity(0.8)
                            .cornerRadius(5)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }
    
    private var descriptionSection: some View {
        Section(header: Text("Description")) {
            TextEditor(text: $listingDescription)
                .frame(height: 150)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }

    

    private var createButtonSection: some View {
        Section {
            Button(isLoading ? "Creating..." : "Create Listing") {
                createListing()
            }
            .disabled(
                title.isEmpty ||
                price.isEmpty ||
                address.isEmpty ||
                totalBedrooms.isEmpty ||
                totalBathrooms.isEmpty ||
                squareFootage.isEmpty ||
                availableBedrooms.isEmpty ||
                listingDescription.isEmpty ||
                isLoading
            )
        }
    }


    private func handleAddressSelection(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let item = response?.mapItems.first {
                self.suppressAutocomplete = true
                self.address = item.placemark.formattedAddress
                self.latitude = item.placemark.coordinate.latitude
                self.longitude = item.placemark.coordinate.longitude
                withAnimation {
                    self.addressVM.searchResults = []
                }
            } else if let error = error {
                print("Search error:", error.localizedDescription)
            }
        }
    }

    private func createListing() {
        guard let uid = authViewModel.user?.uid else { return }
        guard let lat = latitude, let lng = longitude else {
            self.error = "Please select a valid address."
            return
        }

        isLoading = true
        error = nil

        let listing = Listing(
            id: nil,
            userID: uid,
            title: title,
            price: Int(price) ?? 0,
            address: address,
            latitude: lat,
            longitude: lng,
            totalNumberOfBedrooms: Int(totalBedrooms) ?? 0,
            totalNumberOfBathrooms: Int(totalBathrooms) ?? 0,
            totalSquareFootage: Int(squareFootage) ?? 0,
            numberOfBedroomsAvailable: Int(availableBedrooms) ?? 0,
            startDateAvailible: startDateAvailable,
            lastDateAvailible: lastDateAvailable,
            description: listingDescription
        )


        userListingViewModel.createListing(for: uid, listing: listing) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    dismiss()
                case .failure(let err):
                    error = err.localizedDescription
                }
            }
        }
    }
}

extension MKPlacemark {
    var formattedAddress: String {
        let components = [
            subThoroughfare,      // e.g. 3333
            thoroughfare,         // e.g. Walnut St
            locality,             // e.g. Philadelphia
            administrativeArea,   // e.g. PA
            postalCode            // e.g. 19104
        ]
        
        return components
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
