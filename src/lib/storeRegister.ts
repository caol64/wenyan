import { themeStore, settingsStore, articleStore, credentialStore } from "@wenyan-md/ui";
import { articleStorageAdapter } from "./adapters/articleStorageAdapter";
import { themeStorageAdapter } from "./adapters/themeStorageAdapter";
import { credentialStoreAdapter } from "./adapters/credentialStoreAdapter";
import { settingsStorageAdapter } from "./adapters/settingsStoreAdapter";

export async function registerStore() {
    await themeStore.register(themeStorageAdapter);
    await settingsStore.register(settingsStorageAdapter);
    await articleStore.register(articleStorageAdapter);
    await credentialStore.register(credentialStoreAdapter);
}
