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
const renderer = new marked.Renderer();

// 重写渲染标题的方法（h1 ~ h6）
renderer.heading = function(heading) {
    const text = heading.text;
    const level = heading.depth;
    // 返回带有 span 包裹的自定义标题
    return `<h${level}><span class="h${level}-span">${text}</span></h${level}>\n`;
};

// 配置 marked.js 使用自定义的 Renderer
marked.use({
    renderer: renderer
});
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
        svg.style.width = svg.getAttribute("width");
        svg.style.height = svg.getAttribute("height");
        const parent = element.parentElement;
        element.remove();
        parent.appendChild(svg);
    });
    return clonedWenyan.outerHTML;
}
function getContentForGzh() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    // 处理公式
    let elements = clonedWenyan.querySelectorAll("mjx-container");
    elements.forEach(element => {
        const svg = element.querySelector('svg');
        svg.style.width = svg.getAttribute("width");
        svg.style.height = svg.getAttribute("height");
        svg.removeAttribute("width");
        svg.removeAttribute("height");
        const parent = element.parentElement;
        element.remove();
        parent.appendChild(svg);
    });
    // 读取主题css样式
    const stylesheets = document.styleSheets;
    let stylesMap = new Map();
    Array.from(stylesheets).forEach(sheet => {
        Array.from(sheet.cssRules).forEach(rule => {
            if (rule instanceof CSSStyleRule) {
                if (rule.selectorText.startsWith("#wenyan")) {
                    let styleObject = new Map();
                    for (let i = 0; i < rule.style.length; i++) {
                        const property = rule.style[i];
                        styleObject.set(property, rule.style.getPropertyValue(property));
                    }
                    stylesMap.set(rule.selectorText, styleObject);
                }
            }
        });
    });
    // 公众号不支持css伪元素，将伪元素样式提取出来拼接成一个span
    elements = clonedWenyan.querySelectorAll('h1, h2, h3, h4, h5, h6, blockquote');
    elements.forEach(element => {
        stylesMap.forEach((value, key) => {
            if (key.includes(element.tagName.toLowerCase() + "::after") ||
                key.includes(element.tagName.toLowerCase() + "::before")) {
                const styles = value;
                if (styles.size > 0) {
                    // 创建一个新的 <span> 元素
                    const span = document.createElement('span');
                    // 将伪类的内容和样式应用到 <span> 标签
                    span.textContent = styles.get("content").replace(/['"]/g, '');
                    const entries = Array.from(styles.entries());
                    const cssString = entries.map(([key, value]) => `${key}: ${value}`).join('; ');
                    span.style.cssText = cssString;
                    if (key.includes("::after")) {
                        element.appendChild(span);
                    } else {
                        element.insertBefore(span, element.firstChild);
                    }
                }
            }
        });
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
function addFootnotes(listStyle) {
    let footnotes = [];
    let footnoteIndex = 0;
    const links = document.querySelectorAll('a[href]'); // 获取所有带有 href 的 a 元素
    links.forEach((linkElement) => {
        const title = linkElement.textContent || linkElement.innerText;
        const href = linkElement.getAttribute("href");

        // 添加脚注并获取脚注编号
        footnotes.push([++footnoteIndex, title, href]);

        // 在链接后插入脚注标记
        const footnoteMarker = document.createElement('sup');
        footnoteMarker.setAttribute("class", "footnote");
        footnoteMarker.innerHTML = `[${footnoteIndex}]`;
        linkElement.after(footnoteMarker);
    });
    if (footnoteIndex > 0) {
        if (!listStyle) {
            let footnoteArray = footnotes.map((x) => {
                if (x[1] === x[2]) {
                    return `<p id="#footnote-${x[0]}">[${x[0]}]: <i>${x[1]}</i></p>`;
                }
                return `<p id="#footnote-${x[0]}">[${x[0]}]<span>${x[1]}: <i>${x[2]}</i></span></p>`;
            });
            const footnotesHtml = `<h3>引用链接</h3><div id="footnotes">${footnoteArray.join("")}</div>`;
            document.getElementById("wenyan").innerHTML += footnotesHtml;
        } else {
            let footnoteArray = footnotes.map((x) => {
                if (x[1] === x[2]) {
                    return `<li id="#footnote-${x[0]}">[${x[0]}]: <i>${x[1]}</i></li>`;
                }
                return `<li id="#footnote-${x[0]}">[${x[0]}] ${x[1]}: <i>${x[2]}</i></li>`;
            });
            const footnotesHtml = `<h3>引用链接</h3><div id="footnotes"><ul>${footnoteArray.join("")}</ul></div>`;
            document.getElementById("wenyan").innerHTML += footnotesHtml;
        }
    }
}
document.addEventListener('click', function(event) {
    window.webkit.messageHandlers.clickHandler.postMessage(null);
});
window.webkit.messageHandlers.loadHandler.postMessage(null);
