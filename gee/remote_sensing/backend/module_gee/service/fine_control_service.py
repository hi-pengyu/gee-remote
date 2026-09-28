"""
精细化管控服务

支持多维度的地块管控：
1. 按行政区 + 作物类型
2. 按自定义区域 + 作物类型
3. 按单个地块 + 作物类型
"""

from typing import List, Optional, Dict, Any
from psycopg2.pool import SimpleConnectionPool
from config.env import DataBaseConfig
import json


class FineControlService:
    """精细化管控服务"""
    
    def __init__(self):
        """初始化数据库连接池"""
        self.pool = SimpleConnectionPool(
            1, 10,
            host=DataBaseConfig.db_host,
            port=DataBaseConfig.db_port,
            user=DataBaseConfig.db_username,
            password=DataBaseConfig.db_password,
            database=DataBaseConfig.db_database
        )
    
    def create_control_policy(
        self,
        policy_name: str,
        policy_type: str,
        control_action: str,
        adcode: Optional[str] = None,
        custom_geometry: Optional[str] = None,
        plot_id: Optional[int] = None,
        crop_codes: Optional[List[str]] = None,
        reason: Optional[str] = None,
        priority: int = 0,
        created_by: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        创建管控策略
        
        Args:
            policy_name: 策略名称
            policy_type: 策略类型 (admin_region/custom_region/single_plot)
            control_action: 控制动作 (pause/resume)
            adcode: 行政区代码
            custom_geometry: 自定义区域几何
            plot_id: 地块ID
            crop_codes: 作物代码列表
            reason: 原因
            priority: 优先级
            created_by: 创建人
            
        Returns:
            创建的策略信息
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            # 获取行政区名称
            region_name = None
            if adcode:
                cursor.execute(
                    "SELECT name FROM china_administrative_divisions WHERE adcode = %s",
                    (adcode,)
                )
                result = cursor.fetchone()
                if result:
                    region_name = result[0]
            
            # 预览影响范围
            affected_plots = self._get_affected_plots(
                cursor, policy_type, adcode, custom_geometry, plot_id, crop_codes
            )
            
            # 打印调试日志
            print(f"🛠️ 创建策略: {policy_name}, 类型: {policy_type}, 动作: {control_action}")
            print(f"   参数: adcode={adcode}, plot_id={plot_id}, custom_geometry={bool(custom_geometry)}")
            
            # 插入策略
            sql = """
                INSERT INTO gee_control_policies (
                    policy_name, policy_type, adcode, region_name,
                    custom_geometry, plot_id, crop_codes,
                    control_action, reason, priority, created_by
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING policy_id, created_at
            """
            
            cursor.execute(sql, (
                policy_name, policy_type, adcode, region_name,
                custom_geometry, plot_id, crop_codes,
                control_action, reason, priority, created_by
            ))
            
            policy_id, created_at = cursor.fetchone()
            conn.commit()
            print(f"✅ 策略创建成功: ID={policy_id}")
            cursor.close()
            
            return {
                'policyId': policy_id,
                'policyName': policy_name,
                'policyType': policy_type,
                'controlAction': control_action,
                'affectedPlots': len(affected_plots),
                'createdAt': created_at.isoformat() if created_at else None
            }
            
        finally:
            self.pool.putconn(conn)
    
    def preview_impact(
        self,
        policy_type: str,
        adcode: Optional[str] = None,
        custom_geometry: Optional[str] = None,
        plot_id: Optional[int] = None,
        crop_codes: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        预览管控影响范围
        
        Args:
            policy_type: 策略类型
            adcode: 行政区代码
            custom_geometry: 自定义区域几何
            plot_id: 地块ID
            crop_codes: 作物代码列表
            
        Returns:
            影响统计信息
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            affected_plots = self._get_affected_plots(
                cursor, policy_type, adcode, custom_geometry, plot_id, crop_codes
            )
            
            cursor.close()
            
            # 统计
            total_plots = len(affected_plots)
            active_plots = sum(1 for p in affected_plots if p['monitorStatus'] == 1)
            paused_plots = sum(1 for p in affected_plots if p['monitorStatus'] == 0)
            
            # 按作物类型统计
            crop_stats = {}
            for plot in affected_plots:
                crop_type = plot['cropType'] or 'unknown'
                if crop_type not in crop_stats:
                    crop_stats[crop_type] = {'total': 0, 'active': 0, 'paused': 0}
                crop_stats[crop_type]['total'] += 1
                if plot['monitorStatus'] == 1:
                    crop_stats[crop_type]['active'] += 1
                else:
                    crop_stats[crop_type]['paused'] += 1
            
            return {
                'totalPlots': total_plots,
                'activePlots': active_plots,
                'pausedPlots': paused_plots,
                'cropStats': crop_stats,
                'plots': affected_plots[:100]  # 最多返回100个地块详情
            }
            
        finally:
            self.pool.putconn(conn)
    
    def _get_affected_plots(
        self,
        cursor,
        policy_type: str,
        adcode: Optional[str] = None,
        custom_geometry: Optional[str] = None,
        plot_id: Optional[int] = None,
        crop_codes: Optional[List[str]] = None
    ) -> List[Dict[str, Any]]:
        """获取受影响的地块列表"""
        
        conditions = []
        params = []
        
        if policy_type == 'admin_region' and adcode:
            conditions.append("adcode LIKE %s")
            params.append(f"{adcode}%")
        elif policy_type == 'single_plot' and plot_id:
            conditions.append("plot_id = %s")
            params.append(plot_id)
        elif policy_type == 'custom_region' and custom_geometry:
            conditions.append("ST_Intersects(geometry, ST_GeomFromGeoJSON(%s))")
            params.append(custom_geometry)
        
        if crop_codes:
            conditions.append("crop_type = ANY(%s)")
            params.append(crop_codes)
        
        where_clause = " AND ".join(conditions) if conditions else "1=1"
        
        sql = f"""
            SELECT 
                plot_id, plot_name, crop_type, monitor_status,
                province, city, district, adcode
            FROM gee_plots
            WHERE {where_clause}
            LIMIT 1000
        """
        
        cursor.execute(sql, params)
        
        plots = []
        for row in cursor.fetchall():
            plots.append({
                'plotId': row[0],
                'plotName': row[1],
                'cropType': row[2],
                'monitorStatus': row[3],
                'province': row[4],
                'city': row[5],
                'district': row[6],
                'adcode': row[7]
            })
        
        return plots
    
    def get_active_policies(
        self,
        policy_type: Optional[str] = None,
        is_active: Optional[bool] = None,
        page_num: int = 1,
        page_size: int = 20
    ) -> Dict[str, Any]:
        """
        获取管控策略列表
        
        Args:
            policy_type: 策略类型筛选
            is_active: 是否启用筛选
            page_num: 页码
            page_size: 每页数量
            
        Returns:
            策略列表
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            where_conditions = ["1=1"]
            params = []
            
            if policy_type:
                where_conditions.append("policy_type = %s")
                params.append(policy_type)
            
            if is_active is not None:
                where_conditions.append("is_active = %s")
                params.append(is_active)
            
            where_clause = "WHERE " + " AND ".join(where_conditions)
            
            # 查询总数
            count_sql = f"SELECT COUNT(*) FROM gee_control_policies {where_clause}"
            cursor.execute(count_sql, params)
            total = cursor.fetchone()[0]
            
            # 查询数据
            offset = (page_num - 1) * page_size
            data_sql = f"""
                SELECT 
                    policy_id, policy_name, policy_type, adcode, region_name,
                    plot_id, crop_codes, control_action, reason, priority,
                    created_by, created_at, is_active
                FROM gee_control_policies
                {where_clause}
                ORDER BY priority DESC, created_at DESC
                LIMIT %s OFFSET %s
            """
            cursor.execute(data_sql, params + [page_size, offset])
            
            rows = []
            for row in cursor.fetchall():
                rows.append({
                    'policyId': row[0],
                    'policyName': row[1],
                    'policyType': row[2],
                    'adcode': row[3],
                    'regionName': row[4],
                    'plotId': row[5],
                    'cropCodes': row[6],
                    'controlAction': row[7],
                    'reason': row[8],
                    'priority': row[9],
                    'createdBy': row[10],
                    'createdAt': row[11].isoformat() if row[11] else None,
                    'isActive': row[12]
                })
            
            cursor.close()
            
            return {
                'rows': rows,
                'total': total,
                'pageNum': page_num,
                'pageSize': page_size
            }
            
        finally:
            self.pool.putconn(conn)
    
    def delete_policy(self, policy_id: int) -> bool:
        """
        删除管控策略
        
        Args:
            policy_id: 策略ID
            
        Returns:
            是否成功
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            # 1. 先删除关联的日志（解决外键约束）
            # 注意：如果有其他表也引用了policy_id，也需要在这里处理
            log_sql = "DELETE FROM gee_control_logs WHERE policy_id = %s"
            cursor.execute(log_sql, (policy_id,))
            log_affected = cursor.rowcount
            print(f"🧹 清理关联日志: policy_id={policy_id}, 删除行数={log_affected}")
            
            # 2. 删除策略
            sql = "DELETE FROM gee_control_policies WHERE policy_id = %s"
            cursor.execute(sql, (policy_id,))
            
            affected = cursor.rowcount
            conn.commit()
            print(f"🗑️ 删除策略: ID={policy_id}, 影响行数={affected}")
            cursor.close()
            
            return affected > 0
            
        finally:
            self.pool.putconn(conn)
    
    def toggle_policy(self, policy_id: int, is_active: bool) -> bool:
        """
        启用/禁用策略
        
        Args:
            policy_id: 策略ID
            is_active: 是否启用
            
        Returns:
            是否成功
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            sql = "UPDATE gee_control_policies SET is_active = %s WHERE policy_id = %s"
            cursor.execute(sql, (is_active, policy_id))
            
            affected = cursor.rowcount
            conn.commit()
            cursor.close()
            
            return affected > 0
            
        finally:
            self.pool.putconn(conn)
    
    def get_plot_control_status(self, plot_id: int) -> Dict[str, Any]:
        """
        获取地块的管控状态
        
        Args:
            plot_id: 地块ID
            
        Returns:
            地块管控状态
        """
        conn = self.pool.getconn()
        try:
            cursor = conn.cursor()
            
            sql = """
                SELECT 
                    plot_id, plot_name, crop_type,
                    original_status, effective_status, applied_policy
                FROM v_plot_control_status
                WHERE plot_id = %s
            """
            cursor.execute(sql, (plot_id,))
            
            row = cursor.fetchone()
            cursor.close()
            
            if row:
                return {
                    'plotId': row[0],
                    'plotName': row[1],
                    'cropType': row[2],
                    'originalStatus': row[3],
                    'effectiveStatus': row[4],
                    'appliedPolicy': row[5]
                }
            return None
            
        finally:
            self.pool.putconn(conn)


# 创建全局服务实例
fine_control_service = FineControlService()
