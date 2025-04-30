import SwiftUI
import FirebaseStorage
import UIKit

struct ListingDetailView: View {
  let listingID: String

  @EnvironmentObject private var userListingViewModel: UserListingViewModel
  @Environment(\.dismiss)    private var dismiss

  @State private var userName:  String?
  @State private var userEmail: String?
  @State private var showDeleteConfirmation = false
  @State private var navigateToEdit       = false

  private var listing: Listing? {
    userListingViewModel.listings.first { $0.id == listingID }
  }

  var body: some View {
    Group {
      if let listing = listing {
        ScrollView {
          VStack(alignment: .leading, spacing: 20) {
            
            // MARK: – Title & Price
            Text(listing.title)
              .font(.largeTitle)
              .fontWeight(.bold)

            Text(
              "\(listing.price, format: .currency(code: "USD").precision(.fractionLength(0))) / month"
            )
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.green)

            // MARK: – Description
            Text("Description")
              .font(.headline)
              .foregroundColor(.secondary)
            Text(listing.description)

            Divider()

            // MARK: – Photos
            if !listing.image.isEmpty {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                  ForEach(listing.image, id: \.self) { uiImage in
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

            // MARK: – Numeric Details
            VStack(alignment: .leading, spacing: 8) {
              Text("Listing Details")
                .font(.headline)
                .foregroundColor(.secondary)
              detailRow("Total Bedrooms", "\(listing.totalNumberOfBedrooms)")
              detailRow("Total Bathrooms", "\(listing.totalNumberOfBathrooms)")
              detailRow("Square Footage",   "\(listing.totalSquareFootage) sqft")
              detailRow("Bedrooms Available", "\(listing.numberOfBedroomsAvailable)")
            }
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
            )

            Divider()

            // MARK: – Availability
            VStack(alignment: .leading, spacing: 8) {
              Text("Availability")
                .font(.headline)
                .foregroundColor(.secondary)
              Text("Available from \(formattedDate(listing.startDateAvailible)) to \(formattedDate(listing.lastDateAvailible))")
            }
            CalendarView(
              startDate: listing.startDateAvailible,
              endDate: listing.lastDateAvailible
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical)

            Divider()

            // MARK: – Address
            VStack(alignment: .leading, spacing: 8) {
              Text("Address")
                .font(.headline)
                .foregroundColor(.secondary)
              Text(listing.address)
            }

            // MARK: – Posted By
            if let name = userName, let email = userEmail {
              VStack(alignment: .leading, spacing: 8) {
                Text("Posted By")
                  .font(.headline)
                  .foregroundColor(.secondary)
                Text(name)
                Text(email)
                  .font(.subheadline)
                  .foregroundColor(.gray)
              }
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.secondarySystemBackground))
              )
              .padding(.top, 20)
            }

            // MARK: – Actions
            VStack(spacing: 12) {
              NavigationLink(
                destination: EditListingView(listing: listing),
                isActive: $navigateToEdit
              ) {
                Button("Edit Listing") {
                  navigateToEdit = true
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(12)
              }

              Button(role: .destructive) {
                showDeleteConfirmation = true
              } label: {
                Text("Delete Listing")
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(Color.red.opacity(0.9))
                  .foregroundColor(.white)
                  .cornerRadius(12)
              }
            }
            .padding(.top, 20)

          } // VStack
          .padding()
        } // ScrollView
      } else {
        Text("Listing no longer available.")
          .foregroundColor(.secondary)
      }
    } // Group
    .navigationTitle("Listing Details")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      if let l = listing { loadUserInfo(for: l) }
    }
    .alert("Delete Listing?",
           isPresented: $showDeleteConfirmation)
    {
      Button("Delete", role: .destructive) {
        if let l = listing {
          userListingViewModel.deleteListing(listing: l) { _ in
            ListingViewModel.shared.fetchData()
            dismiss()
          }
        }
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Are you sure you want to permanently delete this listing?")
    }
  }

  // MARK: – Row Helper
  private func detailRow(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title).font(.body)
      Spacer()
      Text(value).font(.body)
    }
  }

  // MARK: – Data Loading
  private func loadUserInfo(for listing: Listing) {
    let uid = listing.userID ?? ""
    UserViewModel.getUserName(userID: uid)  { userName  = $0 }
    UserViewModel.getUserEmail(userID: uid) { userEmail = $0 }
  }

  // MARK: – Date Formatting
  private func formattedDate(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f.string(from: date)
  }
}
