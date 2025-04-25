//
//  ListingDetailView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct ListingDetailView: View {
    var listing: Listing

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(listing.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Price
                Text("$\(listing.price)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)

                Divider()

                // Address
                VStack(alignment: .leading, spacing: 8) {
                    Text("Address")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(listing.address)
                        .font(.body)
                        .foregroundColor(.primary)
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            )
            .padding()
        }
        .navigationTitle("Listing Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

