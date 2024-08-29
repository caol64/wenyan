const {markedHighlight} = globalThis.markedHighlight;
let postprocessMarkdown = "";
let isScrollingFromScript = false;
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
    MathJax.typeset();
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
        setStylesheet("hljs", highlight);
    }
}
function getContent() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    const elements = clonedWenyan.querySelectorAll("mjx-container");
    elements.forEach(element => {
        const math = element.getAttribute("math");
        const parent = element.parentElement;
        element.remove();
        parent.innerHTML = math;
    });
    return clonedWenyan.outerHTML;
}
function getContentWithMathImg() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    const elements = clonedWenyan.querySelectorAll("mjx-container");
    elements.forEach(element => {
        const math = element.getAttribute("math");
        const parent = element.parentElement;
        element.remove();
        let img = document.createElement("img");
        img.setAttribute("alt", math);
        img.setAttribute("data-eeimg", "true");
        img.setAttribute("style", "margin: 0 auto; width: auto; max-width: 100%;");
        parent.appendChild(img);
    });
    return clonedWenyan.outerHTML;
}
function getContentWithMathSvg() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    const elements = clonedWenyan.querySelectorAll("mjx-container");
    elements.forEach(element => {
        const svg = element.querySelector('svg');
        const parent = element.parentElement;
        element.remove();
        parent.appendChild(svg);
    });
    return clonedWenyan.outerHTML;
}
function getPostprocessMarkdown() {
    return postprocessMarkdown;
}
function scroll(scrollFactor) {
    isScrollingFromScript = true;
    window.scrollTo(0, document.body.scrollHeight * scrollFactor);
    requestAnimationFrame(() => isScrollingFromScript = false);
}
window.onscroll = function() {
    if (!isScrollingFromScript) {
        window.webkit.messageHandlers.scrollHandler.postMessage({ y0: window.scrollY / document.body.scrollHeight });
    }
};
function addFootnotes() {
    let footnotes = [];
    let footnoteIndex = 0;
    const links = document.querySelectorAll('a[href]'); // 获取所有带有 href 的 a 元素
    links.forEach((linkElement) => {
        const title = linkElement.textContent || linkElement.innerText;
        const href = linkElement.getAttribute('href');
        
        // 添加脚注并获取脚注编号
        footnotes.push([++footnoteIndex, title, href]);

        // 在链接后插入脚注标记
        const footnoteMarker = document.createElement('sup');
        footnoteMarker.innerHTML = `<a href="#footnote-${footnoteIndex}" style="text-decoration: none;">[${footnoteIndex}]</a>`;
        linkElement.after(footnoteMarker);
    });
    if (footnoteIndex > 0) {
        let footnoteArray = footnotes.map((x) => {
            if (x[1] === x[2]) {
                return `<li id="#footnote-${x[0]}">[${x[0]}]: <i><a href="${x[1]}">${x[1]}</a></i></li>`;
            }
            return `<li id="#footnote-${x[0]}">[${x[0]}] ${x[1]}: <i><a href="${x[2]}">${x[2]}</a></i></li>`;
        });
        const footnotesHtml = `<h3>引用链接</h3><div id="footnotes"><ul>${footnoteArray.join("")}</ul></div>`;
        document.getElementById("wenyan").innerHTML += footnotesHtml;
    }
}
window.webkit.messageHandlers.loadHandler.postMessage(null);
