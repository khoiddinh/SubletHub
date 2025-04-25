//
//  CreateListingView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import CoreLocation
import MapKit

struct CreateListingView: View {
    @State private var title: String = ""
    @State private var price: String = ""
    @State private var address: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
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
            addressSection
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
                    List(addressVM.searchResults, id: \.uniqueID) { completion in
                        Button(action: {
                            handleAddressSelection(completion)
                        }) {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .fontWeight(.semibold)
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4) // optional spacing
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxHeight: 200)
                }
            }
        }
    }

    private var createButtonSection: some View {
        Section {
            Button(isLoading ? "Creating..." : "Create Listing") {
                createListing()
            }
            .disabled(title.isEmpty || price.isEmpty || address.isEmpty || isLoading)
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
            userID: uid,
            title: title,
            price: Int(price) ?? 0,
            address: address,
            latitude: lat,
            longitude: lng
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
