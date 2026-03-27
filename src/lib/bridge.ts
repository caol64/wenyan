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
            callbacks: Map<string, { resolve: Function; reject: Function }>;
            listeners: Map<string, Set<Function>>;
            invokeCallback: (callbackId: string, data: any, error: string | null) => void;
            emit: (event: string, payload: any) => void;
        };
    }
}

if (typeof window !== "undefined" && !window.__WENYAN_BRIDGE__) {
    window.__WENYAN_BRIDGE__ = {
        callbacks: new Map(),
        listeners: new Map(),
        invokeCallback: (callbackId: string, data: any, error: string | null) => {
            const cb = window.__WENYAN_BRIDGE__.callbacks.get(callbackId);
            if (!cb) return;
            if (error) {
                globalState.setAlertMessage({
                    type: "error",
                    message: `Error: ${error}`,
                });
                cb.reject(new Error(error));
            } else {
                cb.resolve(data);
            }
            // 响应结束后清理内存
            window.__WENYAN_BRIDGE__.callbacks.delete(callbackId);
        },
        emit: (event: string, payload: any) => {
            const handlers = window.__WENYAN_BRIDGE__.listeners.get(event);
            if (!handlers) return;

            handlers.forEach((fn) => fn(payload));
        },
    };
}

export function invokeSwift<T, R>(action: string, payload?: T | null, isCallback?: boolean): Promise<R> {
    return new Promise((resolve, reject) => {
        if (!window.webkit?.messageHandlers?.wenyanBridge) {
            resolve(undefined as unknown as R);
            return;
        }

        if (isCallback) {
            // 生成唯一的 callbackId
            const callbackId = Math.random().toString(36).substring(2, 15) + Date.now().toString(36);

            // 登记回调
            window.__WENYAN_BRIDGE__.callbacks.set(callbackId, { resolve, reject });

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
            resolve(undefined as unknown as R);
        }
    });
}

export function onSwift(event: string, handler: (data: any) => void) {
    const bridge = window.__WENYAN_BRIDGE__;

    if (!bridge.listeners.has(event)) {
        bridge.listeners.set(event, new Set());
    }

    bridge.listeners.get(event)!.add(handler);

    return () => {
        bridge.listeners.get(event)?.delete(handler);
    };
}
