import { handleMarkdownFile } from "$lib/action";
import { globalState } from "@wenyan-md/ui";

export async function handleFileOpen(file: string) {
    try {
        globalState.isLoading = true;
        const content = await handleMarkdownFile(file);
        globalState.setMarkdownText(content);
    } catch (error) {
        globalState.setAlertMessage({
            type: "error",
            message: `处理文件出错: ${error instanceof Error ? error.message : error}`,
        });
    } finally {
        globalState.isLoading = false;
    }
}
