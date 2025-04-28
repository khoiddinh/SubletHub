//
//  ListingCard.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct ListingCard: View {
    let listing: Listing

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(listing.title)
                .font(.headline)

            Text("$\(listing.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
