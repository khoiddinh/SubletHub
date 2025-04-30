//
//  LoginView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String?
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    Text("SubletHub")
                        .font(.largeTitle)
                        .bold()

                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    if let error = error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button(action: login) {
                        Text("Log In")
                            .bold()
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(isLoading)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    NavigationLink("Create Account", destination: SignupView())
                        .padding(.top, 10)
                }
                .padding()

                if isLoading {
                    LoadingOverlay()
                }
            }
        }
    }

    private func login() {
        Task {
            isLoading = true
            error = nil
            do {
                try await authVM.login(email: email, password: password)
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }
}
