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
            VStack(spacing: 20) {
                UserProfileCard()

                Button("Edit Profile") {
                    path.append("edit")
                }

                Button("Help & Support") {
                    path.append("help")
                }

                Spacer()
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "edit": EditProfileView()
                case "help": HelpView()
                default: Text("Unknown route")
                }
            }
            .padding()
            .navigationTitle("Account")
        }
        
    }
}
