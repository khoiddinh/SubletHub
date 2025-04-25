//
//  ListingDetailView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct ListingDetailView: View {
    var listing: Listing

    @State private var userName: String?
    @State private var userEmail: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(listing.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // Price
                Text("$\(listing.price) / month")
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

                // User Info Block
                if let name = userName, let email = userEmail {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Posted By")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text(name)
                            .font(.body)
                            .fontWeight(.medium)

                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )

                } else {
                    ProgressView("Loading poster info...")
                        .padding()
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
        .onAppear {
            loadUserInfo()
        }
    }

    private func loadUserInfo() {
        UserViewModel.getUserName(userID: listing.userID ?? "") { name in
            self.userName = name
        }

        UserViewModel.getUserEmail(userID: listing.userID ?? "") { email in
            self.userEmail = email
        }
    }
}
