//
//  ListingDetailView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI
import FirebaseStorage
import UIKit

struct ListingDetailView: View {
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

                if !listing.image.isEmpty {
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


                // Additional Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("Listing Details")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Total Bedrooms:")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(listing.totalNumberOfBedrooms)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Total Bathrooms:")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(listing.totalNumberOfBathrooms)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Square Footage:")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(listing.totalSquareFootage) sqft")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Bedrooms Available:")
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(listing.numberOfBedroomsAvailable)")
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Availability")
                        .font(.headline)
                        .foregroundColor(.secondary)

                Text("Available from \(formattedDate(listing.startDateAvailible)) to \(formattedDate(listing.lastDateAvailible))")
                    .font(.body)
                    .foregroundColor(.primary)
                }
        
                // Availability Dates - Calendar (Read-Only)
                CalendarView(startDate: listing.startDateAvailible, endDate: listing.lastDateAvailible)
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
                VStack(spacing: 12) {
                    // Edit Button
                    NavigationLink(destination: EditListingView(listing: listing), isActive: $navigateToEdit) {
                        Button {
                            navigateToEdit = true
                        } label: {
                            Text("Edit Listing")
                                .font(.body)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }

                    // Delete Button
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete Listing")
                            .font(.body)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 30)
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
            Button("Delete", role: .destructive, action: {
                userListingViewModel.deleteListing(listing: listing)
                dismiss()
            })
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to permanently delete this listing?")
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


    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

