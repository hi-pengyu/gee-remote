import request from '@/utils/request'

// 获取作物类型列表
export function getCropTypes() {
    return request({
        url: '/gee/crop/types',
        method: 'get'
    })
}

// 作物类型选项（前端使用）
export const cropTypeOptions = [
    { label: '玉米', value: 'corn', period: '04-01 ~ 09-30' },
    { label: '水稻', value: 'rice', period: '05-01 ~ 10-31' },
    { label: '小麦', value: 'wheat', period: '10-01 ~ 06-30' },
    { label: '大豆', value: 'soybean', period: '05-01 ~ 09-30' },
    { label: '棉花', value: 'cotton', period: '04-01 ~ 10-31' }
]
