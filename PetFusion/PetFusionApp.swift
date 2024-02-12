//
//  PetFusionApp.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import SwiftUI
import SwiftData

/**
 Before Ship:
 - fix "App Transport Security Settings"
 - figure out better way to store API Key?
 */

@main
struct PetFusionApp: App {
    // Indicates whether the user completed the introduction views
    // @AppStorage automatically reads the value from NSUserDefaults.standardUserDefaults
    @AppStorage("didCompleteIntro") var didCompleteIntro: Bool = false

    // Set up SwiftData schema and container
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GenerativeImage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if self.didCompleteIntro {
                MainTabView()
            } else {
                UserIntroView()
            }
        }
        .modelContainer(PetFusionApp.sharedModelContainer)
    }
}
