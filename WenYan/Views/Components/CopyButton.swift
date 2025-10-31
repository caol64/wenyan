//
//  CopyButton.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/30.
//

import SwiftUI

struct CopyButton: View {
    @EnvironmentObject private var htmlViewModel: HtmlViewModel
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Button(action: {
            htmlViewModel.onCopy()
        }) {
            HStack {
                VStack {
                    Image(systemName: appState.isCopied ? "checkmark" : "clipboard")
                        .imageScale(.medium)
                }
                .frame(width: 24)
                Text("复制")
                    .font(.body)
            }
            .frame(height: 24)
        }
    }
}
