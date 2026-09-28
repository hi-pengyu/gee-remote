import request from '@/utils/request'

// 查询任务结果列表
export function listResult(query) {
    return request({
        url: '/gee/result/list',
        method: 'get',
        params: query
    })
}

// 查询任务结果详情
export function getResult(taskId) {
    return request({
        url: `/gee/result/detail/${taskId}`,
        method: 'get'
    })
}

// 查询模型预测结果
export function getModelPredictions(taskId) {
    return request({
        url: `/gee/result/predictions/${taskId}`,
        method: 'get'
    })
}
