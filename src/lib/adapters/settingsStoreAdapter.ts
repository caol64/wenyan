import { getSettings, saveSettings } from "$lib/action";
import type { Settings, SettingsStorageAdapter } from "@wenyan-md/ui";

export const settingsStorageAdapter: SettingsStorageAdapter = {
    async load(): Promise<Settings | null> {
        return await getSettings();
    },
    async save(settings: Settings): Promise<void> {
        await saveSettings(settings);
    },
};
