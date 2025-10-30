//
//  MarkdownViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Combine
import WebKit

@MainActor
final class MarkdownViewModel: NSObject, ObservableObject {
    private let appState: AppState
    @Published var content: String = ""
    @Published var scrollFactor: CGFloat = 0
    weak var webView: WKWebView?
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    // MARK: - Combine Subscriber
    func bindTo(_ htmlViewModel: HtmlViewModel) {
        htmlViewModel.$scrollFactor
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.scroll(scrollFactor: newContent)
            }
            .store(in: &cancellables)
    }

    // MARK: - Article Loading
    func loadArticle() {
        if let lastArticle = UserDefaults.standard.string(forKey: "lastArticle") {
            content = lastArticle
        } else {
            loadDefaultArticle()
        }
    }
    
    func loadDefaultArticle() {
        do {
            content = try loadFileFromResource(forResource: "example", withExtension: "md")
        } catch {
            error.handle(in: appState)
        }
    }
    
    func openArticle(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let files):
            let file = files[0]
            let gotAccess = file.startAccessingSecurityScopedResource()
            if !gotAccess { return }
            let fileExtension = file.pathExtension.lowercased()
            if fileExtension == "md" || fileExtension == "markdown" {
                do {
                    content = try String(contentsOfFile: file.path, encoding: .utf8)
                } catch {
                    error.handle(in: appState)
                }
            }
            file.stopAccessingSecurityScopedResource()
        case .failure(let error):
            error.handle(in: appState)
        }
    }
    
    func setContent(_ content: String) {
        self.content = content
        Task.detached(priority: .background) {
            UserDefaults.standard.set(content, forKey: "lastArticle")
        }
    }

    // MARK: - WebView Interaction
    func loadInitialHTML(in webView: WKWebView) {
        do {
            let html = try loadFileFromResource(forResource: "editor", withExtension: "html")
            webView.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            error.handle(in: appState)
        }
    }

    func setContentToWebView() {
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }

    func scroll(scrollFactor: CGFloat) {
        callJavascript(javascriptString: "scroll(\(scrollFactor));")
    }

    func onFileUploadComplete(_ url: String) {
        callJavascript(javascriptString: "onFileUploadComplete(\(url.toJavaScriptString()));")
    }

    func onFileUploadFailed() {
        callJavascript(javascriptString: "onFileUploadComplete();")
    }
    
    // MARK: - Call Javascript
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }
}

// MARK: - ScriptMessageHandler
extension MarkdownViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        // 处理来自 JavaScript 的消息
        case WebkitStatus.loadHandler:  // codemirror初始化完毕
            setContentToWebView()
        case WebkitStatus.contentChangeHandler:  // codemirror内容变化
            let content = (message.body as? String) ?? ""
            setContent(content)
        case WebkitStatus.scrollHandler:
            guard let body = message.body as? [String: CGFloat], let y = body["y0"] else { return }
            scrollFactor = y
        case WebkitStatus.errorHandler:
            let content = (message.body as? String) ?? ""
            appState.appError = AppError.bizError(description: content)
        case WebkitStatus.uploadHandler:
            guard let body = message.body as? [String: Any],
                let name = body["name"] as? String,
                let type = body["type"] as? String,
                let dataArray = body["data"] as? [UInt8]
            else {
                appState.appError = AppError.bizError(description: "未找到需上传的文件")
                onFileUploadFailed()
                return
            }
            let fileData = Data(dataArray)
            Task {
                do {
                    let url = try await uploadImage(fileData, name: name, type: type)
                    onFileUploadComplete(url)
                } catch {
                    error.handle(in: appState)
                    onFileUploadFailed()
                }
            }
        default:
            break
        }
    }
}

// MARK: - UIDelegate
extension MarkdownViewModel: WKUIDelegate {
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
