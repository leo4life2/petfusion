//
//  EditorDebugView.swift
//  PetFusion
//
//  Created by Michael Zhu on 2/4/24.
//

import Foundation
import SwiftUI

// A debug view that displays relevant data about the editd image
struct EditorDebugView: View {
    
    @State var selectedImage: EditedImage
    
    var body: some View {
        VStack {
            HStack {
                Text("""
                     [For Debugging] Loading generated image using the following source image, mask, and prompt
                     """)
                .font(.footnote)
                .padding()
                .foregroundColor(.gray)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 1)
                .padding()
                ProgressView().progressViewStyle(.circular)
            }
            Text("Input Prompt: \(self.selectedImage.prompt)")
                .font(.subheadline)
                .padding()

            Image(uiImage: self.selectedImage.image)
                .resizable()
                .scaledToFit()
                .padding()

            Image(uiImage: self.selectedImage.maskImage)
                .resizable()
                .scaledToFit()
                .padding()
        }
    }
}
