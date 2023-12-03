//
//  SettingsView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/20/23.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @State var userSetting: UserSettings?

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
                if let userSetting = self.userSetting {
                    Form {
                        Group {
                            self.stableDiffusionSection(userSetting: userSetting)
                            self.debugSection(userSetting: userSetting)
                            self.infoSection(userSetting: userSetting)
                        }
                    }
                }
            }
        }.onAppear(perform: {
            do {
                userSetting = try UserSettings.shared()
            } catch {
                // no-op
            }
        })
    }

    func stableDiffusionSection(userSetting: UserSettings) -> some View {
        return Section("Stable Diffusion API Preferences") {
            HStack {
                Text("API Key")
                TextField("API Key", text: Bindable(userSetting).apiKey)
            }

            HStack {
                Picker("Generation Types", selection: Bindable(userSetting).generationType) {
                    ForEach(GenerationType.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
            }

            HStack {
                Toggle("Enhance Prompt", isOn: Bindable(userSetting).enhancePrompt)
            }

            HStack {
                Picker("Prompt Strength", selection: Bindable(userSetting).promptStrength) {
                    ForEach(Array(stride(from: 0, to: 1.1, by: 0.1)), id: \.self) { index in
                          Text(String(format: "%.1f", index))
                             .tag(index)
                          }
                }
            }
        }
    }

    func debugSection(userSetting: UserSettings) -> some View {
        return Section("Debugging") {
            HStack {
                Toggle("Use Default Image", isOn: Bindable(userSetting).useDefaultImage)
            }
        }
    }

    func infoSection(userSetting: UserSettings) -> some View {
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
                         Made with ❤️ and ☕️ by foobar
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserSettings.self, configurations: config)
    container.mainContext.insert(UserSettings(apiKey: "asdf", generationType: .img2img, enhancePrompt: true, promptStrength: 0.3, useDefaultImage: true))
    return SettingsView()
        .modelContainer(container)
}
