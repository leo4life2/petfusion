//
//  ImageDrawingView.swift
//  PetFusion
//
//  Created by Michael Zhu on 2/3/24.
//

import Foundation
import PencilKit
import SwiftUI

// a view that can be drawn upon via PencilKit
// placed over the image to allow the user to draw masks
struct ImageDrawingView: UIViewRepresentable {

    @Binding var strokeSize: Double
    var isKeyboardVisible: Bool
//    let strokeColor = Color(hex: "#7E76FA")
    let strokeColor = Color.black
    var canvasView: PKCanvasView

    func makeUIView(context: Context) -> PKCanvasView {
        // Set up the canvasView, we explicitly do not set up the ToolPicker so that it is not shown to the user
        canvasView.delegate = context.coordinator
        updateTool(for: canvasView)
        canvasView.tool = PKInkingTool(.monoline, color: UIColor(self.strokeColor), width: CGFloat(self.strokeSize))
        canvasView.drawingPolicy = .anyInput
        canvasView.backgroundColor = UIColor.clear
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update the view if needed.
        updateTool(for: uiView)
        uiView.isUserInteractionEnabled = !isKeyboardVisible
    }
    
    private func updateTool(for canvasView: PKCanvasView) {
        // .monoline means that the drawing tool is a perfect circle
        // strokeColor is adjusted so that the mask is purple
        // strokeSize is adjustable via the slider in the eidtor view
        canvasView.tool = PKInkingTool(.monoline, color: UIColor(self.strokeColor), width: CGFloat(self.strokeSize))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: ImageDrawingView

        init(_ parent: ImageDrawingView) {
            self.parent = parent
        }
    }
}
