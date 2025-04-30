//
//  UserProfileCard.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI
import FirebaseAuth

struct UserProfileCard: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    func getInitials(_ name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components
            .compactMap { $0.first } // take first letter of each word
            .prefix(2)               // at most 2 initials
            .map { String($0) }
            .joined()
        print(initials)
        return initials.uppercased()
    }
    
    var body: some View {
        let initials = getInitials(authVM.user?.displayName ?? "")
        HStack(spacing: 17){
            Circle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(initials)
                        .padding(4)
                        .foregroundColor(.white)
                )
            // name
            Text(authVM.user?.displayName ?? "")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}
