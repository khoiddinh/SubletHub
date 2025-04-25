//
//  Triangle.swift
//  SubletHub
//
//  Created by Khoi Dinh on 4/24/25.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))    // Top center
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))  // Bottom right
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))  // Bottom left
        path.closeSubpath()
        return path
    }
}
