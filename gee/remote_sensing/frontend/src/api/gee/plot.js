import request from '@/utils/request'

// 查询地块列表
export function listPlot(query) {
    return request({
        url: '/gee/plot/list',
        method: 'get',
        params: query
    })
}

// 查询地块详情
export function getPlot(plotId) {
    return request({
        url: '/gee/plot/' + plotId,
        method: 'get'
    })
}

// 新增地块
export function createPlot(data) {
    return request({
        url: '/gee/plot/',
        method: 'post',
        data: data
    })
}

// 修改地块
export function updatePlot(data) {
    return request({
        url: '/gee/plot/' + data.plotId,
        method: 'put',
        data: data
    })
}

// 删除地块
export function delPlot(plotId) {
    return request({
        url: '/gee/plot/' + plotId,
        method: 'delete'
    })
}

// 获取地块关联的任务列表
export function getPlotTasks(plotId) {
    return request({
        url: '/gee/plot/' + plotId + '/tasks',
        method: 'get'
    })
}

// 获取地块可用的遥感日期
export function getPlotDates(data) {
    return request({
        url: '/gee/plot/' + data.plotId + '/dates',
        method: 'get',
        params: {
            startDate: data.startDate,
            endDate: data.endDate
        }
    })
}

// 切换地块监测状态
export function toggleMonitorStatus(plotId, monitorStatus) {
    return request({
        url: '/gee/plot/' + plotId + '/toggle',
        method: 'put',
        data: {
            monitorStatus: monitorStatus
        }
    })
}
