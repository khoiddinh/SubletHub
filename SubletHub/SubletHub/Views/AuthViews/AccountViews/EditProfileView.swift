//
//  EditProfileView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
            }

            Section(header: Text("Email")) {
                if let email = authViewModel.user?.email {
                    Text(email)
                        .foregroundColor(.gray)
                }
            }

            if let error = error {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }

            Section {
                Button(isSaving ? "Saving..." : "Save Changes") {
                    saveProfile()
                }
                .disabled(isSaving)
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            if let displayName = authViewModel.user?.displayName {
                let parts = displayName.split(separator: " ")
                if parts.count >= 2 {
                    firstName = String(parts[0])
                    lastName = String(parts[1])
                } else if parts.count == 1 {
                    firstName = String(parts[0])
                }
            }
        }
    }

    private func saveProfile() {
        Task {
            isSaving = true
            error = nil
            do {
                try await authViewModel.updateProfile(firstName: firstName, lastName: lastName)
                dismiss()
            } catch {
                self.error = error.localizedDescription
            }
            isSaving = false
        }
    }
}
