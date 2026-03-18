export interface FileEntry {
    name: string;
    path: string;
    isDirectory: boolean;
    children?: FileEntry[];
}
