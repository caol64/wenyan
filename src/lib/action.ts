import { invokeSwift } from "./bridge";

interface SaveThemePayload {
    id: string;
    name: string;
    css: string;
}

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

export async function loadArticles(): Promise<string> {
    return await invokeSwift<null, string>("loadArticles", null, true);
}

export async function saveArticle(payload: string): Promise<string> {
    return await invokeSwift<string, string>("saveArticle", payload, true);
}

export async function loadArticle(): Promise<string> {
    return await invokeSwift<null, string>("loadArticle", null, true);
}

export async function loadThemes(): Promise<ThemeDO[]> {
    return await invokeSwift<null, ThemeDO[]>("loadThemes", null, true);
}

export async function saveTheme(payload: SaveThemePayload): Promise<string> {
    return await invokeSwift<SaveThemePayload, string>("saveTheme", payload, true);
}

export async function removeTheme(id: string): Promise<void> {
    await invokeSwift<string, void>("removeTheme", id, false);
}

export async function localPathToBase64(path: string): Promise<string> {
    return await invokeSwift<string, string>("localPathToBase64", path, true);
}

export async function uploadBase64Image(payload: UploadImagePayload): Promise<string> {
    return await invokeSwift<UploadImagePayload, string>("uploadBase64Image", payload, true);
}

export async function uploadImage(path: string): Promise<string> {
    return await invokeSwift<string, string>("uploadImage", path, true);
}

export async function handleMarkdownContent(content: string): Promise<string> {
    return await invokeSwift<string, string>("handleMarkdownContent", content, true);
}

export async function handleMarkdownFile(path: string): Promise<string> {
    return await invokeSwift<string, string>("handleMarkdownFile", path, true);
}

export async function resetLastArticlePath(): Promise<void> {
    await invokeSwift<null, void>("resetLastArticlePath", null, false);
}
