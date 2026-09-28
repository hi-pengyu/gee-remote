import request from '@/utils/request'

// 获取行政区列表
export function getAdminRegions(query) {
    return request({
        url: '/gee/admin-regions/list',
        method: 'get',
        params: query
    })
}

// 获取行政区列表（含地块统计）
export function getAdminRegionsWithStats(query) {
    return request({
        url: '/gee/admin-regions/list-with-stats',
        method: 'get',
        params: query
    })
}

// 获取行政区详情
export function getAdminRegionDetail(adcode) {
    return request({
        url: `/gee/admin-regions/${adcode}`,
        method: 'get'
    })
}

// 搜索行政区
export function searchAdminRegions(keyword, limit = 20) {
    return request({
        url: '/gee/admin-regions/search',
        method: 'get',
        params: {
            keyword,
            limit
        }
    })
}
