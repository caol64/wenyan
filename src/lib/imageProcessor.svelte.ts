import { localPathToBase64 } from "$lib/action";
import type { ImageProcessorAction } from "@wenyan-md/ui";

export const imageProcessorAction: ImageProcessorAction = (node) => {
    const run = async () => {
        const images = node.querySelectorAll<HTMLImageElement>("img");
        if (images.length === 0) return;

        for (const img of images) {
            const dataSrc = img.getAttribute("src");

            if (!dataSrc || dataSrc.startsWith("data:")) {
                continue;
            }

            const resolvedSrc = await localPathToBase64(dataSrc);
            if (resolvedSrc && resolvedSrc.startsWith("data:")) {
                img.setAttribute("data-src", dataSrc);
                img.src = resolvedSrc;
            }
        }
    };

    // 首次运行
    run();

    // 如果内容动态变化，可以用 MutationObserver
    const observer = new MutationObserver(() => run());

    observer.observe(node, {
        childList: true,
        subtree: true,
    });

    return {
        destroy() {
            observer.disconnect();
        },
    };
};
