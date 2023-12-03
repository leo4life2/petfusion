//
//  EditorImageCardView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/21/23.
//

import SwiftUI
import PencilKit

struct EditorImageCardView: View {

    @State var showingMaskEditor: Bool = false
    @Binding var editedImage: EditedImageState

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: editedImage.selectedImage)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 5)
                .frame(height: UIScreen.main.bounds.height * 0.45)

            HStack {
                Button {
                    showingMaskEditor.toggle()
                } label: {
                    Image(systemName: "theatermask.and.paintbrush")
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule(style: .continuous))
                        .padding()
                        .sheet(isPresented: $showingMaskEditor) {
                            EditorCreateMaskView(selectedImage: editedImage.selectedImage, canvasView: editedImage.imageMaskCanvasView)
                        }
                }

                Spacer()

                Button {
                    editedImage.clear()
                } label: {
                    Image(systemName: "x.circle")
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.35))
                        .clipShape(Capsule())
                        .padding()
                }
            }
        }
    }
}

struct PreviewWrapper_EditorImageCardView: View {
    @State var imageState = EditedImageState(selectedImage: UIImage(named: "cat2")!)
    var body: some View {
        EditorImageCardView(showingMaskEditor: false, editedImage: $imageState)
    }
}
#Preview {
    PreviewWrapper_EditorImageCardView()
}
