//
//  ImageDebugView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/21/23.
//

import SwiftUI

struct ImageDebugView: View {

    var editedImageState: EditedImageState

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
            Text("Input Prompt: \(editedImageState.positivePrompt)")
                .font(.subheadline)
                .padding()

            Image(uiImage: editedImageState.selectedImage)
                .resizable()
                .scaledToFit()
                .padding()

            Image(uiImage: editedImageState.maskImage)
                .resizable()
                .scaledToFit()
                .padding()
        }
    }
}

