//
//  QuotesView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/30/23.
//

import SwiftUI

struct QuotesView: View {
    let quotes = [
        "Swapping time and space",
        "Spinning violently around the y-axis",
        "Tokenizing real life",
        "Bending the spoon",
        "Filtering morale",
        "Don't think of purple hippos",
        "We need a new fuse",
        "The architects are still drafting",
        "The bits are breeding",
        "We're building the buildings as fast as we can",
        "Pay no attention to the man behind the curtain",
        "enjoy the elevator music",
        "Don't worry - a few bits tried to escape, but we caught them",
        "Checking the gravitational constant in your locale",
        "Go ahead -- hold your breath",
    ]
    @State private var currentQuoteIndex = 0
    @State private var dots = ""

    var body: some View {
        Text("\(quotes[currentQuoteIndex])\(dots)")
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                    currentQuoteIndex = Int.random(in: 0..<quotes.count)
                }
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    dots = dots.count < 3 ? dots + "." : ""
                }
            }
            .multilineTextAlignment(.center)
            .padding()
    }
}
