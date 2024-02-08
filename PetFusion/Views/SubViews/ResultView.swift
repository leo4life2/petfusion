//
//  ResultView.swift
//  PetFusion
//
//  Created by fdsa on 1/29/24.
//

import Foundation
import SwiftUI

// A view that prominently displays a single generated image
struct ResultView: View {
    @State var image: GenerativeImage?
    var body: some View {
        if let image = image {
            VStack {
                Spacer()
                Image(uiImage: image.toUIImage())
                    .resizable()
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                Spacer()
                
                ZStack {
                    ShareLink(
                        item: Image(uiImage: image.toUIImage()),
                        preview: SharePreview(
                            image.prompt,
                            image: Image(uiImage: image.toUIImage())
                        ),
                        label: {
                            HStack {
                                Text("Share")
                            }
                            .padding()
                            .frame(maxWidth: .greatestFiniteMagnitude)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding()
                        })
                }
            }
        }
    }
}
