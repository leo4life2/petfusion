//
//  MaskEditorView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/20/23.
//

import SwiftUI
import PencilKit

struct PencilKitView: UIViewRepresentable {

    var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        // Set up the canvasView
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 15)
        canvasView.drawingPolicy = .anyInput

        canvasView.backgroundColor = UIColor.clear

        // Add the tool picker
        setupToolPicker(for: canvasView)

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the view if needed.
    }

    private func setupToolPicker(for canvasView: PKCanvasView) {
        if let window = UIApplication.shared.windows.first,
           let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
}

struct EditorCreateMaskView: View {

    var selectedImage: UIImage
    var canvasView: PKCanvasView

    var body: some View {
        VStack {
            Image(systemName: "chevron.down").padding()
            Spacer()
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .overlay {
                    PencilKitView(canvasView: canvasView)
                }
            Spacer()
        }

    }
}

