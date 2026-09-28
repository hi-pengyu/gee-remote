"""行政区管控策略服务"""
import psycopg2
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor
from typing import Dict, List, Optional
from config.env import DataBaseConfig
from utils.log_util import logger


class RegionPolicyService:
    """行政区管控策略服务"""
    
    _pool = None
    
    def __init__(self):
        """初始化服务"""
        if RegionPolicyService._pool is None:
            db_config = DataBaseConfig
            RegionPolicyService._pool = SimpleConnectionPool(
                minconn=1,
                maxconn=10,
                host=db_config.db_host,
                port=db_config.db_port,
                user=db_config.db_username,
                password=db_config.db_password,
                database=db_config.db_database
            )
    
    def _get_connection(self):
        """获取连接"""
        return RegionPolicyService._pool.getconn()
    
    def _put_connection(self, conn):
        """归还连接"""
        RegionPolicyService._pool.putconn(conn)
    
    def pause_region(self, adcode: str, reason: str, operator: str) -> Dict:
        """
        暂停某个行政区的所有地块监测
        
        Args:
            adcode: 行政区代码（支持前缀，如 41 代表河南省）
            reason: 暂停原因
            operator: 操作人
            
        Returns:
            {'success': bool, 'affected_plots': int}
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 1. 添加管控策略
            cursor.execute('''
                INSERT INTO gee_region_policies 
                (adcode, policy_type, reason, created_by, is_active)
                VALUES (%s, 'pause', %s, %s, TRUE)
                ON CONFLICT (adcode) 
                DO UPDATE SET 
                    reason = EXCLUDED.reason,
                    is_active = TRUE,
                    updated_at = CURRENT_TIMESTAMP
            ''', (adcode, reason, operator))
            
            # 2. 调用存储过程批量更新地块状态
            cursor.execute('SELECT * FROM pause_region_plots(%s, %s, %s)', 
                          (adcode, reason, operator))
            result = cursor.fetchone()
            affected_count = result[0] if result else 0
            
            conn.commit()
            cursor.close()
            
            logger.info(f"已暂停行政区 {adcode}，影响 {affected_count} 个地块")
            
            return {
                'success': True,
                'affected_plots': affected_count,
                'adcode': adcode,
                'reason': reason
            }
            
        except Exception as e:
            conn.rollback()
            logger.error(f"暂停区域失败: {e}")
            return {
                'success': False,
                'error': str(e)
            }
        finally:
            self._put_connection(conn)
    
    def resume_region(self, adcode: str, operator: str) -> Dict:
        """
        恢复某个行政区的监测
        
        Args:
            adcode: 行政区代码
            operator: 操作人
            
        Returns:
            {'success': bool, 'affected_plots': int}
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            
            # 1. 删除或禁用管控策略
            cursor.execute('''
                UPDATE gee_region_policies 
                SET is_active = FALSE,
                    updated_at = CURRENT_TIMESTAMP
                WHERE adcode = %s
            ''', (adcode,))
            
            # 2. 调用存储过程恢复地块状态
            cursor.execute('SELECT * FROM resume_region_plots(%s, %s)', 
                          (adcode, operator))
            result = cursor.fetchone()
            affected_count = result[0] if result else 0
            
            conn.commit()
            cursor.close()
            
            logger.info(f"已恢复行政区 {adcode}，影响 {affected_count} 个地块")
            
            return {
                'success': True,
                'affected_plots': affected_count,
                'adcode': adcode
            }
            
        except Exception as e:
            conn.rollback()
            logger.error(f"恢复区域失败: {e}")
            return {
                'success': False,
                'error': str(e)
            }
        finally:
            self._put_connection(conn)
    
    def get_paused_regions(self) -> List[Dict]:
        """获取所有暂停的行政区列表"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            cursor.execute('''
                SELECT 
                    policy_id,
                    adcode,
                    reason,
                    created_by,
                    created_at,
                    updated_at
                FROM gee_region_policies
                WHERE policy_type = 'pause' AND is_active = TRUE
                ORDER BY created_at DESC
            ''')
            
            rows = cursor.fetchall()
            cursor.close()
            
            # 转换为驼峰命名
            result = []
            for row in rows:
                result.append({
                    'policyId': row['policy_id'],
                    'adcode': row['adcode'],
                    'reason': row['reason'],
                    'createdBy': row['created_by'],
                    'createdAt': row['created_at'].isoformat() if row['created_at'] else None,
                    'updatedAt': row['updated_at'].isoformat() if row['updated_at'] else None
                })
            
            return result
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    def get_paused_adcodes(self) -> List[str]:
        """获取所有暂停的行政区代码列表（用于过滤）"""
        conn = self._get_connection()
        try:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT adcode 
                FROM gee_region_policies
                WHERE policy_type = 'pause' AND is_active = TRUE
            ''')
            
            rows = cursor.fetchall()
            cursor.close()
            
            return [row[0] for row in rows]
            
        finally:
            cursor.close()
            self._put_connection(conn)
    
    @staticmethod
    def is_region_paused(adcode: str, paused_adcodes: List[str]) -> bool:
        """
        检查行政区是否被暂停（支持前缀匹配）
        
        Args:
            adcode: 要检查的行政区代码
            paused_adcodes: 暂停的行政区代码列表
            
        Returns:
            True if paused, False otherwise
            
        Example:
            410000 暂停，则 410100、410200 都会被暂停
        """
        if not adcode:
            return False
        
        for paused in paused_adcodes:
            if adcode.startswith(paused):
                return True
        
        return False
    
    def get_region_stats(self, adcode: str) -> Dict:
        """
        获取某个行政区的地块统计信息
        
        Args:
            adcode: 行政区代码
            
        Returns:
            统计信息
        """
        conn = self._get_connection()
        try:
            cursor = conn.cursor(cursor_factory=RealDictCursor)
            
            cursor.execute('''
                SELECT 
                    COUNT(*) as total_plots,
                    SUM(CASE WHEN monitor_status = 1 THEN 1 ELSE 0 END) as active_plots,
                    SUM(CASE WHEN monitor_status = 0 THEN 1 ELSE 0 END) as paused_plots,
                    SUM(CASE WHEN auto_update = TRUE THEN 1 ELSE 0 END) as auto_update_plots
                FROM gee_plots
                WHERE adcode LIKE %s || '%%'
            ''', (adcode,))
            
            result = cursor.fetchone()
            cursor.close()
            
            return {
                'adcode': adcode,
                'totalPlots': result['total_plots'] or 0,
                'activePlots': result['active_plots'] or 0,
                'pausedPlots': result['paused_plots'] or 0,
                'autoUpdatePlots': result['auto_update_plots'] or 0
            }
            
        finally:
            cursor.close()
            self._put_connection(conn)


# 创建单例实例
region_policy_service = RegionPolicyService()
