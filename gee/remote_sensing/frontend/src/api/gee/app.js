import request from '@/utils/request'

// 查询应用列表
export function listApp(query) {
    return request({
        url: '/gee/app/list',
        method: 'get',
        params: query
    })
}

// 查询应用详情
export function getApp(appId) {
    return request({
        url: '/gee/app/' + appId,
        method: 'get'
    })
}

// 新增应用
export function createApp(data) {
    return request({
        url: '/gee/app/',
        method: 'post',
        data: data
    })
}

// 修改应用
export function updateApp(data) {
    return request({
        url: '/gee/app/' + data.appId,
        method: 'put',
        data: data
    })
}

// 删除应用
export function delApp(appId) {
    return request({
        url: '/gee/app/' + appId,
        method: 'delete'
    })
}

// 重置API Key
export function regenerateKey(appId) {
    return request({
        url: '/gee/app/' + appId + '/regenerate-key',
        method: 'post'
    })
}
