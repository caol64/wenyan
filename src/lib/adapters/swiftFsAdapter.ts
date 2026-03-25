import { filterAndSortEntries, type FileEntry, type FileSystemAdapter } from "@wenyan-md/ui";
import { invokeSwift } from "../bridge";

export const swiftFsAdapter: FileSystemAdapter = {
    async openDirectoryPicker(): Promise<string | null> {
        const path = await invokeSwift<null, string | null>("openDirectoryPicker", null, true);
        return path;
    },

    async readDir(path: string): Promise<FileEntry[]> {
        const entries = await invokeSwift<string, FileEntry[]>("readDir", path, true);
        return filterAndSortEntries(entries);
    }
};
