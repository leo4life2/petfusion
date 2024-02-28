//
//  SettingsView.swift
//  TestGenerativeImages
//
//  Created by fdsa on 11/20/23.
//

import SwiftUI
import SwiftData
import Combine

struct InfoView: View {
    // API Key for the Stable Diffusion API, stored in User Defaults
    @AppStorage("apiKey") var apiKey: String = ""
    @ObservedObject private var rateLimiter = RateLimiter.shared

    var body: some View {
        ZStack {
            Color(uiColor: UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack {
                HStack {
                    Text("Info")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                Form {
                    Group {
                        self.rateLimitSection
                        self.questionsSection
                        self.infoSection
                        #if DEBUG
                        self.debugSection
                        #endif
                    }
                }
            }
        }
    }
    
    var rateLimitSection: some View {
        return Section("Image Generations") {
            VStack {
                HStack {
                    Spacer()
                    Text("\(self.rateLimiter.requestsLeft)").font(.largeTitle)
                    Text("Generations Remaining")
                    Spacer()
                }
                .padding([.bottom])
                HStack {
                    Spacer()
                    Text("Free users are limited to \(self.rateLimiter.requestLimit) generations per hour. You will receive more in \(lround(self.rateLimiter.timeUntilReset() / 60)) minutes")
                        .font(.subheadline)
                    Spacer()
                }
            }
        }
    }
    
    var questionsSection: some View {
        return Section("Contact Us") {
            HStack {
                Spacer()
                Link(destination: URL(string: "https://www.instagram.com/")!) {
                    Image("socialmedia_mail_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                Spacer()
                Link(destination: URL(string: "https://www.instagram.com/")!) {
                    Image("socialmedia_instagram_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                Spacer()
                Link(destination: URL(string: "https://www.instagram.com/")!) {
                    Image("socialmedia_wechat_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                Spacer()
                Link(destination: URL(string: "https://www.instagram.com/")!) {
                    Image("socialmedia_x_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
                Spacer()
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

    var debugSection: some View {
        return Section("[DEBUG ONLY]") {
            HStack {
                Text("API Key")
                TextField("API Key", text: $apiKey)
                    .onReceive(Just(apiKey), perform: { newApiKey in
                        // update new values in User Defaults
                        UserDefaults.standard.setValue(newApiKey, forKey: "apiKey")
                    })
            }
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
}

#Preview {
    return InfoView()
}
