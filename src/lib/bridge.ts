import { globalState } from "@wenyan-md/ui";

declare global {
    interface Window {
        webkit?: {
            messageHandlers: {
                wenyanBridge: {
                    postMessage(message: any): void;
                };
            };
        };
        // 供 Swift 调用的全局回调管家
        __WENYAN_BRIDGE__: {
            callbacks: Record<string, { resolve: Function; reject: Function }>;
            invokeCallback: (callbackId: string, data: any, error: string | null) => void;
            setContent: (content: string) => void;
        };
    }
}

if (typeof window !== "undefined" && !window.__WENYAN_BRIDGE__) {
    window.__WENYAN_BRIDGE__ = {
        callbacks: {},
        invokeCallback: (callbackId: string, data: any, error: string | null) => {
            const cb = window.__WENYAN_BRIDGE__.callbacks[callbackId];
            if (!cb) return;
            if (error) {
                cb.reject(new Error(error));
            } else {
                cb.resolve(data);
            }
            // 响应结束后清理内存
            delete window.__WENYAN_BRIDGE__.callbacks[callbackId];
        },
        setContent: (content: string) => {
            globalState.setMarkdownText(content);
        },
    };
}

export function invokeSwift<T>(action: string, payload?: any, isCallback: boolean = false): Promise<T> {
    return new Promise((resolve, reject) => {
        if (!window.webkit?.messageHandlers?.wenyanBridge) {
            return;
        }

        if (isCallback) {
            // 生成唯一的 callbackId
            const callbackId = Math.random().toString(36).substring(2, 15) + Date.now().toString(36);

            // 登记回调
            window.__WENYAN_BRIDGE__.callbacks[callbackId] = { resolve, reject };

            // 发送消息给 Swift
            window.webkit.messageHandlers.wenyanBridge.postMessage({
                action,
                callbackId,
                payload,
            });
        } else {
            window.webkit.messageHandlers.wenyanBridge.postMessage({
                action,
                callbackId: "",
                payload,
            });
        }
    });
}
