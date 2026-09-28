import request from '@/utils/request'

// 获取任务列表
export function listTask(query) {
    return request({
        url: '/gee/task/list',
        method: 'get',
        params: query
    })
}

// 获取任务详情
export function getTask(taskId) {
    return request({
        url: '/gee/task/' + taskId,
        method: 'get'
    })
}

// 创建任务
export function addTask(data) {
    return request({
        url: '/gee/task',
        method: 'post',
        data: data
    })
}

// 取消任务
export function cancelTask(taskId) {
    return request({
        url: '/gee/task/' + taskId + '/cancel',
        method: 'post'
    })
}

// 获取任务日志
export function getTaskLog(taskId) {
    return request({
        url: '/gee/task/' + taskId + '/log',
        method: 'get'
    })
}

// 导出任务列表
export function exportTask(query) {
    return request({
        url: '/gee/task/export',
        method: 'get',
        params: query,
        responseType: 'blob'
    })
}
