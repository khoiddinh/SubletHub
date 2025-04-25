//
//  AccountView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//
import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) var authVM
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    UserProfileCard()
                        .listRowInsets(EdgeInsets()) // optional: remove padding
                }

                Section {
                    NavigationLink(value: "edit") {
                        Label("Edit Profile", systemImage: "pencil")
                    }

                    NavigationLink(value: "help") {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }

                    Button(role: .destructive) {
                        authVM.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "arrow.right.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationDestination(for: String.self) { route in
                switch route {
                case "edit": EditProfileView()
                case "help": HelpView()
                default: Text("Unknown route")
                }
            }
            .navigationTitle("Account")
        }
    }
}
