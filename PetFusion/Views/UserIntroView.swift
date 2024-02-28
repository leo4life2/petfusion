//
//  UserIntroView.swift
//  PetFusion
//
//  Created by fdsa on 1/29/24.
//

import Foundation
import SwiftUI

// Main ScrollView containing all IntroSubViews
struct UserIntroView: View {
    @State private var currentPage = 0
    
    var first: some View {
        VStack {
            Image(uiImage: UIImage(named: "intro001")!)
                .resizable()
                .frame(height: UIScreen.main.bounds.height * 0.45)
            HStack {
                Spacer()
                Text("Transform your pet portrait!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25))
                    .bold()
                    .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text("Unleash your imagination! Transform images of your pet into anything you can think of 🤠")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding([.leading, .trailing])
                Spacer()
            }
        }
    }
    
    var second: some View {
        VStack {
            Image(uiImage: UIImage(named: "intro002")!)
                .resizable()
                .frame(height: UIScreen.main.bounds.height * 0.45)
            HStack {
                Spacer()
                Text("Step 1: Scribble")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25))
                    .bold()
                    .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text("Upload your image, and scribble to indicate the section of your pet to keep. You can also use the auto-scribble button.\n\nThe rest of the image will be transformed by AI")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding([.leading, .trailing])
                Spacer()
            }
        }
    }
    
    var third: some View {
        VStack {
            Image(uiImage: UIImage(named: "intro003")!)
                .resizable()
                .scaledToFit()
                .frame(height: UIScreen.main.bounds.height * 0.45)
            HStack {
                Spacer()
                Text("Step 2: Input Prompt")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25))
                    .bold()
                    .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text("Unleash your imagination, and describe the desired image that you want!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding([.leading, .trailing])
                Spacer()
            }
        }
    }
    
    var fourth: some View {
        VStack {
            Image(uiImage: UIImage(named: "intro004")!)
                .resizable()
                .frame(height: UIScreen.main.bounds.height * 0.45)
            HStack {
                Spacer()
                Text("Step 3: See Result")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25))
                    .bold()
                    .padding()
                Spacer()
            }
            HStack {
                Spacer()
                Text("Look at your created masterpiece - don't forget to share with friends!")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16))
                    .padding([.leading, .trailing])
                Spacer()
            }
        }
    }
    
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
            .padding(.top, 40)

            TabView(selection: $currentPage) {
                self.first
                    .tag(0)
                self.second
                    .tag(1)
                self.third
                    .tag(2)
                self.fourth
                    .tag(3)
            }
            
            Button(action: {
                if currentPage < 3 {
                    currentPage += 1
                } else {
                    // if we've hit the last page, update UserDefaults
                    // the main PetFusionApp App listens for changes to didCompleteIntro,
                    // and will automatically display the MainTabView
                    UserDefaults.standard.setValue(true, forKey: "didCompleteIntro")
                }
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
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear(perform: {
            UIScrollView.appearance().isScrollEnabled = false
        })
    }
}

#Preview {
    UserIntroView()
}
