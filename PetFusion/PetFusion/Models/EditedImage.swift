//
//  EditedImage.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import Foundation
import SwiftUI

let IMAGE_MAX_SIZE = CGSizeMake(1024, 1024)
// Workaround, as SwiftUI does not work well with Optional binding :/
let DEFAULT_EMPTY_IMAGE = UIImage.createBlankWhiteImage(width: Int(IMAGE_MAX_SIZE.width), height: Int(IMAGE_MAX_SIZE.height))

// An image that is currently being edited by the user
struct EditedImage {
    public var image: UIImage = DEFAULT_EMPTY_IMAGE
    public var maskImage: UIImage = DEFAULT_EMPTY_IMAGE
    public var prompt: String = ""

    public func hasSelectedImage() -> Bool {
        return self.image != DEFAULT_EMPTY_IMAGE
    }
    
    public mutating func updateMask(maskImage: UIImage) {
        self.maskImage = maskImage
    }
    
    public mutating func updatePrompt(prompt: String) {
        self.prompt = prompt
    }
}
