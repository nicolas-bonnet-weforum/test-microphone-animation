//
//  StylePickerView.swift
//  test microphone animation
//
//  Created by Nicolas Bonnet on 11.10.2025.
//

import SwiftUI

struct StylePickerView: View {
    @Binding var selectedStyle: AnimationStyle
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(AnimationStyle.allCases, id: \.self) { style in
                Button(action: {
                    selectedStyle = style
                    dismiss()
                }) {
                    HStack {
                        Text(style.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedStyle == style {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle("Animation Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
