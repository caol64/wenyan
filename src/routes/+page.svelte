<script lang="ts">
    import { onMount } from "svelte";
    import { appState } from "$lib/appState.svelte";
    import {
        globalState,
        MainPage,
        Sidebar,
        AlertModal,
        SettingsModal,
        ConfirmModal,
        CreateThemeModal,
        SimpleLoader,
        FileSidebar,
    } from "@wenyan-md/ui";
    import { registerStore } from "$lib/storeRegister";
    import { loadArticle } from "$lib/action";
    import { setHooks } from "$lib/setHooks";
    import { useSwiftListeners } from "$lib/listeners.svelte";
    import { swiftFsAdapter } from "$lib/adapters/swiftFsAdapter";

    setHooks();

    onMount(async () => {
        await registerStore();
        globalState.setMarkdownText(await loadArticle());
        globalState.setPlatform("wechat");
    });

    useSwiftListeners();
</script>

<div class="flex h-screen w-full flex-col overflow-hidden relative">
    <div class="flex h-full w-full flex-col overflow-hidden md:flex-row relative">
        {#if globalState.isShowFileSidebar}
            <FileSidebar fsAdapter={swiftFsAdapter} />
        {/if}
        <MainPage />

        {#if globalState.judgeSidebarOpen()}
            <div class="h-full w-80">
                <Sidebar />
            </div>
        {/if}

        {#if globalState.isLoading}
            <SimpleLoader />
        {/if}
    </div>
</div>

<AlertModal />
<ConfirmModal />
<SettingsModal isOpen={appState.isShowSettingsPage} onClose={() => (appState.isShowSettingsPage = false)} />
<CreateThemeModal
    isOpen={globalState.isShowCreateThemeModal}
    onClose={() => (globalState.isShowCreateThemeModal = false)}
/>
