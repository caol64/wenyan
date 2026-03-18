import { themeStore, settingsStore, localStorageSettingsAdapter, articleStore, credentialStore } from "@wenyan-md/ui";
import { userDefaultsArticleStorageAdapter } from "./stores/userDefaultsArticleStore";
import { coreDataThemeStorageAdapter } from "./stores/coreDataThemeStore";
// import { sqliteCredentialStoreAdapter } from "./stores/sqliteCredentialStore";

export async function registerStore() {
    await themeStore.register(coreDataThemeStorageAdapter);
    // await settingsStore.register(localStorageSettingsAdapter);
    await articleStore.register(userDefaultsArticleStorageAdapter);
    // await credentialStore.register(sqliteCredentialStoreAdapter);
}
