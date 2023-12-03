//
//  Binding+Comparators.swift
//  TestGenerativeImages
//
//  Created by Michael Zhu on 11/21/23.
//

import SwiftUI

// https://stackoverflow.com/questions/57021722/swiftui-optional-textfield
//
// Supports: TextField("", text: $test ?? "default value")
func ??<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

public extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy { source.wrappedValue = nil }
                else { source.wrappedValue = newValue }
            }
        )
    }
}
