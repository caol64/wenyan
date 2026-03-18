import { appState } from "./appState.svelte";
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
} from "@wenyan-md/ui";
import { resetWechatAccessToken } from "$lib/stores/sqliteCredentialStore";
import { defaultEditorDropHandler, defaultEditorPasteHandler } from "$lib/services/editorHandler";
import { exportImage } from "$lib/services/exportHandler";
import { imageProcessorAction } from "$lib/services/processImages.svelte";
import { publishHandler } from "$lib/services/publishHandler";
import { copyHandler } from "$lib/services/copyHandler";
import { sqliteUploadCacheStore } from "./stores/sqliteUploadCacheStore";

export function setHooks() {
    setCopyClick(copyHandler);
    // setEditorPaste(defaultEditorPasteHandler);
    // setEditorDrop(defaultEditorDropHandler);
    // setPreviewClick(closeMoreMenu);
    // setEditorClick(closeMoreMenu);
    // setUploadHelpClick(uploadHelpClick);
    // setResetTokenClick(resetWechatAccessToken);
    // setExportImageClick(exportImage);
    // setImageProcessorAction(imageProcessorAction);
    // setPublishArticleClick(publishHandler);
    // setAutoCacheChangeClick(autoCacheChangeHandler);
    // setImportCssClick(importCssHandler);
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

// async function importCssHandler(url: string, name: string) {
//     const resp = await tauriFetch(url);
//     if (!resp.ok) {
//         globalState.setAlertMessage({
//             type: "error",
//             title: "导入 CSS 失败",
//             message: `无法从 ${url} 获取 CSS 文件。`,
//         });
//         return;
//     }
//     const cssText = await resp.text();
//     const themeId = globalState.getCurrentThemeId();
//     themeStore.addCustomTheme(`0:${themeId}`, name);
//     const currentTheme = globalState.getCurrentTheme();
//     currentTheme.name = name;
//     currentTheme.css = cssText;
//     currentTheme.id = `0:${themeId}`;
//     globalState.customThemeName = name;
// }
