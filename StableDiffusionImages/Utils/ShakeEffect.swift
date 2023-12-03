//
//  ShakeEffect.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/24/23.
//

import SwiftUI

// Custom modifier for shake effect
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit), y: 0))
    }
}
