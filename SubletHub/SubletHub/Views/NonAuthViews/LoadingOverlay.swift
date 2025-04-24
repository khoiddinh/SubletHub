//
//  LoadingOverlay.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//
import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            ProgressView()
                .scaleEffect(2.0)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
        }
    }
}
