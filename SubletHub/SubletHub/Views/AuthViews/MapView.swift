//
//  MapView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import SwiftUI
import MapKit

// TODO: FIX ON CLICK SCALE AND BACKGROUND CHANGE, REDO ANNOTATIONS
struct MapView: View {
    // default: centered on Philadelphia
    @State var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var viewModel = ListingViewModel()
    @State var addressVM = AddressAutocompleteViewModel() // map view distinct autocomplete vm
    @State private var selectedListingID: String?
    
    var body: some View {
        ZStack(alignment: .top) {
            listingsMap
                .onAppear { viewModel.fetchData() }
                .onTapGesture {
                    selectedListingID = nil
                    addressVM.searchResults = []
                }

            SearchBar(addressVM: $addressVM, position: $position)
        }
    }
    // TODO: make these clickable and open listing popup (the click box right now is weird)
    @ViewBuilder
    private func annotationView(for listing: Listing) -> some View {
        VStack(spacing: 0) {
            Text("$\(listing.price)")
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(radius: 2)

            Triangle()
                .fill(Color.white)
                .frame(width: 12, height: 6)
                .shadow(radius: 1.2)
                .offset(y: -0.8)
                .scaleEffect(x: 1, y: -1) // flip triangle
        }
        .offset(y: -20)
        .onTapGesture {
            withAnimation {
                selectedListingID = listing.id
            }
        }
        .scaleEffect(selectedListingID == listing.id ? 1.2 : 1.0)
        .background(selectedListingID == listing.id ? Color.black.opacity(0.1) : Color.clear)
    }
    private var listingsMap: some View {
        let validListings = viewModel.listings.compactMap { $0.id != nil ? $0 : nil }

        return Map(position: $position, interactionModes: [.all]) {
            ForEach(validListings) { listing in
                Annotation("", coordinate: listing.coordinate) {
                    annotationView(for: listing)
                }
                .annotationTitles(.hidden) // prevents default artifacts
            }
        }
    }

}

