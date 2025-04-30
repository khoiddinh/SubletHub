//
//  SearchBar.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI
import MapKit

struct SearchBar: View {
    @State var searchQuery: String = ""
    @State var suppressAutoComplete: Bool = false
    @State var address: String = ""
    @State var latitude: Double?
    @State var longitude: Double?
    
    @ObservedObject var addressVM: AddressAutocompleteViewModel
    @Binding var position: MapCameraPosition

    var body: some View {
        VStack (spacing: 0){
            TextField("Search", text: $searchQuery)
                .padding(10)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.top)
                .padding(.horizontal)
                .shadow(radius: 2)
                .onChange(of: searchQuery) {
                    if suppressAutoComplete {
                        suppressAutoComplete = false
                        return
                    }
                    addressVM.updateSearch(query: searchQuery)
                }
            
            // results
            if !addressVM.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(addressVM.searchResults.prefix(2), id: \.uniqueID) { completion in
                        Button(action: {
                            handleAddressSelection(completion)
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(completion.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal)
                                    .padding(.top, 2)
                                    .padding(.bottom, 1)
                                Text(completion.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.bottom, 0.5)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .opacity(0.8)
                            .cornerRadius(5)
                            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            } else if !suppressAutoComplete && !searchQuery.isEmpty && addressVM.searchResults.isEmpty && address != searchQuery {
                Text("No results found")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    func handleAddressSelection(_ completion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)

        search.start { response, error in
            if let item = response?.mapItems.first {
                let placemark = item.placemark
                let coord = placemark.coordinate
                let isCoordValid = CLLocationCoordinate2DIsValid(coord) &&
                                   (coord.latitude != 0 && coord.longitude != 0)

                self.suppressAutoComplete = true
                self.address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .joined(separator: ", ")
                self.latitude = coord.latitude
                self.longitude = coord.longitude
                self.searchQuery = self.address

                withAnimation {
                    self.addressVM.searchResults = []

                    if isCoordValid {
                        position = .region(
                            MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        )
                    } else if var region = response?.boundingRegion {
                        // fallback to center of bounding region (for cities)
                        region.span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15) // zoom out more for cities
                        position = .region(region)
                    } else {
                        print("No valid coordinates or bounding region found.")
                    }
                }
            } else if let error = error {
                print("Search error:", error.localizedDescription)
            }
        }
    }

}
