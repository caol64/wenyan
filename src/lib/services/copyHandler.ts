import { getWenyanElement, writeHtmlToClipboard, writeTextToClipboard } from "$lib/utils";
import { globalState, wenyanCopier, wenyanRenderer } from "@wenyan-md/ui";

export async function copyHandler() {
    if (globalState.getPlatform() === "juejin") {
        writeTextToClipboard(wenyanRenderer.postHandlerContent);
    } else {
        const wenyanElement = getWenyanElement();
        await wenyanCopier.copy(wenyanElement);
        writeHtmlToClipboard(wenyanCopier.html);
    }
}
