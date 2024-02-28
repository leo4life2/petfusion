//
//  MainTabView.swift
//  PetFusion
//
//  Created by fdsa on 1/27/24.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    
    // Index of the tab currently active
    @State private var currentTabSelection = 1
    // Bool indicating whether the editor modal should be displayed
    @State private var presentEditorView = false
    
    var body: some View {
        TabView(selection: $currentTabSelection,
                content:  {
            GalleryView()
                .tabItem { Label("Library", systemImage: "photo.on.rectangle") }
                .tag(1)
                
            Text("")
                .tabItem {
                    Button(action: {
                        presentEditorView = true
                    }, label: {
                        Label("Editor", systemImage: "plus.square")
                    })
                }
                .tag(2)
        
            InfoView()
                .tabItem { Label("Info", systemImage: "info.square") }
                .tag(3)
        })
        .onChange(of: currentTabSelection) { oldValue, newValue in
            if (newValue == 2) {
                // present the editor modal view view, then immediately switch back to
                // the previous tab selection under the hood - this allows the user's
                // selection to not be stuck on the editor tab once they leave the modal view
                self.presentEditorView = true
                self.currentTabSelection = oldValue
            }
        }
        .sheet(isPresented: $presentEditorView, content: {
            EditorView(editorViewModel: EditorViewModel.shared)
        })
    }
}

#Preview {
    MainTabView()
}
