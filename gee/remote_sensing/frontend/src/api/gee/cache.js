import request from '@/utils/request'

// 获取缓存列表
export function listCache(query) {
    return request({
        url: '/gee/cache/list',
        method: 'get',
        params: query
    })
}

// 获取缓存统计
export function getCacheStats() {
    return request({
        url: '/gee/cache/stats',
        method: 'get'
    })
}

// 获取缓存详情
export function getCacheDetail(tileId) {
    return request({
        url: '/gee/cache/' + tileId,
        method: 'get'
    })
}

// 删除缓存
export function delCache(tileIds) {
    return request({
        url: '/gee/cache/' + tileIds,
        method: 'delete'
    })
}

// 预取瓦片
export function prefetchTiles(data) {
    return request({
        url: '/gee/cache/prefetch',
        method: 'post',
        data: data
    })
}

// 获取热点瓦片
export function getHotTiles(limit) {
    return request({
        url: '/gee/cache/hot',
        method: 'get',
        params: { limit }
    })
}

// 清理缓存
export function cleanupCache(keepDays) {
    return request({
        url: '/gee/cache/cleanup',
        method: 'post',
        data: { keep_days: keepDays }
    })
}

// 导出缓存列表
export function exportCache(query) {
    return request({
        url: '/gee/cache/export',
        method: 'get',
        params: query,
        responseType: 'blob'
    })
}
