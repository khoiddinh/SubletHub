//
//  AuthViewModel.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import FirebaseAuth
import Observation

@Observable
class AuthViewModel {
    var user: User?
    
    init() {
        listen()
    }

    func listen() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func login(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = result.user
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }
}

