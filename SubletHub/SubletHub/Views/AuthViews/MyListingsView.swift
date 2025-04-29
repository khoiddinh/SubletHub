//
//  MyListingsView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/28/25.
//


//
//  MyListingsView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI

struct MyListingsView: View {
    @State var path = NavigationPath()
    @Environment(AuthViewModel.self) var authViewModel
    @Environment(UserListingViewModel.self) var userListingViewModel
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    NavigationLink(destination: CreateListingView()) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Create New Listing")
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)

                    ForEach(userListingViewModel.listings) { listing in
                        NavigationLink(value: listing) {
                            ListingCard(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
            .navigationDestination(for: Listing.self) { listing in
                ListingDetailView(listing: listing)
            }
        }
        .navigationTitle(Text("My Listings"))
        .onAppear {
            if let uid = authViewModel.user?.uid {
                userListingViewModel.loadListings(for: uid)
            }
        }
    }
    
}