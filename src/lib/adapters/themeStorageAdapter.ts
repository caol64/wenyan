import { loadThemes, removeTheme, saveTheme } from "../action";
import type { ThemeStorageAdapter, CustomTheme } from "@wenyan-md/ui";

export const themeStorageAdapter: ThemeStorageAdapter = {
    async load() {
        const themes = await loadThemes();
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
        const result = await saveTheme({ id, name, css });
        return result;
    },

    async remove(id: string) {
        await removeTheme(id);
    },
};
