import type { CustomTheme, Settings } from "@wenyan-md/ui";
import { invokeSwift } from "./bridge";
import type { WechatPublishOptions } from "@wenyan-md/core/wechat";

interface ThemeDO {
    id: string;
    name: string;
    content: string;
    createdAt: number;
}

interface UploadImagePayload {
    file: string;
    fileName: string;
    mimetype: string;
}

interface ExportedFilePayload {
    fileType: string;
    fileName: string;
    base64Data: string;
}

interface CredentialDO {
    appId: string;
    appSecret: string;
}

interface UploadImageResponse {
    mediaId: string;
    url: string;
}

export async function pageInit(): Promise<void> {
    return await invokeSwift<null, void>("pageInit", null, false);
}

export async function loadArticles(): Promise<string> {
    return await invokeSwift<null, string>("loadArticles", null, true);
}

export async function saveArticle(payload: string): Promise<void> {
    return await invokeSwift<string, void>("saveArticle", payload, false);
}

export async function loadThemes(): Promise<ThemeDO[]> {
    return await invokeSwift<null, ThemeDO[]>("loadThemes", null, true);
}

export async function saveTheme(payload: CustomTheme): Promise<string> {
    return await invokeSwift<CustomTheme, string>("saveTheme", payload, true);
}

export async function removeTheme(id: string): Promise<void> {
    await invokeSwift<string, void>("removeTheme", id, false);
}

export async function pathToBase64(path: string): Promise<string> {
    return await invokeSwift<string, string>("pathToBase64", path, true);
}

export async function uploadBase64Image(payload: UploadImagePayload): Promise<string> {
    return await invokeSwift<UploadImagePayload, string>("uploadBase64Image", payload, true);
}

export async function uploadImage(path: string): Promise<UploadImageResponse> {
    return await invokeSwift<string, UploadImageResponse>("uploadImage", path, true);
}

export async function handleMarkdownContent(content: string): Promise<string> {
    return await invokeSwift<string, string>("handleMarkdownContent", content, true);
}

export async function handleMarkdownFile(path: string): Promise<string> {
    return await invokeSwift<string, string>("handleMarkdownFile", path, true);
}

export async function resetLastArticlePath(): Promise<void> {
    return await invokeSwift<null, void>("resetLastArticlePath", null, false);
}

export async function getCredential(): Promise<CredentialDO> {
    return await invokeSwift<null, CredentialDO>("getCredential", null, true);
}

export async function saveCredential(credential: CredentialDO): Promise<void> {
    return await invokeSwift<CredentialDO, void>("saveCredential", credential, false);
}

export async function getSettings(): Promise<Settings> {
    return await invokeSwift<null, Settings>("getSettings", null, true);
}

export async function saveSettings(settings: Settings): Promise<void> {
    return await invokeSwift<Settings, void>("saveSettings", settings, false);
}

export async function openLink(url: string): Promise<void> {
    return await invokeSwift<string, void>("openLink", url, false);
}

export async function autoCacheChange(): Promise<void> {
    return await invokeSwift<null, void>("autoCacheChange", null, false);
}

export async function resetWechatAccessToken(): Promise<void> {
    return await invokeSwift<null, void>("resetWechatAccessToken", null, false);
}

export async function publishArticleToDraft(publishOption: WechatPublishOptions): Promise<string> {
    return await invokeSwift<WechatPublishOptions, string>("publishArticleToDraft", publishOption, true);
}

export async function saveExportedFile(payload: ExportedFilePayload): Promise<void> {
    return await invokeSwift<ExportedFilePayload, void>("saveExportedFile", payload, false);
}

export async function copyToClipboard(html: string): Promise<void> {
    return await invokeSwift<string, void>("copyToClipboard", html, false);
}
