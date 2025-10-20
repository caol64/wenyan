/*
 * Copyright 2024 Lei Cao
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

const serif = "ui-serif, Georgia, Cambria, 'Noto Serif', 'Times New Roman', serif";
const sansSerif = "ui-sans-serif, system-ui, 'Apple Color Emoji', 'Segoe UI', 'Segoe UI Symbol', 'Noto Sans', 'Roboto', sans-serif";
const monospace = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, 'Liberation Mono', 'Roboto Mono', 'Courier New', 'Microsoft YaHei', monospace";

let postprocessMarkdown = "";
let isScrollingFromScript = false;
let customCss = "";
let highlightCss = "";
let codeblockSettings;
let paragraphSettings;

function getScrollFrame() {
    const height = document.body.scrollHeight;
    const width = document.getElementById("wenyan").offsetWidth;
    const fullWidth = document.body.scrollWidth;
    return { width, height, fullWidth }
}

function setStylesheet(id, href) {
    const style = document.createElement("link");
    style.setAttribute("id", id);
    style.setAttribute("rel", "stylesheet");
    style.setAttribute("href", href);
    document.head.appendChild(style);
}

async function setContent(content) {
    document.getElementById("wenyan")?.remove();
    const container = document.createElement("section");
    const preHandlerContent = WenyanCore.handleFrontMatter(content);
    let body = preHandlerContent.body;
    if (preHandlerContent.title) {
        body = `# ${preHandlerContent.title}\n\n${body}`;
    }
    container.innerHTML = await WenyanCore.renderMarkdown(body);
    container.setAttribute("id", "wenyan");
    container.setAttribute("class", "preview");
    document.body.appendChild(container);
}

function setPreviewMode(mode) {
    document.getElementById("style")?.remove();
    setStylesheet("style", mode);
}

function setCustomTheme(css) {
    document.getElementById("theme")?.remove();
    const style = document.createElement("style");
    style.setAttribute("id", "theme");
    customCss = WenyanCore.replaceCSSVariables(css);
    customCss = WenyanCore.modifyCss(customCss, {
        '#wenyan pre code': [
            {
                property: 'font-family',
                value: codeblockSettings.fontFamily,
                append: true
            }
        ],
        '#wenyan pre': [
            {
                property: 'font-size',
                value: codeblockSettings.fontSize,
                append: true
            }
        ]
    });
    if (paragraphSettings && paragraphSettings.isEnabled) {
        let classes = [];
        let fontFamilyClass = {};
        if (paragraphSettings.fontSize) {
            classes.push({property: 'font-size', value: paragraphSettings.fontSize, append: true});
        }
        if (paragraphSettings.fontType) {
            if (paragraphSettings.fontType === 'serif') {
                fontFamilyClass = {property: 'font-family', value: serif, append: true};
                classes.push(fontFamilyClass);
            } else if (paragraphSettings.fontType === 'sans') {
                fontFamilyClass = {property: 'font-family', value: sansSerif, append: true};
                classes.push(fontFamilyClass);
            } else if (paragraphSettings.fontType === 'mono') {
                fontFamilyClass = {property: 'font-family', value: monospace, append: true};
                classes.push(fontFamilyClass);
            }
        }
        if (paragraphSettings.fontWeight) {
            classes.push({property: 'font-weight', value: paragraphSettings.fontWeight, append: true});
        }
        if (paragraphSettings.wordSpacing) {
            classes.push({property: 'letter-spacing', value: paragraphSettings.wordSpacing, append: true});
        }
        if (paragraphSettings.lineSpacing) {
            classes.push({property: 'line-height', value: paragraphSettings.lineSpacing, append: true});
        }
        if (paragraphSettings.paragraphSpacing) {
            classes.push({property: 'margin', value: `${paragraphSettings.paragraphSpacing} 0`, append: true});
        }
        customCss = WenyanCore.modifyCss(customCss, {
            '#wenyan p': classes,
            '#wenyan ul': classes,
            '#wenyan h1': [fontFamilyClass],
            '#wenyan h2': [fontFamilyClass],
            '#wenyan h3': [fontFamilyClass],
            '#wenyan h4': [fontFamilyClass],
            '#wenyan h5': [fontFamilyClass],
            '#wenyan h6': [fontFamilyClass]
        });
    }
    style.textContent = customCss;
    document.head.appendChild(style);
}

async function setHighlight(hlThemeId) {
    document.getElementById("hljs")?.remove();
    if (hlThemeId) {
        const style = document.createElement("style");
        style.setAttribute("id", "hljs");
        const hlTheme = WenyanStyles.hlThemes[hlThemeId];
        highlightCss = await hlTheme.getCss();
        style.textContent = highlightCss;
        document.head.appendChild(style);
    } else {
        highlightCss = "";
    }
}

function getContent() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    const elements = clonedWenyan.querySelectorAll("mjx-container");
    elements.forEach(element => {
        const svg = element.firstChild;
        const parent = element.parentElement;
        element.remove();
        let img = document.createElement("img");
        const encodedSVG = encodeURIComponent(svg.outerHTML);
        const dataURL = `data:image/svg+xml,${encodedSVG}`;
        img.setAttribute("src", dataURL);
        parent.appendChild(img);
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

function getContentForMedium() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    // 处理blockquote，移除<p>标签
    clonedWenyan.querySelectorAll('blockquote p').forEach(p => {
        const span = document.createElement('span');
        span.innerText = p.innerText + "\n\n";
        p.replaceWith(span);
    });
    // 处理代码块
    clonedWenyan.querySelectorAll('pre').forEach(p => {
        const code = p.querySelector('code');
        p.setAttribute("data-code-block-lang", "none");
        if (code) {
            // 获取 class 属性
            const classAttribute = code.getAttribute('class');
            // 提取语言
            if (classAttribute) {
                // 1. 分割类名并使用 find() 查找以 'language-' 开头的类
                const languageClass = classAttribute.split(' ').find(cls => cls.startsWith('language-'));
                
                // 2. 关键：检查 find() 的返回值是否有效（即不是 undefined）
                if (languageClass) {
                    // 3. 只有在找到匹配项时，才执行 replace() 来提取语言名
                    const language = languageClass.replace('language-', '');
                    
                    if (language) {
                        p.setAttribute("data-code-block-lang", language);
                    }
                }
            }
            // 获取所有子 span 元素
            const spans = code.querySelectorAll('span');

            // 遍历每个 span 元素，将它们替换为它们的文本内容
            spans.forEach(span => {
                span.replaceWith(...span.childNodes); // 只替换标签，保留内容
            });
            // 如果不删除多余的换行符，编辑器会把代码块分割，暂时未找到好的解决方法
            code.innerHTML = code.innerHTML.replace(/\n+/g, '\n');
        }
        p.setAttribute("data-code-block-mode", "2");
    });
    // 处理table，转成ascii格式
    clonedWenyan.querySelectorAll('table').forEach(t => {
        const pre = document.createElement('pre');
        const code = document.createElement('code');
        code.innerText = tableToAsciiArt(t);
        pre.appendChild(code);
        pre.setAttribute("data-code-block-lang", "none");
        pre.setAttribute("data-code-block-mode", "2");
        t.replaceWith(pre);
    });
    // 处理嵌套ul li
    clonedWenyan.querySelectorAll('ul ul').forEach(ul => {
        transformUl(ul);  // 处理每个 <ul>
    });
    // 原样输出公式
    clonedWenyan.querySelectorAll("mjx-container").forEach(element => {
        const math = element.getAttribute("math");
        const parent = element.parentElement;
        element.remove();
        parent.innerHTML = math;
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

function tableToAsciiArt(table) {
    const rows = Array.from(table.querySelectorAll('tr')).map(tr =>
        Array.from(tr.querySelectorAll('th, td')).map(td => td.innerText.trim())
    );

    if (rows.length === 0) return '';

    // 获取每列的最大宽度
    const columnWidths = rows[0].map((_, i) =>
        Math.max(...rows.map(row => row[i].length))
    );

    const horizontalLine = '+' + columnWidths.map(width => '-'.repeat(width + 2)).join('+') + '+\n';

    // 格式化行数据
    const formattedRows = rows.map(row =>
        '| ' + row.map((cell, i) => cell.padEnd(columnWidths[i])).join(' | ') + ' |\n'
    );

    // 构建最终的表格
    let asciiTable = horizontalLine;
    asciiTable += formattedRows[0];  // 表头
    asciiTable += horizontalLine;
    asciiTable += formattedRows.slice(1).join('');  // 表内容
    asciiTable += horizontalLine;

    return asciiTable;
}

// 递归处理所有嵌套的 <ul>，将其转换为 Medium 风格
function transformUl(ulElement) {
    // 先递归处理子 <ul>
    ulElement.querySelectorAll('ul').forEach(nestedUl => {
        transformUl(nestedUl);  // 递归调用处理嵌套 <ul>
    });

    // 把 <li> 转换成 Medium-friendly 格式
    let replaceString = Array.from(ulElement.children).map(item => item.outerHTML).join(' ');
    
    // 将 <li> 标签替换为 Medium 风格列表
    replaceString = replaceString.replace(/<li>/g, '<br>\n- ').replace(/<\/li>/g, '');

    // 将原来的 <ul> 替换为转换后的字符串
    ulElement.outerHTML = replaceString;
}

//// 非通用方法
async function getContentForGzh() {
    const wenyan = document.getElementById("wenyan");
    const clonedWenyan = wenyan.cloneNode(true);
    const content = await WenyanCore.getContentForGzhCustomCss(clonedWenyan, customCss, highlightCss, codeblockSettings.isMacStyle);
    window.webkit.messageHandlers.copyContentHandler.postMessage(content);
}

function setMacStyle() {
    document.getElementById("macStyle")?.remove();
    const style = document.createElement("style");
    style.setAttribute("id", "macStyle");
    style.textContent = window.macStyleCss;
    document.head.appendChild(style);
}

function setCodeblockSettings(settingsObj) {
    codeblockSettings = settingsObj;
}

function setParagraphSettings(settingsObj) {
    paragraphSettings = settingsObj;
}

function removeMacStyle() {
    document.getElementById("macStyle")?.remove();
}

async function setThemeById(themeId, isGzh) {
    const theme = isGzh ? WenyanStyles.themes[themeId] : WenyanStyles.otherThemes[themeId];
    const css = await theme.getCss();
    setCustomTheme(css);
}

async function getThemeById(themeId) {
    const theme = WenyanStyles.themes[themeId];
    const content = await theme.getCss();
    window.webkit.messageHandlers.loadThemesHandler.postMessage(content);
}

window.onscroll = function() {
    if (!isScrollingFromScript) {
        window.webkit.messageHandlers.scrollHandler.postMessage({ y0: window.scrollY / document.body.scrollHeight });
    }
};

document.addEventListener('click', function(event) {
    window.webkit.messageHandlers.clickHandler.postMessage(null);
});

WenyanCore.configureMarked();

const builtinGzhThemes = WenyanStyles.getAllThemes().map(obj => {
    const { id, appName, author } = obj;
    return { id, appName, author };
});

const builtinHighlightThemes = WenyanStyles.getAllHlThemes().map(obj => {
    const { id } = obj;
    return { id };
});

window.webkit.messageHandlers.loadHandler.postMessage({ gzhThemes: builtinGzhThemes, hlThemes: builtinHighlightThemes });
