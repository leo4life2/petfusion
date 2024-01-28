//
//  SettingsView.swift
//  TestGenerativeImages
//
//  Created by fdsa on 11/20/23.
//

import SwiftUI
import SwiftData
import Combine

struct SettingsView: View {
    // API Key for the Stable Diffusion API, stored in User Defaults
    @AppStorage("apiKey") var apiKey: String = ""

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack {
                HStack {
                    Text("Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                Form {
                    Group {
                        self.stableDiffusionSection
                        self.debugSection
                        self.infoSection
                    }
                }
            }
        }
    }

    var stableDiffusionSection: some View {
        return Section("API Preferences") {
            HStack {
                Text("API Key")
                TextField("API Key", text: $apiKey)
                    .onReceive(Just(apiKey), perform: { newApiKey in
                        // update new values in User Defaults
                        UserDefaults.standard.setValue(newApiKey, forKey: "apiKey")
                    })
            }
        }
    }

    var debugSection: some View {
        return Section("Debugging") {
            HStack {
                Button(action: {
                    // no-op
                    DispatchQueue.main.async {
                        let container = PetFusionApp.sharedModelContainer
                        container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg1")!.jpegData(compressionQuality: 0.75)!))
                        container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg2")!.jpegData(compressionQuality: 0.75)!))
                        container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg3")!.jpegData(compressionQuality: 0.75)!))
                    }
                }, label: {
                    Text("Add New Test Data")
                })
            }
            HStack {
                Button(action: {
                    // no-op
                    DispatchQueue.main.async {
                        try? PetFusionApp.sharedModelContainer.mainContext.delete(model: GenerativeImage.self)
                    }
                    UserDefaults.standard.removeObject(forKey: "apiKey")
                    UserDefaults.standard.removeObject(forKey: "didCompleteIntro")
                }, label: {
                    Text("Clear All Data")
                })
            }
        }
    }

    var infoSection: some View {
        return Section("Info") {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("""
                         Version: 1.0.0
                         """)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    Text("")
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("""
                         Made with ❤️ and ☕️ by fdsa
                         """)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
                    Text("")
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview {
    return SettingsView()
}
