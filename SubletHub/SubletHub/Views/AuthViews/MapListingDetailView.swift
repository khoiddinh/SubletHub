import SwiftUI
import UIKit

struct MapListingDetailView: View {
  @State var listing: Listing
  
  @State private var userName: String?
  @State private var userEmail: String?
  @State private var showDeleteConfirmation = false
  
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var userListingViewModel: UserListingViewModel
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        listingHeader
        descriptionSection
        listingImages
        listingDetails
        availabilitySection
        CalendarView(startDate: listing.startDateAvailible,
                     endDate:   listing.lastDateAvailible)
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
    .navigationTitle("Listing Details")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear(perform: loadUserInfo)
    .alert("Delete Listing?", isPresented: $showDeleteConfirmation) {
      Button("Delete", role: .destructive) {
        userListingViewModel.deleteListing(listing: listing) { _ in
          ListingViewModel.shared.fetchData()
          dismiss()
        }
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Are you sure you want to permanently delete this listing?")
    }
  }
}

private extension MapListingDetailView {
  var listingHeader: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(listing.title)
        .font(.largeTitle).bold()
      Text("\(listing.price, format: .currency(code: "USD").precision(.fractionLength(0))) / month")
        .font(.title2).fontWeight(.semibold).foregroundColor(.green)
      Divider()
    }
  }
  
  var descriptionSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Description")
        .font(.headline).foregroundColor(.secondary)
      Text(listing.description)
        .font(.body)
    }
  }
  
  private var listingImages: some View {
      // if imageURLs is nil, treat it as an empty array:
      let urls = listing.imageURLs ?? []

      return Group {
        if urls.isEmpty {
          EmptyView()
        } else {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
              ForEach(urls, id: \.self) { urlString in
                if let url = URL(string: urlString) {
                  AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                      ProgressView()
                    case let .success(img):
                      img
                        .resizable()
                        .scaledToFill()
                        .frame(width: 250, height: 200)
                        .clipped()
                        .cornerRadius(10)
                    case .failure:
                      Color.gray
                    @unknown default:
                      EmptyView()
                    }
                  }
                }
              }
            }
            .padding(.vertical)
          }
        }
      }
    }

  
  var listingDetails: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Listing Details")
        .font(.headline).foregroundColor(.secondary)
      detailRow("Total Bedrooms", "\(listing.totalNumberOfBedrooms)")
      detailRow("Total Bathrooms", "\(listing.totalNumberOfBathrooms)")
      detailRow("Square Footage", "\(listing.totalSquareFootage) sqft")
      detailRow("Bedrooms Available", "\(listing.numberOfBedroomsAvailable)")
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.secondarySystemBackground)))
  }
  
  func detailRow(_ title: String, _ value: String) -> some View {
    HStack {
      Text(title)
      Spacer()
      Text(value)
    }
  }
  
  var availabilitySection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Availability")
        .font(.headline).foregroundColor(.secondary)
      Text("From \(formattedDate(listing.startDateAvailible)) to \(formattedDate(listing.lastDateAvailible))")
    }
  }
  
  var addressSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Address")
        .font(.headline).foregroundColor(.secondary)
      Text(listing.address)
    }
  }
  
  var userInfoSection: some View {
    Group {
      if let name = userName, let email = userEmail {
        VStack(alignment: .leading, spacing: 8) {
          Text("Posted By")
            .font(.headline).foregroundColor(.secondary)
          Text(name)
          Text(email).font(.subheadline).foregroundColor(.gray)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
                      .fill(Color(.secondarySystemBackground)))
        .padding(.top, 30)
      } else {
        ProgressView("Loading poster info…")
          .padding(.top, 30)
      }
    }
  }
  
  func loadUserInfo() {
    let uid = listing.userID ?? ""
    UserViewModel.getUserName(userID: uid) { self.userName = $0 }
    UserViewModel.getUserEmail(userID: uid) { self.userEmail = $0 }
  }
  
  func formattedDate(_ d: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    return f.string(from: d)
  }
}
