import request from '@/utils/request'

// 创建管控策略
export function createControlPolicy(data) {
    return request({
        url: '/gee/fine-control/policies',
        method: 'post',
        data
    })
}

// 预览影响范围
export function previewImpact(data) {
    return request({
        url: '/gee/fine-control/preview',
        method: 'post',
        data
    })
}

// 获取策略列表
export function getControlPolicies(query) {
    return request({
        url: '/gee/fine-control/policies',
        method: 'get',
        params: query
    })
}

// 删除策略
export function deleteControlPolicy(policyId) {
    return request({
        url: `/gee/fine-control/policies/${policyId}`,
        method: 'delete'
    })
}

// 启用/禁用策略
export function toggleControlPolicy(policyId, isActive) {
    return request({
        url: `/gee/fine-control/policies/${policyId}/toggle`,
        method: 'put',
        data: { isActive }
    })
}

// 获取地块管控状态
export function getPlotControlStatus(plotId) {
    return request({
        url: `/gee/fine-control/plots/${plotId}/status`,
        method: 'get'
    })
}
