import { DBInstance } from "$lib/stores/db";
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

export const sqliteCredentialStoreAdapter: CredentialStoreAdapter = {
    async load(): Promise<GenericCredential[]> {
        const db = await DBInstance.getInstance();
        const rows = await db.select<CredentialDO[]>("SELECT * FROM Credential;");
        if (rows.length > 0) {
            return rows.map((row) => ({
                type: row.type,
                name: row.name ?? "",
                appId: row.appId ?? "",
                appSecret: row.appSecret ?? "",
            }));
        }
        // 兼容旧数据
        const imageHostsStr = localStorage.getItem("customImageHosts");
        const imageHosts = JSON.parse(imageHostsStr ?? "[]") as oldGzhImageHost[];
        if (imageHosts.length > 0) {
            await this.save({
                type: "wechat",
                name: "wechat",
                appId: imageHosts[0].appId,
                appSecret: imageHosts[0].appSecret,
            });
            await updateWechatAccessToken(imageHosts[0].accessToken, imageHosts[0].expireTime);
            localStorage.removeItem("customImageHosts");
            return [
                {
                    type: "wechat",
                    name: "wechat",
                    appId: imageHosts[0].appId,
                    appSecret: imageHosts[0].appSecret,
                },
            ];
        }
        return [];
    },
    async save(credential: GenericCredential): Promise<void> {
        const db = await DBInstance.getInstance();
        const row = await db.select<CredentialDO[]>("SELECT * FROM Credential WHERE type = $1;", [credential.type]);
        if (row.length === 0) {
            await db.execute(
                "INSERT INTO Credential (type, name, appId, appSecret, accessToken, refreshToken, expireTime, updatedAt, createdAt) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9);",
                [
                    credential.type,
                    credential.name ?? null,
                    credential.appId ?? null,
                    credential.appSecret ?? null,
                    null,
                    null,
                    0,
                    new Date().getTime(),
                    new Date().toISOString(),
                ],
            );
        } else {
            await db.execute(
                "UPDATE Credential SET name = $1, appId = $2, appSecret = $3, updatedAt = $4 WHERE type = $5;",
                [
                    credential.name ?? null,
                    credential.appId ?? null,
                    credential.appSecret ?? null,
                    new Date().getTime(),
                    credential.type,
                ],
            );
        }
    },
    async remove(type: string): Promise<void> {
        throw new Error("Function not implemented.");
    },
};

export async function getWechatToken(): Promise<CredentialDO | null> {
    const db = await DBInstance.getInstance();
    const rows = await db.select<CredentialDO[]>("SELECT * FROM Credential;");
    if (rows.length > 0) {
        return rows[0];
    }
    return null;
}

export async function updateWechatAccessToken(accessToken: string, expireTime: number) {
    const db = await DBInstance.getInstance();
    await db.execute("UPDATE Credential SET accessToken = $1, expireTime = $2, updatedAt = $3 WHERE type = $4;", [
        accessToken,
        expireTime,
        new Date().getTime(),
        "wechat",
    ]);
}

export async function resetWechatAccessToken() {
    const db = await DBInstance.getInstance();
    await db.execute("UPDATE Credential SET accessToken = $1, expireTime = $2, updatedAt = $3 WHERE type = $4;", [
        null,
        0,
        new Date().getTime(),
        "wechat",
    ]);
}
