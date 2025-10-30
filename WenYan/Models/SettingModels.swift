//
//  SettingModels.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation

struct CodeblockSettings: Codable {
    var isEnabled = false
    var isMacStyle = false
    var theme = "github"
    var fontSize = FontSize.px12.rawValue
    var fontFamily = ""
}

struct ParagraphSettings: Codable {
    var isEnabled = false
    var fontSize = FontSize.px16.rawValue
    var fontType = FontType.sans.rawValue
    var fontWeight = FontWeight._400.rawValue
    var wordSpacing = WordSpacing.medium.rawValue
    var lineSpacing = LineSpacing.medium.rawValue
    var paragraphSpacing = ParagraphSpacing.medium.rawValue
}
