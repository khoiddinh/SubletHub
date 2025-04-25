//
//  SearchBar.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/25/25.
//
import SwiftUI

// TODO: FIX SEARCH BAR SELECTION AND AUTOCOMPLETE
struct SearchBar: View {
    @State var searchQuery: String = ""
    
    @Binding var addressVM: AddressAutocompleteViewModel

    var body: some View {
        TextField("Search", text: $searchQuery)
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding()
            .onChange(of: searchQuery) {
                addressVM.updateSearch(query: searchQuery)
            }

        // results
        if !addressVM.searchResults.isEmpty {
            List(addressVM.searchResults, id: \.uniqueID) { completion in
                Button(action: {
                    //handleAddressSelection(completion)
                }) {
                    VStack(alignment: .leading) {
                        Text(completion.title)
                            .fontWeight(.semibold)
                        Text(completion.subtitle)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4) // optional spacing
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxHeight: 200)
        }
    }
}
