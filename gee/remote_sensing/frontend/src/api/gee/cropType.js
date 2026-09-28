import request from '@/utils/request'

// 获取作物类型列表
export function getCropTypes(status = '0') {
    return request({
        url: '/gee/crop-types/list',
        method: 'get',
        params: { status }
    })
}

// 获取作物类型详情
export function getCropTypeDetail(cropCode) {
    return request({
        url: `/gee/crop-types/${cropCode}`,
        method: 'get'
    })
}

// 获取作物类型名称（辅助函数）
export function getCropTypeName(cropCode, cropTypes) {
    if (!cropCode || !cropTypes) return cropCode
    const crop = cropTypes.find(c => c.cropCode === cropCode)
    return crop ? crop.cropName : cropCode
}
