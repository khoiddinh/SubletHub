//
//  ContentView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Map", systemImage: "map", value: 0) {
                MapView()
            }
            Tab("Account", systemImage: "person", value: 1) {
                AccountView()
            }
        }
    }
}

#Preview {
    ContentView()
}
