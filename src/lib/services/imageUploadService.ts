import { uploadBase64Image, uploadImage } from "$lib/action";
import type { WechatUploadResponse } from "@wenyan-md/core/wechat";

export async function uploadPathImage(imageUrl: string): Promise<WechatUploadResponse> {
    const resp = await uploadImage(imageUrl);
    return { url: resp, media_id: "" };
}

export async function uploadBlobImage(file: File): Promise<WechatUploadResponse> {
    const arrayBuffer = await file.arrayBuffer();
    const resp = await uploadBase64Image({ file: bytesToBase64(arrayBuffer), fileName: file.name, mimetype: file.type });
    return { url: resp, media_id: "" };
}

function bytesToBase64(data: Uint8Array | ArrayBuffer): string {
    const bytes = data instanceof Uint8Array ? data : new Uint8Array(data);
    const chunkSize = 8192;
    if (bytes.length <= chunkSize) {
        let binary = "";
        for (let i = 0; i < bytes.length; i++) {
            binary += String.fromCharCode(bytes[i]);
        }
        return btoa(binary);
    }
    const chunks: string[] = [];
    for (let i = 0; i < bytes.length; i += chunkSize) {
        const sub = bytes.subarray(i, i + chunkSize);
        chunks.push(String.fromCharCode(...sub));
    }
    return btoa(chunks.join(""));
}
