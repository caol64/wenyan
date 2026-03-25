import {
    setPreviewClick,
    setCopyClick,
    setEditorClick,
    setEditorDrop,
    setEditorPaste,
    setUploadHelpClick,
    setResetTokenClick,
    setExportImageClick,
    setImageProcessorAction,
    setPublishArticleClick,
    setAutoCacheChangeClick,
    setImportCssClick,
    globalState,
    themeStore,
    setHandleFileOpen,
    defaultPublishHandler,
    setGetWenyanElement,
    setPublishArticleToDraft,
    setUploadImage,
    setPublishHelpClick,
    defaultEditorPasteHandler,
    defaultEditorDropHandler,
    setHandleMarkdownContent,
    setMarkdownFileDrop,
    setUploadBlobImage,
} from "@wenyan-md/ui";
import { handleFileOpen } from "./services/fileOpenHandler";
import { imageProcessorAction } from "./imageProcessor.svelte";
import { getWenyanElement } from "../utils";
import { uploadBlobImage, uploadPathImage } from "./services/imageUploadService";
import { handleMarkdownContent } from "./action";

export function setHooks() {
    setEditorPaste(defaultEditorPasteHandler);
    setEditorDrop(defaultEditorDropHandler);
    // setUploadHelpClick(uploadHelpClick);
    // setResetTokenClick(resetWechatAccessToken);
    // setExportImageClick(exportImage);
    setImageProcessorAction(imageProcessorAction);
    setPublishArticleClick(defaultPublishHandler);
    // setAutoCacheChangeClick(autoCacheChangeHandler);
    setImportCssClick(importCssHandler);
    setHandleFileOpen(handleFileOpen);
    setGetWenyanElement(getWenyanElement);
    // setPublishArticleToDraft(publishArticleToDraft);
    setUploadImage(uploadPathImage);
    // setPublishHelpClick(publishHelpClick);
    setHandleMarkdownContent(handleMarkdownContent);
    setMarkdownFileDrop(onMarkdownFileDrop);
    setUploadBlobImage(uploadBlobImage);
}

// async function uploadHelpClick() {
//     await open("https://yuzhi.tech/docs/wenyan/upload");
// }

// function closeMoreMenu() {
//     appState.isShowMoreMenu = false;
// }

// function autoCacheChangeHandler() {
//     sqliteUploadCacheStore.clear();
// }

async function importCssHandler(url: string, name: string) {
    const resp = await fetch(url);
    if (!resp.ok) {
        globalState.setAlertMessage({
            type: "error",
            title: "导入 CSS 失败",
            message: `无法从 ${url} 获取 CSS 文件。`,
        });
        return;
    }
    const cssText = await resp.text();
    const themeId = globalState.getCurrentThemeId();
    themeStore.addCustomTheme(`0:${themeId}`, name);
    const currentTheme = globalState.getCurrentTheme();
    currentTheme.name = name;
    currentTheme.css = cssText;
    currentTheme.id = `0:${themeId}`;
    globalState.customThemeName = name;
}

async function onMarkdownFileDrop(): Promise<void> {
    
}
