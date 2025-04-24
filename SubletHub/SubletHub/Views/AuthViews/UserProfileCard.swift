//
//  UserProfileCard.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI
import FirebaseAuth

struct UserProfileCard: View {
    @Environment(AuthViewModel.self) var authVM
    
    func getInitials(_ name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components
            .compactMap { $0.first } // take first letter of each word
            .prefix(2)               // at most 2 initials
            .map { String($0) }
            .joined()
        return initials.uppercased()
    }
    
    var body: some View {
        let initials = getInitials(authVM.user?.displayName ?? "")
        
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.7))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(initials)
                        .font(.title)
                        .foregroundColor(.white)
                )

            // Name or email
            Text(authVM.user?.displayName ?? "")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}
