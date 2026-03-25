import type { CredentialStoreAdapter, CredentialType, GenericCredential } from "@wenyan-md/ui";

interface CredentialDO {
    id: number;
    type: CredentialType;
    name: string;
    appId: string;
    appSecret: string;
    accessToken: string;
    refreshToken: string;
    expireTime: number;
    updatedAt: number;
    createdAt: string;
}

interface oldGzhImageHost {
    type: string;
    appId: string;
    appSecret: string;
    accessToken: string;
    expireTime: number;
    isEnabled: boolean;
}

export const credentialStoreAdapter: CredentialStoreAdapter = {
    async load(): Promise<GenericCredential[]> {

        return [];
    },
    async save(credential: GenericCredential): Promise<void> {

    },
    async remove(type: string): Promise<void> {
        throw new Error("Function not implemented.");
    },
};

