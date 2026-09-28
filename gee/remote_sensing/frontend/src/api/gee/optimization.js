import request from '@/utils/request'

// 计算优化区域
export function calculateOptimization(data) {
    return request({
        url: '/gee/optimization/calculate',
        method: 'post',
        data: data
    })
}

// 触发批量下载
export function triggerBatchDownload(data) {
    return request({
        url: '/gee/optimization/trigger',
        method: 'post',
        data: data
    })
}

// 计算并保存优化结果
export function calculateAndSave(data) {
    return request({
        url: '/gee/optimization/calculate-and-save',
        method: 'post',
        data: data
    })
}

// 获取优化结果历史记录
export function getOptimizationHistory(data) {
    return request({
        url: '/gee/optimization/history',
        method: 'post',
        data: data
    })
}

// 获取优化结果详情
export function getOptimizationDetail(resultId) {
    return request({
        url: `/gee/optimization/history/${resultId}`,
        method: 'get'
    })
}
