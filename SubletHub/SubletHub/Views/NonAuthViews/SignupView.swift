//
//  SignupView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct SignupView: View {
    @Environment(AuthViewModel.self) var authVM
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var error: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button("Sign Up") {
                signUp()
            }
            .disabled(isLoading)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }

    private func signUp() {
        Task {
            isLoading = true
            error = nil

            guard password == confirmPassword else {
                error = "Passwords do not match"
                isLoading = false
                return
            }

            do {
                try await authVM.signUp(email: email, password: password)
                dismiss() // return to login 
            } catch {
                self.error = error.localizedDescription
            }

            isLoading = false
        }
    }
}
