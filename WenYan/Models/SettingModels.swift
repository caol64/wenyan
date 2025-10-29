//
//  SettingModels.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Foundation

struct CodeblockSettings: Codable {
    var isEnabled: Bool = false
    var isMacStyle: Bool = false
    var theme: String = "github"
    var fontSize: String = FontSize.px12.rawValue
    var fontFamily: String = ""
}

struct ParagraphSettings: Codable {
    var isEnabled: Bool = false
    var fontSize: String = FontSize.px16.rawValue
    var fontType: String = FontType.sans.rawValue
    var fontWeight: String = FontWeight._400.rawValue
    var wordSpacing: String = WordSpacing.medium.rawValue
    var lineSpacing: String = LineSpacing.medium.rawValue
    var paragraphSpacing: String = ParagraphSpacing.medium.rawValue
}
