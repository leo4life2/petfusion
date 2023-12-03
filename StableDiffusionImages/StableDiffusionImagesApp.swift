//
//  StableDiffusionImagesApp.swift
//  StableDiffusionImages
//
//  Created by Michael Zhu on 12/3/23.
//

import SwiftUI
import SwiftData

/*
 TODOs:
 - figure out issues with API and url links to images. try with python library
 - input validation for mask
 - make sure mask is black
 */

let DEFAULT_MODEL_CONTAINER: ModelContainer = try! ModelContainer(for: UserSettings.self, LibraryImage.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false, allowsSave: true))

@main
struct StableDiffusionImagesApp: App {

    @State private var selection = 2;
    private var container: ModelContainer = DEFAULT_MODEL_CONTAINER

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selection) {
                EditorView()
                    .tabItem {
                        Label("Editor", systemImage: "slider.horizontal.3")
                    }
                    .tag(1)

                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "photo.on.rectangle")
                    }
                    .tag(2)

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(3)
            }
            .modelContainer(self.container)
        }
    }
}
