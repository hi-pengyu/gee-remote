import request from '@/utils/request'

// 获取仪表盘数据
export function getDashboard() {
    return request({
        url: '/gee/stats/dashboard',
        method: 'get'
    })
}

// 获取趋势数据
export function getTrend(days) {
    return request({
        url: '/gee/stats/trend',
        method: 'get',
        params: { days }
    })
}

// 获取性能数据
export function getPerformance() {
    return request({
        url: '/gee/stats/performance',
        method: 'get'
    })
}
