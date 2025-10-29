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

const imgType = [
    "image/bmp",
    "image/png",
    "image/jpeg",
    "image/gif",
    "video/mp4",
];
let tempEvent = null;
let isScrollingFromScript = false;

CodeMirror.keyMap["default"]["Cmd-/"] = "toggleComment"; // Add-on
// See http://codemirror.net/doc/manual.html#keymaps
CodeMirror.keyMap["basic"]["Tab"] = function (cm) {
    var spaces = Array(cm.getOption("indentUnit") + 1).join(" ");
    cm.replaceSelection(spaces, "end", "+input");
};
var editor = CodeMirror(document.body, {
    lineNumbers: false,
    autofocus: true,
    mode: "markdown",
    theme: "juejin",
    showInvisibles: false,
    maxInvisibles: 16,
    autoCloseTags: true,
    smartIndent: true,
    tabSize: 2,
    indentUnit: 2,
    lineWrapping: true,
    readOnly: false,
    autoCloseBrackets: true,
    selectionPointer: true,
    extraKeys: {
        "Cmd-F": "findPersistent",
        "Ctrl-Space": "autocomplete",
        "Ctrl-I": "indentAuto",
    },
    styleActiveLine: true,
});

editor.on("change", function (instance, change) {
    var content = getContent();
    window.webkit.messageHandlers.contentChangeHandler.postMessage(content);
});

editor.on("paste", async function (cm, event) {
    const files = event.clipboardData.files;
    if (files) {
        const file = files[0];
        if (file && file.type && imgType.includes(file.type)) {
            event.preventDefault();
            tempEvent = event;
            await uploadLocalImage(file);
            if (url) {
                const insertedText = `![](${url})`;
                editor.replaceSelection(insertedText);
            }
        }
    }
});

editor.on("drop", async function (cm, event) {
    event.preventDefault();
    tempEvent = event;
    const files = event.dataTransfer.files;
    if (files) {
        handleFiles(files, event);
    }
});

function setContent(content) {
    editor.doc.setValue(content);
    editor.doc.clearHistory();
    editor.doc.markClean();
}

function getContent() {
    return editor.doc.getValue();
}

function scroll(scrollFactor) {
    isScrollingFromScript = true;
    window.scrollTo(0, document.body.scrollHeight * scrollFactor);
    requestAnimationFrame(() => (isScrollingFromScript = false));
}

window.onscroll = function () {
    if (!isScrollingFromScript) {
        window.webkit.messageHandlers.scrollHandler.postMessage({ y0: window.scrollY / document.body.scrollHeight });
    }
};

async function handleFiles(files, event) {
    for (let i = 0; i < files.length; i++) {
        const file = files[i];
        if (file.type === "text/markdown") {
            const reader = new FileReader();
            reader.onload = function (e) {
                const content = e.target.result;
                setContent(content);
            };
            reader.onerror = function (e) {
                throwError(`读取文件出错: ${e.target.error}`);
            };
            reader.readAsText(file);
        } else if (imgType.includes(file.type)) {
            await uploadLocalImage(file);
        } else {
            throwError("不支持的文件类型");
        }

        if (i > 0) {
            break; // 暂时只支持一个文件
        }
    }
}

async function uploadLocalImage(file) {
    showOverlay();
    try {
        doUpload(file);
    } catch (error) {
        throwError(`${error}`);
    }
}

async function doUpload(file) {
    const arrayBuffer = await file.arrayBuffer();
    const uint8Array = new Uint8Array(arrayBuffer);
    window.webkit.messageHandlers.uploadHandler.postMessage({
        name: file.name,
        type: file.type,
        size: file.size,
        data: Array.from(uint8Array) // 转成普通数组（避免 TypedArray 兼容性问题）
    });
}

function throwError(msg) {
    window.webkit.messageHandlers.errorHandler.postMessage(msg);
}

// 显示遮罩层
function showOverlay() {
    document.getElementById("overlay").style.display = "flex";
}

// 隐藏遮罩层
function hideOverlay() {
    document.getElementById("overlay").style.display = "none";
}

function onFileUploadComplete(url) {
    if (url) {
        const insertedText = `![](${url})`;
        if (tempEvent instanceof DragEvent) {
            let x = tempEvent.pageX;
            let y = tempEvent.pageY;
            editor.setCursor(editor.coordsChar({ left: x, top: y }));
            editor.replaceRange(insertedText, editor.getCursor());
            // 移动光标到插入文本的末尾
            const newCursor = {
                line: editor.getCursor().line,
                ch: editor.getCursor().ch + insertedText.length,
            };
            editor.setCursor(newCursor);
        } else {
            // ClipboardEvent
            editor.replaceSelection(insertedText);
        }
    }
    hideOverlay();
}

if (editor) {
    window.webkit.messageHandlers.loadHandler.postMessage(null);
}
