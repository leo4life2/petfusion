//
//  ImagePicker.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import SwiftUI
import UIKit
import Foundation

// A view that brings up the default iOS image picker that allows the user to choose an image from their Photo Library
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var editedImage: EditedImage
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // before using the image, resize all images to 1024x1024 for stable diffusion reasons
                if let resizedImage = image.resizeAndCrop(targetSize: IMAGE_MAX_SIZE) {
                    self.parent.editedImage = EditedImage(image: resizedImage)
                }
            }
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        // no-op
    }
}
