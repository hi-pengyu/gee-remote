import request from '@/utils/request'

// 查询配置列表
export function listConfig(query) {
    return request({
        url: '/gee/config/list',
        method: 'get',
        params: query
    })
}

// 查询配置分组
export function getConfigGroups() {
    return request({
        url: '/gee/config/groups',
        method: 'get'
    })
}

// 查询配置详情
export function getConfig(configKey) {
    return request({
        url: `/gee/config/${configKey}`,
        method: 'get'
    })
}

// 更新配置
export function updateConfig(configKey, configValue) {
    return request({
        url: `/gee/config/${configKey}`,
        method: 'put',
        params: { configValue }
    })
}

// 重新加载配置
export function reloadConfig() {
    return request({
        url: '/gee/config/reload',
        method: 'post'
    })
}
