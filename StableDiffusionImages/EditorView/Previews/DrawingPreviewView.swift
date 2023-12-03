//
//  DrawingPreviewView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/17/23.
//

import SwiftUI
import SwiftData

struct DrawingPreviewContentView: View {
    @Environment(\.modelContext) private var context

    // Content shown on the page - uuid is the uuid from the saved LibraryImage SwiftData Model, otherwise
    // it is "nil" if the LibraryImage model is yet unsaved
    var image: UIImage
    var positivePrompt: String
    var negativePrompt: String
    @State var libraryImageUUID: UUID?

    // Triggers alert after pressing "Save", timer is to auto-dismiss
    @State var showAlert: Bool = false
    @State var timer: Timer?

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack {
                Image(systemName: "chevron.down")
                    .padding()
                Spacer(minLength: 20)

                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 5)
                    .frame(height: UIScreen.main.bounds.height * 0.45)
                    .padding()

                List {
                    HStack {
                        Image(systemName: "plus.square")
                        Text("Prompt:")
                        Spacer()
                        Text(positivePrompt)
                    }
                    HStack {
                        Image(systemName: "minus.square")
                        Text("Prompt:")
                        Spacer()
                        Text(negativePrompt)
                    }
                    HStack {
                        Image(systemName: "calendar")
                        Text("Date:")
                        Spacer()
                        Text("\(Date().formatted(.dateTime.day().month().year()))")
                    }
                }
                .scrollDisabled(true)

                Spacer()

                HStack {
                    let representsUnsavedImage: Bool = self.libraryImageUUID == nil
                    if representsUnsavedImage {
                        Button {
                            let uuid = UUID()
                            let newImage = LibraryImage(
                                positivePrompt: positivePrompt,
                                negativePrompt: negativePrompt,
                                generativeImage: image.pngData()!,
                                id: uuid)
                            self.libraryImageUUID = uuid

                            self.context.insert(newImage)

                            showAlert = true
                            // Dismiss the alert after 2 seconds
                            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
                                showAlert = false
                                timer?.invalidate()
                            }
                        } label: {
                            Label("Save", systemImage: "photo.badge.arrow.down")
                                .padding()
                                .foregroundColor(.blue)
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Saved"), message: Text("✅"))
                        }
                        Spacer()
                        ShareLink(item: Image(uiImage: image),
                                  preview: SharePreview(
                                    "Generated Image",
                                    image: Image(uiImage: image)
                                  )
                        )
                        .foregroundColor(.blue)
                        .padding()
                    } else {
                        Spacer()
                        ShareLink(item: Image(uiImage: image),
                                  preview: SharePreview(
                                    "Generated Image",
                                    image: Image(uiImage: image)
                                  )
                        )
                        .foregroundColor(.blue)
                        .padding()
                        Spacer()
                    }
                }

                Spacer()
            }
        }
    }

}

struct DrawingPreviewLoadingView: View {

    @State var showingDebugView: Bool = false
    @Binding var editedImageState: EditedImageState

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                LoadingCircleView()
            }
            Spacer()
            HStack {
                QuotesView()
                    .padding()
                    .font(.subheadline)
            }
            Spacer()
            HStack {
                Button {
                    showingDebugView.toggle()
                } label: {
                    Text("[Debug]")
                        .font(.footnote)
                        .padding()
                }
                .sheet(isPresented: $showingDebugView) {
                    ImageDebugView(editedImageState: editedImageState)
                }
            }
        }
    }
}

struct DrawingPreviewView: View {

    @Binding var editorState: EditorState
    @Binding var editedImageState: EditedImageState
    @State var showingDebugView: Bool = false
    @State var hasError: Bool = false
    @State var error: Error?

    var body: some View {
        VStack {
            if editedImageState.hasGenerativeImage() {
                DrawingPreviewContentView(
                    image: editedImageState.generativeImage!,
                    positivePrompt: editedImageState.positivePrompt,
                    negativePrompt: editedImageState.negativePrompt,
                    libraryImageUUID: nil
                )
            } else {
                DrawingPreviewLoadingView(editedImageState: $editedImageState)
                    .task {
                        do {
                            editedImageState.generativeImage = try await StableDiffusionAPI().img2img(
                                image: editedImageState.selectedImage,
                                positivePrompt: editedImageState.positivePrompt,
                                negativePrompt: editedImageState.negativePrompt
                            )
                        } catch {
                            self.hasError = true
                            self.error = error
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.editorState.isShowingDrawingPreview = false
                            }
                        }
                    }
            }
        }.alert(isPresented: $hasError) {
            Alert(
                title: Text("Error"),
                message: Text("There was an error in the API call: \(self.error?.localizedDescription ?? "")"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct Preview_DrawingPreviewView: View {
    @State var editorState = EditorState(
        isPhotosLibraryShowingImagePicker: false,
        isPhotosLibraryShowingCamera: false,
        isShowingMaskEditor: false,
        isShowingDrawingPreview: false,
        isInvalidPositiveInput: false,
        isInvalidNegativeInput: false)
    @State var imageState = EditedImageState(
        selectedImage: UIImage(named: "img1")!,
        maskImage: UIImage(named: "img2")!,
        positivePrompt: "foobar",
        generativeImage: UIImage(named: "img3")!
    )
    var body: some View {
        DrawingPreviewLoadingView(editedImageState: $imageState)
//        DrawingPreviewView(editorState: $editorState, editedImageState: $imageState)
    }
}
#Preview {
    Preview_DrawingPreviewView()
}

