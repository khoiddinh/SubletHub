import SwiftUI
import MapKit

struct MapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.9526, longitude: -75.1652),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    @State private var viewModel = ListingViewModel()
    @State private var addressVM = AddressAutocompleteViewModel()
    @State private var selectedListing: Listing? = nil
    
    
    var body: some View {
        ZStack(alignment: .top) {
            listingsMap
                .onAppear { viewModel.fetchData() }
            SearchBar(addressVM: $addressVM, position: $position)
        }
        // now only one sheet, no outer tap gesture to clear it
        .sheet(item: $selectedListing) { listing in
            NavigationStack {
                ListingPopupView(listing: listing)
            }
        }
    }
    
    private var listingsMap: some View {
        Map(position: $position, interactionModes: .all) {
            ForEach(viewModel.listings.filter { $0.id != nil }) { listing in
                Annotation("", coordinate: listing.coordinate) {
                    // wrap in a Button so taps are always recognized
                    Button {
                        withAnimation {
                            selectedListing = listing
                        }
                    } label: {
                        annotationView(for: listing)
                    }
                    .buttonStyle(.plain)
                }
                .annotationTitles(.hidden)
            }
        }
    }
    
    @ViewBuilder
    private func annotationView(for listing: Listing) -> some View {
        ZStack {
            if selectedListing?.id == listing.id {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
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
                    .scaleEffect(x: 1, y: -1)
            }
        }
        .offset(y: -20)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedListing = listing
            }
        }
        .scaleEffect(selectedListing?.id == listing.id ? 1.2 : 1.0)
    }
    
}

struct ListingPopupView: View {
    @Environment(\.dismiss) private var dismiss

    let listing: Listing

    var body: some View {
        VStack(spacing: 16) {
            // Placeholder image – swap in AsyncImage when you have URLs
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 180)
                .overlay(Text("Image Placeholder"))

            VStack(alignment: .leading, spacing: 8) {
                Text(listing.title)
                    .font(.headline)
                Text("$\(listing.price) / month")
                    .font(.subheadline)
                    .foregroundColor(.green)
                HStack {
                    Text("\(listing.numberOfBedroomsAvailable) bd")
                    Text("•")
                    Text("\(listing.totalNumberOfBathrooms) ba")
                    Text("•")
                    Text("\(listing.totalSquareFootage) ft²")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Spacer()

            NavigationLink("View Details") {
                            ListingDetailView(listing: listing)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .navigationTitle("Preview")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Close") {
                                dismiss()
                            }
                        }
                    }
                }
            }
