import request from '@/utils/request'

// 查询自定义区域列表
export function listRegions(query) {
    return request({
        url: '/gee/custom-region/list',
        method: 'get',
        params: query
    })
}

// 查询自定义区域详情
export function getRegion(regionId) {
    return request({
        url: `/gee/custom-region/${regionId}`,
        method: 'get'
    })
}

// 新增自定义区域
export function createRegion(data) {
    return request({
        url: '/gee/custom-region',
        method: 'post',
        data: data
    })
}

// 修改自定义区域
export function updateRegion(data) {
    return request({
        url: `/gee/custom-region/${data.regionId}`,
        method: 'put',
        data: data
    })
}

// 删除自定义区域
export function delRegion(regionId) {
    return request({
        url: `/gee/custom-region/${regionId}`,
        method: 'delete'
    })
}
