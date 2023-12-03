//
//  LibraryView.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/20/23.
//

import SwiftUI
import SwiftData

struct LibraryImageView: View {
    var savedImage: LibraryImage

    var body: some View {
        if let uiImage = UIImage(data: savedImage.generativeImage) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct LibraryView: View {
    var columns : [GridItem] = [
        GridItem(.flexible(), spacing: -3),
        GridItem(.flexible())
    ]
    @Environment(\.modelContext) private var context
    @Query var libraryImages: [LibraryImage]
    @State var selectedLibraryImage: LibraryImage? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(uiColor: UIColor.systemGroupedBackground).ignoresSafeArea()
                ScrollView {
                    HStack {
                        Text("Library")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    LazyVGrid(columns: columns, spacing: 4, content: {
                        ForEach(libraryImages, id: \.self) { image in
                            Button {
                                selectedLibraryImage = image
                            } label: {
                                LibraryImageView(savedImage: image)
                                    .frame(width: geometry.size.width / 2 - 5)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .sheet(item: $selectedLibraryImage) { image in
                                DrawingPreviewContentView(image: image.generativeUIImage(), positivePrompt: image.positivePrompt, negativePrompt: image.negativePrompt, libraryImageUUID: image.id)
                            }
                        }
                    })
                }
            }
        }.onAppear {
            self.insertDefaultData(context: self.context)
        }
    }

    public func insertDefaultData(context: ModelContext) {
        if self.libraryImages.count == 0 {
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img1")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img2")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img3")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img4")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img5")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img6")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img7")!.pngData()!, id: UUID()))
            context.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img8")!.pngData()!, id: UUID()))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LibraryImage.self, configurations: config)
    container.mainContext.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img1")!.pngData()!, id: UUID()))
    container.mainContext.insert(LibraryImage(positivePrompt: "positive asdf", negativePrompt: "negative asdf", generativeImage: UIImage(named: "img2")!.pngData()!, id: UUID()))
    return LibraryView()
        .modelContainer(container)
}
