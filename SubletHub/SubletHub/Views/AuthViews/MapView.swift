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
        .scaleEffect(selectedListing?.id == listing.id ? 1.2 : 1.0)
    }
    
}

struct ListingPopupView: View {
    @Environment(\.dismiss) private var dismiss

    let listing: Listing  // original passed in (can't mutate this)
    @State private var loadedListing: Listing  // mutable copy

    init(listing: Listing) {
        self.listing = listing
        _loadedListing = State(initialValue: listing)
    }

    var body: some View {
        VStack(spacing: 16) {
            ListingCard(listing: loadedListing)

            if !loadedListing.image.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(loadedListing.image.enumerated()), id: \.offset) { (_, uiImage) in
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width*0.95, height: 250)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical)
                }
            }


            Spacer()

            NavigationLink("View Details") {
                MapListingDetailView(listing: loadedListing)
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
        .task {
            loadedListing = await listing.loadingImages()
        }
    }
}
