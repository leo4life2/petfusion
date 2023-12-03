//
//  ImageStore.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/24/23.
//

import SwiftUI
import SwiftData

@Model
class LibraryImage: Hashable, Identifiable {
    /// UUID representing this image
    @Attribute(.unique) public var id: UUID
    /// The positive text prompt associated with the input image
    public var positivePrompt: String
    /// The negative text prompt associated with the input image
    public var negativePrompt: String
    /// The final, generated stable diffusion image
    public var generativeImage: Data

    init(positivePrompt: String, negativePrompt: String, generativeImage: Data, id: UUID) {
        self.positivePrompt = positivePrompt
        self.negativePrompt = negativePrompt
        self.generativeImage = generativeImage
        self.id = id
    }

    func generativeUIImage() -> UIImage {
        return UIImage(data: self.generativeImage)!
    }
}
