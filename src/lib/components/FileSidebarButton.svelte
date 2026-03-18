<script lang="ts">
    import { LeftSplitRect } from "@wenyan-md/ui";
    import { appState } from "$lib/appState.svelte";
</script>

<button class="cursor-pointer" onclick={() => (appState.isShowFileSidebar = !appState.isShowFileSidebar)}>
    <LeftSplitRect w="14px" />
</button>
