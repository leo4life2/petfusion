//
//  KeyboardResponder.swift
//  PetFusion
//
//  Created by Michael Zhu on 2/11/24.
//

import Foundation
import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var isKeyboardVisible: Bool = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { _ in self.isKeyboardVisible = true }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in self.isKeyboardVisible = false }
            .store(in: &cancellables)
    }
}
