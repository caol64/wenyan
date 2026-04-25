import { copyToClipboard } from "../action";
import { getWenyanElement } from "../utils";
import { globalState, wenyanCopier, wenyanRenderer } from "@wenyan-md/ui";

export async function copyHandler() {
    if (globalState.getPlatform() === "juejin") {
        await copyTextToClipboard(wenyanRenderer.postHandlerContent);
    } else {
        const wenyanElement = getWenyanElement();
        await wenyanCopier.copy(wenyanElement);
        await copyHtmlToClipboard(wenyanCopier.html);
    }
}

async function copyTextToClipboard(text: string) {
    await navigator.clipboard.writeText(text);
}

async function copyHtmlToClipboard(htmlString: string) {
    await copyToClipboard(htmlString);
}
