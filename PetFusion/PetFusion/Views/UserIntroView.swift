//
//  UserIntroView.swift
//  PetFusion
//
//  Created by fdsa on 1/29/24.
//

import Foundation
import SwiftUI

// Content and Data specific to a page in the user intro flow
struct IntroSubViewContent: Hashable {
    var image: UIImage
    var headline: String
    var description: String
    var highlightedCircle: Int
}

// Specific content for each page
let INTRODUCTION_CONTENT = [
    IntroSubViewContent(
        image: UIImage(named: "intro001")!,
        headline: "Transform your pet portrait!",
        description: "Unleash your imagination, and transform images of your pet into anything you can think of\n",
        highlightedCircle: 1
    ),
    IntroSubViewContent(
        image: UIImage(named: "intro002")!,
        headline: "Step 1: Scribble",
        description: "Upload your image, and scribble to indicate the section of your pet to keep. The rest of the image will be transformed by AI",
        highlightedCircle: 2
    ),
    IntroSubViewContent(
        image: UIImage(named: "intro003")!,
        headline: "Step 2: Input Prompt",
        description: "Unleash your imagination, and describe the desired image that you want!\n",
        highlightedCircle: 3
    ),
    IntroSubViewContent(
        image: UIImage(named: "intro004")!,
        headline: "Step 3: See Result",
        description: "Look at your created masterpiece - don't forget to share with friends!\n",
        highlightedCircle: 4
    ),
]

// Main view displaying content for a specific IntroSubViewContent. Each IntroSubView is a pane in the ScrollView
struct IntroSubView: View {
    // Content to be displayed
    var content: IntroSubViewContent
    // Action to be performed when the next button is pressed
    var onNext: () -> Void

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text("Petfusion!")
                    .padding([.leading, .top])
                    .font(.system(size: 25))
                    .bold()
                    .foregroundColor(Color(hex: "#7E76FA"))
                Spacer()
            }
            .padding([.bottom])
            
            Image(uiImage: self.content.image)
                .resizable()
                .frame(height: UIScreen.main.bounds.height * 0.45)
            
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .fill(self.content.highlightedCircle == 1 ? Color(hex: "#DF7544") : Color(hex: "#7E76FA"))
                            .frame(width: 35, height: 35)
                        Text("1")
                            .foregroundColor(Color.white)
                            .font(.system(size: 25))
                    }
                    Text("Preview")
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .fill(self.content.highlightedCircle == 2 ? Color(hex: "#DF7544") : Color(hex: "#7E76FA"))
                            .frame(width: 35, height: 35)
                        Text("2")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                    Text("Scribble")
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .fill(self.content.highlightedCircle == 3 ? Color(hex: "#DF7544") : Color(hex: "#7E76FA"))
                            .frame(width: 35, height: 35)
                        Text("3")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                    Text("Prompt")
                }
                Spacer()
                VStack {
                    ZStack {
                        Circle()
                            .fill(self.content.highlightedCircle == 4 ? Color(hex: "#DF7544") : Color(hex: "#7E76FA"))
                            .frame(width: 35, height: 35)
                        Text("4")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                    Text("Voila!")
                }
                Spacer()
            }
            .padding([.top])
            
            Text(self.content.headline)
                .font(.system(size: 25))
                .bold()
                .padding()
    
            Text(self.content.description)
                .font(.system(size: 16))
                .padding([.leading, .trailing])
            
            Spacer()
            
            Button(action: {
                onNext()
            }, label: {
                HStack {
                    Text("Next")
                        .font(.system(size: 17))
                        .bold()
                        .foregroundColor(Color(hex: "#DF7544"))
                        .padding([.trailing, .leading], 40)
                }
            })
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#DF7544"), lineWidth: 3)
            }
            
            Spacer(minLength: 60)
        }
    }
}

// Main ScrollView containing all IntroSubViews
struct UserIntroView: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage,
                content:  {
            ForEach(0..<INTRODUCTION_CONTENT.count, id: \.self) { index in
                let content = INTRODUCTION_CONTENT[index]
                IntroSubView(content: content) {
                    // when the "next" button is pressed...
                    if index < INTRODUCTION_CONTENT.count - 1 {
                        // keep scrolling to next page
                        withAnimation {
                            currentPage = index + 1
                        }
                    } else if index >= INTRODUCTION_CONTENT.count - 1 {
                        // if we've hit the last page, update UserDefaults
                        // the main PetFusionApp App listens for changes to didCompleteIntro,
                        // and will automatically display the MainTabView
                        UserDefaults.standard.setValue(true, forKey: "didCompleteIntro")
                    }
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .tag(index)
            }
        })
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

#Preview {
    UserIntroView()
}
