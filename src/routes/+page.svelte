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
    } from "@wenyan-md/ui";
    import SimpleLoader from "$lib/components/SimpleLoader.svelte";
    import { invokeSwift } from "$lib/bridge";
    import { registerStore } from "$lib/storeRegister";

    onMount(async () => {
        await registerStore();
        globalState.setMarkdownText(await invokeSwift<string>("loadArticle", null, true));
        globalState.setPlatform("wechat");
    });
</script>

<div class="flex h-screen w-full flex-col overflow-hidden relative">
    <div class="flex h-full w-full flex-col overflow-hidden md:flex-row relative">
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
