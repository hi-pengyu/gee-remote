import request from '@/utils/request'

// 查询GEE账号列表
export function listAccounts(query) {
    return request({
        url: '/gee/accounts',
        method: 'get',
        params: query
    })
}

// 查询GEE账号详情
export function getAccount(accountId) {
    return request({
        url: `/gee/accounts/${accountId}`,
        method: 'get'
    })
}

// 新增GEE账号
export function createAccount(data) {
    return request({
        url: '/gee/accounts',
        method: 'post',
        data: data
    })
}

// 修改GEE账号
export function updateAccount(data) {
    return request({
        url: `/gee/accounts/${data.account_id}`,
        method: 'put',
        data: data
    })
}

// 删除GEE账号
export function delAccount(accountId) {
    return request({
        url: `/gee/accounts/${accountId}`,
        method: 'delete'
    })
}

// 获取账号池统计信息
export function getAccountStats() {
    return request({
        url: '/gee/accounts/stats',
        method: 'get'
    })
}

// 标记账号为健康状态
export function markAccountHealthy(accountId) {
    return request({
        url: `/gee/accounts/${accountId}/mark-healthy`,
        method: 'post'
    })
}

// 启用/禁用账号
export function toggleAccount(accountId, isActive) {
    return request({
        url: `/gee/accounts/${accountId}/toggle`,
        method: 'post',
        data: { isActive }
    })
}
