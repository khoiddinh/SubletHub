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
    var error: String?
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        listen()
    }

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    func login(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.user = result.user
            try await updateProfile(firstName: firstName, lastName: lastName)
            
        } catch {
            print("Signup error:", error)
            self.error = error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
    }
    
    func updateProfile(firstName: String, lastName: String) async throws {
        guard let user = user else { return }
        
        do {
            let request = user.createProfileChangeRequest()
            request.displayName = "\(firstName) \(lastName)"
            try await request.commitChanges()
        } catch {
            print("Failed to update profile:", error)
            self.error = error.localizedDescription
        }
        
    }
}

