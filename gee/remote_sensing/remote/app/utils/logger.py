"""日志工具"""
import logging
import sys
from datetime import datetime

# 创建日志格式
LOG_FORMAT = '%(asctime)s | %(levelname)-8s | %(name)-20s | %(message)s'
DATE_FORMAT = '%Y-%m-%d %H:%M:%S'

# 配置根日志
logging.basicConfig(
    level=logging.INFO,
    format=LOG_FORMAT,
    datefmt=DATE_FORMAT,
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)

def get_logger(name: str) -> logging.Logger:
    """获取日志记录器"""
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)  # 设置为 DEBUG 级别
    return logger


# 预定义的日志记录器
api_logger = get_logger('API')
celery_logger = get_logger('CELERY')
gee_logger = get_logger('GEE')
data_logger = get_logger('DATA')
predict_logger = get_logger('PREDICT')

