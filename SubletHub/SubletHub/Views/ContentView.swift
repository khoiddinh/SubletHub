//
//  ContentView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/21/25.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject private var authVM: AuthViewModel

  var body: some View {
    Group {
      if authVM.user != nil {
        // user is signed in
        MainTabView()
      } else {
        // not signed in yet
        LoginView()
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(AuthViewModel())
      .environmentObject(UserListingViewModel())
  }
}
