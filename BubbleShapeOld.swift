//
//  BubbleShape.swift
//  PPL
//
//  Created by Todd Hassinger on 3/1/25.
//


// Views/BubbleShape.swift
import SwiftUI

struct BubbleShapeOld: Shape {
    let isSent: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailWidth: CGFloat = 10
        let tailHeight: CGFloat = 10
        
        var path = Path()
        
        if isSent {
            // Tail on bottom-right
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - radius - tailWidth, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.maxX - radius - tailWidth, y: rect.minY + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY - radius - tailHeight))
            path.addArc(center: CGPoint(x: rect.maxX - tailWidth - radius, y: rect.maxY - radius - tailHeight), radius: radius, startAngle: .degrees(0), endAngle: .degrees(45), clockwise: true)
            path.addLine(to: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY - tailHeight))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - tailWidth, y: rect.maxY - tailHeight))
            path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY - tailHeight))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius - tailHeight), radius: radius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: true)
        } else {
            // Tail on bottom-left
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY - radius - tailHeight))
            path.addLine(to: CGPoint(x: rect.minX + tailWidth, y: rect.maxY - tailHeight))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + tailWidth, y: rect.maxY - tailHeight))
            path.addArc(center: CGPoint(x: rect.minX + radius + tailWidth, y: rect.maxY - radius - tailHeight), radius: radius, startAngle: .degrees(90), endAngle: .degrees(0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY - tailHeight))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius - tailHeight), radius: radius, startAngle: .degrees(0), endAngle: .degrees(-90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + radius))
            path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius), radius: radius, startAngle: .degrees(-90), endAngle: .degrees(-180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + radius + tailWidth, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.minX + radius + tailWidth, y: rect.minY + radius), radius: radius, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: false)
        }
        
        return path
    }
}
