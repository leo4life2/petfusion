//
//  UIImage+Resize.swift
//  TestGenerativeImages
//
//  Created by fdsa on 11/17/23.
//

import SwiftUI
import PencilKit

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: (size.width * scaleFactor).rounded(.up),
            height: (size.height * scaleFactor).rounded(.up)
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }

        return scaledImage
    }

    func resizeAndCrop(targetSize: CGSize) -> UIImage? {
        let size = self.size

        // Calculate the scaling ratios
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Determine the scale to which the image will be resized
        let scaleFactor = max(widthRatio, heightRatio)

        // Calculate the new dimensions of the image
        let scaledWidth = size.width * scaleFactor
        let scaledHeight = size.height * scaleFactor
        let offsetX = (scaledWidth - targetSize.width) / 2
        let offsetY = (scaledHeight - targetSize.height) / 2

        // Create a graphics context with the target size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        self.draw(in: CGRect(x: -offsetX, y: -offsetY, width: scaledWidth, height: scaledHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    static func createBlankWhiteImage(width: Int, height: Int) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    static func imageWithWhiteBackground(from canvasView: PKCanvasView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: canvasView.bounds)
        let image = renderer.image { ctx in
            // Fill the background with white color
            UIColor.white.setFill()
            ctx.fill(canvasView.bounds)
            
            // Draw the canvas view's drawing on top of the white background
            canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    func invertColors() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputCIImage = filter.outputImage {
                return UIImage(cgImage: CIContext(options: nil).createCGImage(outputCIImage, from: outputCIImage.extent)!)
            }
        }
        return nil
    }
}
