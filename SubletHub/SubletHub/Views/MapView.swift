//
//  MapView.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/23/25.
//

import SwiftUI

struct MapView: View {
    @State private var selection: Int = 0
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Map", systemImage: "map", value: 0) {
                MapView()
            }
            Tab("")
        }
    }
}

