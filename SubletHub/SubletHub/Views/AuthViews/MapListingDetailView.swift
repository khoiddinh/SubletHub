//
//  MapListingDetailView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import FirebaseStorage
import UIKit

struct MapListingDetailView: View {
    @State var listing: Listing

    @State private var userName: String?
    @State private var userEmail: String?
    @State private var showDeleteConfirmation: Bool = false
    @State private var navigateToEdit: Bool = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(UserListingViewModel.self) var userListingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                listingHeader
                listingImages
                listingDetails
                availabilitySection
                CalendarView(startDate: listing.startDateAvailible, endDate: listing.lastDateAvailible)
                addressSection
                userInfoSection
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
            )
            .padding()
        }
        .task {
            listing = await listing.loadingImages()
        }
        .navigationTitle("Listing Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadUserInfo()
        }
        .alert("Delete Listing?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                userListingViewModel.deleteListing(listing: listing)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete this listing?")
        }
    }
}

extension MapListingDetailView {
    private var listingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(listing.title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("$\(listing.price) / month")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
            
            Divider()
        }
    }
    
    private var listingImages: some View {
        Group {
            if listing.image.isEmpty {
                EmptyView()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(listing.image.enumerated()), id: \.offset) { (_, uiImage) in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 250, height: 200)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    private var listingDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Listing Details")
                .font(.headline)
                .foregroundColor(.secondary)

            listingDetailRow(title: "Total Bedrooms", value: "\(listing.totalNumberOfBedrooms)")
            listingDetailRow(title: "Total Bathrooms", value: "\(listing.totalNumberOfBathrooms)")
            listingDetailRow(title: "Square Footage", value: "\(listing.totalSquareFootage) sqft")
            listingDetailRow(title: "Bedrooms Available", value: "\(listing.numberOfBedroomsAvailable)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func listingDetailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }

    private var availabilitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Availability")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Available from \(formattedDate(listing.startDateAvailible)) to \(formattedDate(listing.lastDateAvailible))")
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Address")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(listing.address)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
    
    private var userInfoSection: some View {
        Group {
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
                .padding(.top, 30)
            } else {
                ProgressView("Loading poster info...")
                    .padding(.top, 30)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
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
