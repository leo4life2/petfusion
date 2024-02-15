//
//  SubjectDetector.swift
//  PetFusion
//
//  Created by Leo Li on 2024/2/14.
//

import Foundation
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

public struct SubjectLifter {
    enum ImageExtractError: Error {
        case noResultFromForegroundMaskRequest
        case cgImageConversionFailed
    }

    public static func getSubjectMask(from image: CGImage) throws -> UIImage {
        let request = VNGenerateForegroundInstanceMaskRequest()

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        guard let result = request.results?.first else {
            throw ImageExtractError.noResultFromForegroundMaskRequest
        }

        let maskedImageBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: false
        )
        
        // Convert the CVImageBuffer to CIImage
        let maskCIImage = CIImage(cvPixelBuffer: maskedImageBuffer)
        
        // Prepare a context to perform Core Image operations
        let context = CIContext()
        
        // Use Core Image to invert the alpha of the mask, making transparent pixels opaque and vice-versa
        let invertedMask = maskCIImage.applyingFilter("CIColorInvert")

        // Create an all-white image
        let whiteImage = CIImage(color: CIColor.white).cropped(to: maskCIImage.extent)
        
        // Use the inverted mask to blend the white image onto a transparent background
        let blendFilter = CIFilter.blendWithAlphaMask()
        blendFilter.inputImage = whiteImage
        blendFilter.backgroundImage = CIImage(color: .black).cropped(to: maskCIImage.extent)
        blendFilter.maskImage = invertedMask
        
        guard let blendedImage = blendFilter.outputImage else {
            throw ImageExtractError.noResultFromForegroundMaskRequest // Adjust error handling as needed
        }
        
        // Convert the output CIImage to UIImage
        if let outputCGImage = context.createCGImage(blendedImage, from: blendedImage.extent) {
            return UIImage(cgImage: outputCGImage)
        } else {
            throw ImageExtractError.noResultFromForegroundMaskRequest // Adjust error handling as needed
        }
    }
}
