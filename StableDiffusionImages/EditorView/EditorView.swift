//
//  EditorView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/17/23.
//

import SwiftUI
import PencilKit

/// Workaround, as SwiftUI does not work well with Optional binding :-(
let DEFAULT_EMPTY_IMAGE = UIImage(systemName: "questionmark.square")!
let IMAGE_MAX_SIZE = CGSizeMake(1024, 1024)

struct EditedImageState: Hashable {
    /// The image the user selected to generative edit
    public var selectedImage: UIImage = DEFAULT_EMPTY_IMAGE
    /// The PencilKit view storing information about the user-edited mask
    public var imageMaskCanvasView = PKCanvasView()
    /// The mask image generated from the above PencilKit view
    public var maskImage: UIImage = DEFAULT_EMPTY_IMAGE
    /// The positive text prompt associated with the input image
    public var positivePrompt: String = ""
    /// The negative text prompt associated with the input image
    public var negativePrompt: String = ""
    /// The final, generated stable diffusion image
    public var generativeImage: UIImage?

    public mutating func selectImage(image: UIImage) {
        self.selectedImage = image
    }

    public func hasUserSelectedImage() -> Bool {
        return self.selectedImage != DEFAULT_EMPTY_IMAGE
    }

    public mutating func addMaskImage(image: UIImage) {
        self.maskImage = image
    }

    public func hasUserAddedMaskImage() -> Bool {
        return self.maskImage != DEFAULT_EMPTY_IMAGE
    }

    public func hasUserAddedValidPrompt() -> Bool {
        return self.positivePrompt != ""
    }

    public func hasGenerativeImage() -> Bool {
        return self.generativeImage != nil
    }

    public mutating func clear() {
        self.selectedImage = DEFAULT_EMPTY_IMAGE
        self.imageMaskCanvasView = PKCanvasView()
        self.maskImage = DEFAULT_EMPTY_IMAGE
        self.positivePrompt = ""
        self.generativeImage = nil
    }
}

struct EditorState {
    public var isPhotosLibraryShowingImagePicker = false
    public var isPhotosLibraryShowingCamera = false
    public var isShowingMaskEditor = false
    public var isShowingDrawingPreview = false
    public var isInvalidPositiveInput: Bool = false
    public var isInvalidNegativeInput: Bool = false
}

struct EditorView: View {

    @State private var editorState = EditorState()
    @State private var editedImage = EditedImageState()

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack {
                if editedImage.hasUserSelectedImage() {
                    Spacer(minLength: 35)
                    EditorImageSelectedView(editorState: $editorState, editedImage: $editedImage)
                        .padding()
                } else {
                    HStack {
                        Text("Editor")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                    EditorNoSelectionView(editorState: $editorState, editedImage: $editedImage)
                        .padding()
                }
                Spacer()
            }
        }
    }
}

struct EditorImageSelectedView: View {

    @Binding var editorState: EditorState
    @Binding var editedImage: EditedImageState

    var body: some View {
        EditorImageCardView(editedImage: $editedImage)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.9)

        VStack {

            HStack {
                NeumorphicStyleTextField(isInputInvalid: editorState.isInvalidPositiveInput, textField: TextField("Positive Prompt...", text: $editedImage.positivePrompt), imageName: "plus.square")
            }
            HStack {
                NeumorphicStyleTextField(isInputInvalid: editorState.isInvalidNegativeInput, textField: TextField("Negative Prompt...", text: $editedImage.negativePrompt), imageName: "minus.square")
            }

            Spacer(minLength: 25)

            Button {
                if editedImage.positivePrompt.isEmpty || editedImage.negativePrompt.isEmpty {
                    withAnimation {
                        if editedImage.positivePrompt.isEmpty {
                            editorState.isInvalidPositiveInput = true
                        }
                        if editedImage.negativePrompt.isEmpty {
                            editorState.isInvalidNegativeInput = true
                        }
                    }
                    // Reset the animation state after it completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        editorState.isInvalidPositiveInput = false
                        editorState.isInvalidNegativeInput = false
                    }
                    return
                }
                editedImage.maskImage = editedImage.imageMaskCanvasView.drawing.image(from: editedImage.imageMaskCanvasView.bounds, scale: 1.0).scalePreservingAspectRatio(targetSize: editedImage.selectedImage.size)
                editorState.isShowingDrawingPreview = true
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Generate")
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            .sheet(isPresented: $editorState.isShowingDrawingPreview) {
                DrawingPreviewView(editorState: $editorState, editedImageState: $editedImage)
            }

            Spacer(minLength: 10)
        }
    }

}

struct EditorNoSelectionView: View {

    @Binding var editorState: EditorState
    @Binding var editedImage: EditedImageState

    var body: some View {
        HStack {
            Button {
                editorState.isPhotosLibraryShowingImagePicker = true
            } label: {
                HStack {
                    Image(systemName: "photo.badge.plus")
                    Text("Select Photo")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            }.sheet(isPresented: $editorState.isPhotosLibraryShowingImagePicker) {
                ImagePicker(sourceType: .photoLibrary, editedImage: $editedImage)
            }

            Button {
                editorState.isPhotosLibraryShowingCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill") // Camera icon from SF Symbols
                    Text("Take Photo")
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(10)
            }.sheet(isPresented: $editorState.isPhotosLibraryShowingCamera) {
                ImagePicker(sourceType: .camera, editedImage: $editedImage)
            }
        }
    }
}

#Preview {
    EditorView()
}
