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
                Image(systemName: appState.isCopied ? "checkmark" : "clipboard")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                Text("复制")
                    .font(.system(size: 14))
            }
            .frame(height: 24)
        }
    }
}
