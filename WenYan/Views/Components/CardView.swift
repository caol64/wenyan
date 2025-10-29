//
//  CardView.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(10)
            .shadow(radius: 3)
    }
}
