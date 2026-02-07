//
//  HtmlViewModel.swift
//  WenYan
//
//  Created by Lei Cao on 2025/10/23.
//

import Combine
import PDFKit
import SwiftUI
import WebKit

@MainActor
final class HtmlViewModel: NSObject, ObservableObject {
    private let appState: AppState
    @Published var content: String = ""
    @Published var scrollFactor: CGFloat = 0
    @Published var isFootnotes = false
    @Published var exportImgData: DataFile?
    @Published var exportPdfData: DataFile?

    weak var webView: WKWebView?
    weak var markdownViewModel: MarkdownViewModel?
    private var cancellables = Set<AnyCancellable>()
    private var isWebViewReady = false

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Combine Subscriber
    func bind() {
        appState.$gzhTheme
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.setTheme()
            }
            .store(in: &cancellables)

        appState.$platform
            .receive(on: RunLoop.main)
            .sink { [weak self] platform in
                self?.setTheme()
            }
            .store(in: &cancellables)
    }

    func bindTo(_ markdownViewModel: MarkdownViewModel) {
        self.markdownViewModel = markdownViewModel
        markdownViewModel.$content
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.setContent(newContent)
            }
            .store(in: &cancellables)

        markdownViewModel.$scrollFactor
            .receive(on: RunLoop.main)
            .sink { [weak self] newContent in
                self?.scroll(scrollFactor: newContent)
            }
            .store(in: &cancellables)
    }

    // MARK: - WebView Interaction
    func loadInitialHTML(in webView: WKWebView) {
        do {
            let html = try loadFileFromResource(forResource: "preview", withExtension: "html")
            webView.loadHTMLString(html, baseURL: getResourceBundle())
        } catch {
            error.handle(in: appState)
        }
    }

    func setContentToWebView() {
        guard webView != nil, isWebViewReady else { return }
        callJavascript(javascriptString: "setContent(\(content.toJavaScriptString()));")
    }

    func getContentFromWebView() async throws -> String {
        try await callAsyncJavaScript(javascriptBody: "return getContent();")
    }

    func getPostprocessMarkdown() async throws -> String {
        try await callAsyncJavaScript(javascriptBody: "return getPostprocessMarkdown();")
    }

    func getContentWithMathImg() async throws -> String {
        try await callAsyncJavaScript(javascriptBody: "return getContentWithMathImg();")
    }

    func getContentForGzh() async throws -> String {
        try await callAsyncJavaScript(javascriptBody: "return await getContentForGzh();")
    }

    func getContentForMedium() async throws -> String {
        try await callAsyncJavaScript(javascriptBody: "return getContentForMedium();")
    }

    func getScrollFrame(_ block: JavascriptCallback?) {
        callJavascript(javascriptString: "getScrollFrame();", callback: block)
    }

    func scroll(scrollFactor: CGFloat) {
        callJavascript(javascriptString: "scroll(\(scrollFactor));")
    }

    func applySettings() {
        callJavascript(javascriptString: "applySettings(\(appState.platform == .gzh));")
    }

    // MARK: - Content Management
    func setContent(_ content: String) {
        let processedContent = processImagePaths(in: content)
        self.content = processedContent
        flushContent()
    }
    
    private func processImagePaths(in markdown: String) -> String {
        guard let currentURL = markdownViewModel?.currentFileURL else { return markdown }
        
        let pattern = #"!\[(.*?)\]\((.*?)\)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return markdown }
        
        let range = NSRange(markdown.startIndex..., in: markdown)
        let matches = regex.matches(in: markdown, options: [], range: range)
        
        var result = markdown
        
        for match in matches.reversed() {
            guard let altTextRange = Range(match.range(at: 1), in: markdown),
                  let urlRange = Range(match.range(at: 2), in: markdown) else { continue }
            
            let imagePath = String(markdown[urlRange])
            
            if imagePath.hasPrefix("http://") || imagePath.hasPrefix("https://") || imagePath.hasPrefix("data:") {
                continue
            }
            
            let dataURL = convertImageToDataURL(imagePath, relativeTo: currentURL)
            
            if dataURL != nil {
                let altText = String(markdown[altTextRange])
                let replacement = "![\(altText)](\(dataURL!))"
                let matchRange = Range(match.range, in: markdown)!
                result.replaceSubrange(matchRange, with: replacement)
            }
        }
        
        return result
    }
    
    private func convertImageToDataURL(_ relativePath: String, relativeTo baseURL: URL) -> String? {
        let baseURLDirectory = baseURL.deletingLastPathComponent()
        
        var resolvedURL: URL
        
        if relativePath.hasPrefix("/") {
            resolvedURL = URL(fileURLWithPath: relativePath)
        } else if relativePath.hasPrefix("../") {
            resolvedURL = baseURLDirectory.appendingPathComponent(relativePath)
        } else if relativePath.hasPrefix("./") {
            let cleanPath = String(relativePath.dropFirst(2))
            resolvedURL = baseURLDirectory.appendingPathComponent(cleanPath)
        } else {
            resolvedURL = baseURLDirectory.appendingPathComponent(relativePath)
        }
        
        resolvedURL = resolvedURL.standardized
        
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: resolvedURL.path, isDirectory: &isDirectory) else { return nil }
        guard !isDirectory.boolValue else { return nil }
        
        let gotAccess = resolvedURL.startAccessingSecurityScopedResource()
        defer {
            if gotAccess {
                resolvedURL.stopAccessingSecurityScopedResource()
            }
        }
        
        guard let imageData = try? Data(contentsOf: resolvedURL) else { return nil }
        
        let mimeType = mimeTypeForPath(resolvedURL.path)
        let base64String = imageData.base64EncodedString()
        return "data:\(mimeType);base64,\(base64String)"
    }
    
    private func mimeTypeForPath(_ path: String) -> String {
        let ext = (path as NSString).pathExtension.lowercased()
        switch ext {
        case "png": return "image/png"
        case "jpg", "jpeg": return "image/jpeg"
        case "gif": return "image/gif"
        case "webp": return "image/webp"
        case "svg": return "image/svg+xml"
        case "bmp": return "image/bmp"
        case "ico": return "image/x-icon"
        default: return "image/png"
        }
    }

    func flushContent() {
        setContentToWebView()
        if isFootnotes {
            addFootnotes()
        }
    }

    func configWebView() {
        setCodeblockSettings()
        setParagraphSettings()
        setTheme()
        setContentToWebView()
    }

    func setTheme() {
        if appState.platform == .gzh {
            if appState.gzhTheme.themeType == .custom,
                let customTheme = appState.getCurrentCustomTheme(),
                let themeContent = customTheme.content
            {
                callJavascript(javascriptString: "setCustomTheme(\(themeContent.toJavaScriptString()), true);")
            } else {
                callJavascript(javascriptString: "setThemeById(\(appState.gzhTheme.id().toJavaScriptString()), true);")
            }
        } else {
            callJavascript(javascriptString: "setThemeById(\(appState.platform.themes[0].id.toJavaScriptString()), false);")
        }
    }

    func changeFootnotes() {
        isFootnotes.toggle()
        flushContent()
    }

    func addFootnotes() {
        if appState.platform == .gzh {
            callJavascript(javascriptString: "addFootnotes(false);")
        } else {
            callJavascript(javascriptString: "addFootnotes(true);")
        }
    }

    func setCodeblockSettings() {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(CodeblockSettingsViewModel.loadSettings() ?? CodeblockSettings())
            let jsonString = String(data: jsonData, encoding: .utf8)
            let jsString = jsonString ?? ""
            callJavascript(javascriptString: "setCodeblockSettings(JSON.parse(\(jsString.toJavaScriptString())));")
        } catch {
            error.handle(in: appState)
        }
    }

    func setParagraphSettings() {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(ParagraphSettingsViewModel.loadSettings() ?? ParagraphSettings())
            let jsonString = String(data: jsonData, encoding: .utf8)
            let jsString = jsonString ?? ""
            callJavascript(javascriptString: "setParagraphSettings(JSON.parse(\(jsString.toJavaScriptString())));")
        } catch {
            error.handle(in: appState)
        }
    }

    // MARK: - Call Javascript
    private func callJavascript(javascriptString: String, callback: JavascriptCallback? = nil) {
        WenYan.callJavascript(webView: webView, javascriptString: javascriptString, callback: callback)
    }

    private func callAsyncJavaScript(javascriptBody: String, args: [String: Any] = [:]) async throws -> String {
        try await WenYan.callAsyncJavaScript(webView: webView, javascriptBody: javascriptBody, args: args) as? String ?? ""
    }
}

// MARK: - ScriptMessageHandler
extension HtmlViewModel: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        // 处理来自 JavaScript 的消息
        case WebkitStatus.loadHandler:  // wenyan-core.js 初始化完毕
            isWebViewReady = true
            if let body = message.body as? [String: Any] {
                if let gzhThemes = body["gzhThemes"] as? [[String: String]] {
                    PlatformConfig.setThemes(body: gzhThemes)
                }

                if let hlThemes = body["hlThemes"] as? [[String: String]] {
                    HlThemeConfig.setThemes(body: hlThemes)
                }
            }
            appState.initial()
            configWebView()
        case WebkitStatus.scrollHandler:
            guard let body = message.body as? [String: CGFloat], let y = body["y0"] else { return }
            scrollFactor = y
        default:
            break
        }
    }
}

// MARK: - UIDelegate
extension HtmlViewModel: WKUIDelegate {
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

// MARK: - Exporter
extension HtmlViewModel {
    var isPdfExporting: Binding<Bool> {
        Binding(
            get: { self.exportPdfData != nil },
            set: { if !$0 { self.exportPdfData = nil } }
        )
    }

    var isImgExporting: Binding<Bool> {
        Binding(
            get: { self.exportImgData != nil },
            set: { if !$0 { self.exportImgData = nil } }
        )
    }

    func exportContent(as type: ExportType) {
        guard let webView = self.webView else { return }

        getScrollFrame { result in
            do {
                guard let body = try result.get() as? [String: CGFloat],
                    let height = body["height"]
                else { return }

                let originalFrame = webView.frame
                let newFrame = NSRect(x: 0, y: 0, width: originalFrame.width, height: height)
                webView.frame = newFrame

                webView.exportPDF { pdfData, error in
                    guard let pdfData = pdfData else { return }

                    switch type {
                    case .pdf:
                        self.exportPdfData = DataFile(data: pdfData)

                    case .longImage:
                        if let pdf = PDFDocument(data: pdfData),
                            let page = pdf.page(at: 0)
                        {
                            let pageSize = page.bounds(for: .mediaBox)
                            let image = page.thumbnail(
                                of: CGSize(
                                    width: 1024,
                                    height: 1024 * pageSize.height / pageSize.width
                                ),
                                for: .mediaBox
                            )

                            if let tiffData = image.tiffRepresentation,
                                let bitmapRep = NSBitmapImageRep(data: tiffData),
                                let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.9])
                            {
                                self.exportImgData = DataFile(data: jpegData)
                            }
                        }
                    }
                }

                webView.frame = originalFrame
            } catch {
                error.handle(in: self.appState)
            }
        }
    }

    func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            print("File saved to \(url)")
        case .failure(let error):
            error.handle(in: appState)
        }
    }
}

// MARK: - Copy to Pasteboard
extension HtmlViewModel {
    func onCopy() {
        Task { @MainActor in
            do {
                let content: String

                switch appState.platform {
                case .gzh:
                    content = try await getContentForGzh()
                case .zhihu:
                    content = try await getContentWithMathImg()
                case .juejin:
                    content = try await getPostprocessMarkdown()
                case .medium:
                    content = try await getContentForMedium()
                default:
                    content = try await getContentFromWebView()
                }

                let pasteBoard = NSPasteboard.general
                pasteBoard.clearContents()

                if appState.platform == .juejin {
                    pasteBoard.setString(content, forType: .string)
                } else {
                    pasteBoard.setString(content, forType: .html)
                }

                appState.toggleCopyIcon()

            } catch {
                error.handle(in: self.appState)
            }
        }
    }
}
