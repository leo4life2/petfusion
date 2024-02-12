//
//  KeyboardResponsiveModifier.swift
//  PetFusion
//
//  Created by Michael Zhu on 2/11/24.
//

import SwiftUI
import Combine

struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .animation(.easeOut(duration: 0.3), value: offset) // Apply animation here
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                    let bottomSafeAreaInset = UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 0
                    let keyboardHeight = keyboardSize?.height ?? 0
                    withAnimation {
                        offset = keyboardHeight - bottomSafeAreaInset
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation {
                        offset = 0
                    }
                }
            }
    }
}
