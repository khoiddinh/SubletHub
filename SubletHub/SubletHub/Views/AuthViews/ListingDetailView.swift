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
                
                // Description
                Text(listing.description)
                    .font(.title3)
            

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
                else {
                  
                }
//                if let imageURLs = listing.imageURLs, !imageURLs.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 10) {
//                            ForEach(imageURLs, id: \.self) { urlString in
//                                AsyncImage(url: URL(string: urlString)) { phase in
//                                    switch phase {
//                                    case .empty:
//                                        ProgressView()
//                                            .frame(width: 250, height: 200)
//                                    case .success(let image):
//                                        image
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 250, height: 200)
//                                            .clipped()
//                                            .cornerRadius(10)
//                                    case .failure:
//                                        Image(systemName: "photo")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 250, height: 200)
//                                            .foregroundColor(.gray)
//                                    @unknown default:
//                                        EmptyView()
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical)
//                    }
//                }

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
            Button("Delete", role: .destructive, action: deleteListing)
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
    
    private func deleteListing() {
        guard let id = listing.id else { return }
        
        guard let url = URL(string: "https://us-central1-\(Config.PROJECT_ID).cloudfunctions.net/deleteListing?id=\(id)") else {
            print("Invalid delete URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // Cloud Function expects GET with query param

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error deleting listing:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response deleting listing.")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Listing deleted successfully.")
                DispatchQueue.main.async {
                    dismiss() // Dismiss the view after successful deletion
                }
            } else {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Delete failed: \(errorMessage)")
                } else {
                    print("Delete failed with status code:", httpResponse.statusCode)
                }
            }
        }.resume()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

extension Listing {

    func loadingImages() async -> Listing {
        guard let sid = storageID else { return self }

        let folderRef = Storage.storage()
                               .reference(withPath: "listings/\(sid)")
        var copy = self                                         // ← var

        do {
            let result = try await folderRef.listAll()
            let sorted = result.items.sorted { $0.name < $1.name }

            for ref in sorted {
                if let data = try? await ref.data(maxSize: 4 * 1024 * 1024),
                   let img  = UIImage(data: data) {
                    copy.image.append(img)
                }
            }
        } catch {
            print("image error:", error.localizedDescription)
        }
        return copy
    }
}
