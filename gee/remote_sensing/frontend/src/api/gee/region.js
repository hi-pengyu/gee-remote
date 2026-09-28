import request from '@/utils/request'

// 暂停行政区监测
export function pauseRegion(data) {
    return request({
        url: '/gee/region/pause',
        method: 'post',
        data: data
    })
}

// 恢复行政区监测
export function resumeRegion(adcode) {
    return request({
        url: '/gee/region/resume',
        method: 'post',
        data: {
            adcode: adcode
        }
    })
}

// 获取暂停的行政区列表
export function getPausedRegions() {
    return request({
        url: '/gee/region/paused-list',
        method: 'get'
    })
}

// 获取行政区地块统计
export function getRegionStats(adcode) {
    return request({
        url: '/gee/region/stats/' + adcode,
        method: 'get'
    })
}
