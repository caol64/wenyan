const {markedHighlight} = globalThis.markedHighlight;
let postprocessMarkdown = "";
function preprocess(markdown) {
    const { attributes, body } = window.frontMatter(markdown);
    let head = "";
    if (attributes['title']) {
        head = "# " + attributes['title'] + "\n\n";
    }
    if (attributes['description']) {
        head += "> " + attributes['description'] + "\n\n";
    }
    postprocessMarkdown = head + body;
    return postprocessMarkdown;
}
marked.use({ hooks: { preprocess } });
marked.use(markedHighlight({
    langPrefix: "hljs language-",
    highlight: function(code, language) {
        language = hljs.getLanguage(language) ? language : "plaintext";
        return hljs.highlight(code, { language: language }).value;
    }
}));
function setStylesheet(id, href) {
    const style = document.createElement("link");
    style.setAttribute("id", id);
    style.setAttribute("rel", "stylesheet");
    style.setAttribute("href", href);
    document.head.appendChild(style);
}
function setContent(content) {
    document.getElementById("wenyan")?.remove();
    const container = document.createElement("section");
    container.innerHTML = marked.parse(content);
    container.setAttribute("id", "wenyan");
    container.setAttribute("class", "preview");
    document.body.appendChild(container);
}
function setPreviewMode(mode) {
    document.getElementById("style")?.remove();
    setStylesheet("style", mode)
}
function setTheme(theme) {
    document.getElementById("theme")?.remove();
    setStylesheet("theme", theme)
}
function setHighlight(highlight) {
    document.getElementById("hljs")?.remove();
    if (highlight) {
        setStylesheet("hljs", highlight)
    }
}
function getContent() {
//    const wenyan = document.getElementById("wenyan");
//    const clonedWenyan = wenyan.cloneNode(true);
//    const elements = clonedWenyan.querySelectorAll("#wenyan pre");
//    elements.forEach(element => {
//        const span = document.createElement("span");
//        span.setAttribute("style", macCodeStyle);
//        element.insertBefore(span, element.firstChild);
//    });
//    return clonedWenyan.outerHTML;
    return document.getElementById("wenyan")?.outerHTML;
}
function getPostprocessMarkdown() {
    return postprocessMarkdown;
}
window.webkit.messageHandlers.isReady.postMessage(null);
