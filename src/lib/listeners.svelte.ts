import { globalState, type Platform } from "@wenyan-md/ui";
import { onSwift } from "./bridge";
import { appState } from "./appState.svelte";

export function useSwiftListeners() {
    $effect(() => {
        const unsubscribeSetContent = onSwift("setContent", (content: string) => {
            globalState.setMarkdownText(content);
        });

        const unsubscribeSetPlatform = onSwift("setPlatform", (platform: Platform) => {
            globalState.setPlatform(platform);
        });

        const unsubscribeOpenSettings = onSwift("openSettings", () => {
            appState.isShowSettingsPage = true;
        });

        const unsubscribeToggleFileSidebar = onSwift("toggleFileSidebar", () => {
            globalState.isShowFileSidebar = !globalState.isShowFileSidebar;
        });

        return () => {
            unsubscribeSetContent();
            unsubscribeSetPlatform();
            unsubscribeOpenSettings();
            unsubscribeToggleFileSidebar();
        };
    });
}
