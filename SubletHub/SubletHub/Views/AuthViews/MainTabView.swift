//
//  MainTabView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct MainTabView: View {
    @State private var selection: Int = 0
    @State var userListingViewModel = UserListingViewModel()
    
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Map", systemImage: "map", value: 0) {
                MapView()
            }
            Tab("My Listings", systemImage: "house", value: 1) {
                MyListingsView()
                    .environmentObject(userListingViewModel)
            }
            Tab("Account", systemImage: "person", value: 2) {
                AccountView()
            }
        }
    }
}
