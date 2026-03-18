import { invokeSwift } from "$lib/bridge";
import type { ThemeStorageAdapter, CustomTheme } from "@wenyan-md/ui";

interface ThemeDO {
    id: string;
    name: string;
    content: string;
    createdAt: number;
}

export const coreDataThemeStorageAdapter: ThemeStorageAdapter = {
    async load() {
        const themes = await invokeSwift<ThemeDO[]>("loadThemes", null, true);
        const customThemes: Record<string, CustomTheme> = Object.fromEntries(
            themes.map((theme) => [
                String(theme.id),
                {
                    id: String(theme.id),
                    name: theme.name,
                    css: theme.content,
                },
            ]),
        );
        return customThemes;
    },

    async save(id: string, name: string, css: string): Promise<string> {
        return await invokeSwift<string>("saveTheme", { id, name, css }, true);
    },

    async remove(id: string) {
        await invokeSwift<void>("removeTheme", { id });
    },
};
