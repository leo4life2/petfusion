//
//  PersistentSettings.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/24/23.
//

import SwiftData

enum GenerationType : String, Codable, CaseIterable, Identifiable {
    case img2img, inpaint

    var id: Self { self }
}

@Model
class UserSettings {
    var apiKey: String
    var generationType: GenerationType
    var enhancePrompt: Bool
    var promptStrength: Double

    // for debugging / prototyping
    var useDefaultImage: Bool

    @MainActor public class func shared() throws -> UserSettings {
        try self.ensureSingleInstance()
        let context = DEFAULT_MODEL_CONTAINER.mainContext
        let fetchAll = FetchDescriptor<UserSettings>()
        let allSettings = try context.fetch(fetchAll)
        return allSettings.first!
    }

    @MainActor class func ensureSingleInstance() throws {
        let context = DEFAULT_MODEL_CONTAINER.mainContext
        let fetchAll = FetchDescriptor<UserSettings>()
        let allSettings = try context.fetch(fetchAll)
        if allSettings.count == 0 {
            context.insert(UserSettings())
        }
        if allSettings.count > 1 {
            for userSetting in allSettings[1...allSettings.count] {
                context.delete(userSetting)
            }
        }
    }

    convenience init() {
        self.init(
            apiKey: "foo", // replace with actual StableDiffusion API Key
            generationType: .img2img,
            enhancePrompt: true,
            promptStrength: 0.7,
            useDefaultImage: true
        )
    }

    init(apiKey: String, generationType: GenerationType, enhancePrompt: Bool, promptStrength: Double, useDefaultImage: Bool) {
        self.apiKey = apiKey
        self.generationType = generationType
        self.enhancePrompt = enhancePrompt
        self.promptStrength = promptStrength
        self.useDefaultImage = useDefaultImage
    }
}
