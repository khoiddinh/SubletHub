//
//  MapView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    // default: centered on Philadelphia
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    @State private var viewModel = ListingViewModel()
    
    var body: some View {
        let validListings: [Listing] = viewModel.listings.compactMap { $0.id != nil ? $0 : nil}

        Map(position: $position, interactionModes: [.all]) {
            ForEach(validListings) { listing in
                Annotation("", coordinate: listing.coordinate) {
                    HStack {
                        Text("$\(listing.price)")
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

