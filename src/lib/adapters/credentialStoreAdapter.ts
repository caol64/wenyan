import { getCredential, saveCredential } from "$lib/action";
import type { CredentialStoreAdapter, CredentialType, GenericCredential } from "@wenyan-md/ui";

export const credentialStoreAdapter: CredentialStoreAdapter = {
    async load(): Promise<GenericCredential[]> {
        const credential = await getCredential();
        if (credential) {
            return [{
                type: "wechat" as CredentialType,
                appId: credential.appId,
                appSecret: credential.appSecret,
            }];
        }
        return [];
    },
    async save(credential: GenericCredential): Promise<void> {
        await saveCredential({
            appId: credential.appId || "",
            appSecret: credential.appSecret || "",
        });
    },
    async remove(type: string): Promise<void> {
        throw new Error("Function not implemented.");
    },
};

