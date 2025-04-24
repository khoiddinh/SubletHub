//
//  ContentView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @State var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.user != nil { // if logged in
                MainTabView()
                    .environment(authViewModel)
            } else { // not logged in
                LoginView()
                    .environment(authViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
