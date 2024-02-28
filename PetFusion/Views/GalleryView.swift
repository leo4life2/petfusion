//
//  GalleryView.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import Foundation
import SwiftUI
import SwiftData

struct GalleryView: View {
    
    // Automatically-updated SwiftData query of all saved images
    @Query var images: [GenerativeImage]
    // The currently selected image that should be displayed in a modal pop-up view
    @State var selectedImage: GenerativeImage? = nil
    
    var columns : [GridItem] = [
        GridItem(.flexible(), spacing: -3),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if (images.count == 0) {
                    VStack {
                        Spacer()
                        HStack {
                            Text("Petfusion!")
                                .padding([.leading, .top])
                                .font(.system(size: 25))
                                .bold()
                                .foregroundColor(Color(hex: "#7E76FA"))
                        }
                        .padding()
                        HStack {
                            Text("Go to the Editor tab to get started! 😃")
                        }
                        HStack {
                            Text("Your generated images will appear here")
                        }
                        Spacer()
                    }
                }
                ScrollView {
                    HStack {
                        Text("Gallery")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    // Make a two-column vertical grid of images
                    LazyVGrid(columns: self.columns, spacing: 4, content: {
                        ForEach(self.images, id: \.self) { image in
                            // Make the entire image a button. When pressed, we will bring up a modal view
                            // that prominently displays the image
                            Button {
                                self.selectedImage = image
                            } label: {
                                Image(uiImage: image.toUIImage())
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width / 2 - 5)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .sheet(item: $selectedImage) { image in
                                // The modal view to be displayed that shows a single image
                                ResultView(image: image)
                            }
                            .contextMenu(menuItems: {
                                // Adds a context menu that can be brought up via long-pressing an image
                                // Currently, the options are to:
                                // 1) Share the image
                                ShareLink(
                                    item: Image(uiImage: image.toUIImage()),
                                    preview: SharePreview(
                                        image.prompt,
                                        image: Image(uiImage: image.toUIImage())
                                    ),
                                    label: {
                                        HStack {
                                            Text("Share")
                                            Spacer()
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundColor(Color.blue)
                                        }
                                        .padding()
                                        .frame(maxWidth: .greatestFiniteMagnitude)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                        .padding()
                                        .foregroundColor(Color.blue)
                                    })
                                // 2) Delete the image
                                Button {
                                    PetFusionApp.sharedModelContainer.mainContext.delete(image)
                                } label: {
                                    HStack {
                                        Text("Delete")
                                        Spacer()
                                        Image(systemName: "trash")
                                            .foregroundColor(Color.red)
                                    }
                                }
                            })
                        }
                    })
                }
            }
        }
    }
}

#Preview {
    let container = PetFusionApp.sharedModelContainer
//    container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg1")!.jpegData(compressionQuality: 0.75)!))
//    container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg2")!.jpegData(compressionQuality: 0.75)!))
//    container.mainContext.insert(GenerativeImage(id: UUID(), prompt: "foobar", imageData: UIImage(named: "testimg3")!.jpegData(compressionQuality: 0.75)!))
    return GalleryView()
}
