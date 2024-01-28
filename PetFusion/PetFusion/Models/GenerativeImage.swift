//
//  GenerativeImage.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import Foundation
import SwiftUI
import SwiftData

// A user-generated generative image that has been saved
@Model
class GenerativeImage: Hashable, Identifiable {
    /// UUID representing this image
    @Attribute(.unique) public var id: UUID
    /// The text prompt associated with the input image
    public var prompt: String
    /// The final, generated stable diffusion image
    public var imageData: Data

    init(id: UUID, prompt: String, imageData: Data) {
        self.prompt = prompt
        self.imageData = imageData
        self.id = id
    }

    func toUIImage() -> UIImage {
        return UIImage(data: self.imageData)!
    }
}
