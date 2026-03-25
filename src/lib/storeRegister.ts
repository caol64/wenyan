import { themeStore, settingsStore, localStorageSettingsAdapter, articleStore, credentialStore } from "@wenyan-md/ui";
import { articleStorageAdapter } from "./adapters/articleStorageAdapter";
import { themeStorageAdapter } from "./adapters/themeStorageAdapter";
// import { sqliteCredentialStoreAdapter } from "./stores/sqliteCredentialStore";

export async function registerStore() {
    await themeStore.register(themeStorageAdapter);
    // await settingsStore.register(localStorageSettingsAdapter);
    await articleStore.register(articleStorageAdapter);
    // await credentialStore.register(sqliteCredentialStoreAdapter);
}
