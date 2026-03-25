//
//  FIFOCache.swift
//  WenYan
//
//  Created by Lei Cao on 2026/3/23.
//

import Foundation

final class FIFOCache<K: Hashable, V> {

    private var cache: [K: V] = [:]
    private var order: [K] = []

    private let max: Int

    init(max: Int = 50) {
        self.max = max
    }

    func get(_ key: K) -> V? {
        return cache[key]
    }

    func set(_ key: K, value: V) {

        // 已存在：只更新 value，不改变顺序
        if cache[key] != nil {
            cache[key] = value
            return
        }

        // 超出容量：删除最早的 key
        if cache.count >= max, let firstKey = order.first {
            cache.removeValue(forKey: firstKey)
            order.removeFirst()
        }

        cache[key] = value
        order.append(key)
    }

    func clear() {
        cache.removeAll()
        order.removeAll()
    }
}
