//
//  MainViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/18.
//

import WebKit

@MainActor
final class MainViewModel: NSObject, ObservableObject {
    
    private let appState: AppState
    weak var webView: WKWebView?
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - Call Javascript
    private func callJavascript(callbackId: String, data: Any? = nil, error: String? = nil) {
        let dataJsonString = serializeToJSONString(data)
        let errorJsonString = serializeToJSONString(error)
        let jsScript = "if(window.__WENYAN_BRIDGE__.invokeCallback) { window.__WENYAN_BRIDGE__.invokeCallback('\(callbackId)', \(dataJsonString), \(errorJsonString)); }"
        WenYan.callJavascript(webView: webView, javascriptString: jsScript)
    }
}

// MARK: - ScriptMessageHandler
extension MainViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "wenyanBridge",
              let body = message.body as? [String: Any],
              let action = body["action"] as? String,
              let callbackId = body["callbackId"] as? String else {
            return
        }
        
        let payload = body["payload"]
        switch action {
        case "loadArticles":
            handleLoadArticles(callbackId: callbackId)
        case "saveArticle":
            handleSaveArticle(payload: payload as? String)
        case "loadArticle":
            handleLoadArticle(callbackId: callbackId)
        case "loadThemes":
            handleLoadThemes(callbackId: callbackId)
        case "saveTheme":
            handleSaveTheme(callbackId: callbackId, payload: payload as? JsCustomTheme)
        case "removeTheme":
            handleRemoveTheme(payload: payload as? String)
        default:
            break
        }
    }
    
    func loadArticle() -> String? {
        return UserDefaults.standard.string(forKey: "lastArticle")
    }
    
    func handleLoadArticles(callbackId: String) {
        let article = loadArticle()
        callJavascript(callbackId: callbackId, data: article)
    }
    
    func handleSaveArticle(payload: String?) {
        Task.detached(priority: .background) {
            UserDefaults.standard.set(payload, forKey: "lastArticle")
        }
    }
    
    func handleLoadArticle(callbackId: String) {
        if let article = loadArticle() {
            callJavascript(callbackId: callbackId, data: article)
        } else {
            do {
                let content = try loadFileFromResource(forResource: "example", withExtension: "md")
                callJavascript(callbackId: callbackId, data: content)
            } catch {
                callJavascript(callbackId: callbackId, error: error.localizedDescription)
            }
        }
    }
    
    func loadDefaultArticle() {
        do {
            let content = try loadFileFromResource(forResource: "example", withExtension: "md")
            let jsScript = "if(window.__WENYAN_BRIDGE__.setContent) { window.__WENYAN_BRIDGE__.setContent(\(content.toJavaScriptString())); }"
            WenYan.callJavascript(webView: webView, javascriptString: jsScript)
        } catch {
            error.handle(in: appState)
        }
    }
    
    func handleLoadThemes(callbackId: String) {
        do {
            let themes = try fetchCustomThemes().map { $0.toDictionary() }
            callJavascript(callbackId: callbackId, data: themes)
        } catch {
            error.handle(in: appState)
        }
    }
    
    func handleSaveTheme(callbackId: String, payload: JsCustomTheme?) {
        do {
            if let themeToSave = payload {
                if let theme = try getCustomThemeById(id: themeToSave.id) {
                    try updateCustomTheme(customTheme: theme, content: themeToSave.css)
                    callJavascript(callbackId: callbackId, data: themeToSave.id)
                } else {
                    let result = try saveCustomTheme(name: themeToSave.name, content: themeToSave.css)
                    callJavascript(callbackId: callbackId, data: result.objectID.uriRepresentation().absoluteString)
                }
            }
        } catch {
            error.handle(in: appState)
        }
    }
    
    func handleRemoveTheme(payload: String?) {
        do {
            if let idToDelete = payload {
                if let theme = try getCustomThemeById(id: idToDelete) {
                    try deleteCustomTheme(theme)
                }
            }
        } catch {
            error.handle(in: appState)
        }
    }
}

// MARK: - UIDelegate
extension MainViewModel: WKUIDelegate {
    // 为方便调试，让SwiftUI模拟JS的alert方法
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = "JavaScript Alert"
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
        completionHandler()
    }
}

func fetchCustomThemes() throws -> [CustomTheme] {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<CustomTheme> = CustomTheme.fetchRequest()
    return try context.fetch(fetchRequest)
}

func getCustomThemeById(id: String) throws -> CustomTheme? {
    return try fetchCustomThemes().filter { item in
        item.objectID.uriRepresentation().absoluteString == id
    }.first
}

func saveCustomTheme(name: String, content: String) throws -> CustomTheme {
    let context = CoreDataStack.shared.persistentContainer.viewContext
    let customTheme = CustomTheme(context: context)
    customTheme.name = name
    customTheme.content = content
    customTheme.createdAt = Date()
    try CoreDataStack.shared.save()
    return customTheme
}

func updateCustomTheme(customTheme: CustomTheme, content: String) throws {
    customTheme.content = content
    try CoreDataStack.shared.save()
}

func deleteCustomTheme(_ customTheme: CustomTheme) throws {
    try CoreDataStack.shared.delete(item: customTheme)
}
