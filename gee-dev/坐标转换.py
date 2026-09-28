import psycopg2
import psycopg2.extras
import json

# PostgreSQL 数据库连接配置
DB_CONFIG = {
    'host': '<REDACTED_DB_HOST>',
    'port': 5433,
    'database': 'szhy',
    'user': 'postgres',
    'password': '<REDACTED_DB_PASSWORD>',


}

# 配置信息
DB_SCHEMA = 'smart-plant'
TABLE_NAME = 'land_parcel_info'
ID_COLUMN = 'id'


def convert_coords_format(coord_str):
    """
    将 "84.467191,44.999417;..." 格式转换为
    [{"lng": 84.467191, "lat": 44.999417}, ...]
    """
    if not coord_str or not isinstance(coord_str, str):
        return []

    result_list = []
    points = coord_str.strip().split(';')

    for point in points:
        if point and ',' in point:
            try:
                lng, lat = point.split(',')
                result_list.append({
                    "lng": float(lng),
                    "lat": float(lat)
                })
            except ValueError:
                continue

    return result_list


def main():
    conn = None
    read_cur = None
    write_cur = None

    try:
        conn = psycopg2.connect(**DB_CONFIG)

        # --- 修改 1: 创建两个游标 ---
        # read_cur: 专门用来查询数据
        read_cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        # write_cur: 专门用来执行更新操作
        write_cur = conn.cursor()

        sql = f'SELECT {ID_COLUMN}, boundary_coordinates FROM "{DB_SCHEMA}"."{TABLE_NAME}" LIMIT 100000000;'
        print(f"正在执行: {sql}")

        # 使用 read_cur 查询
        read_cur.execute(sql)

        success_count = 0

        # 遍历 read_cur
        for row in read_cur:
            original_data = row['boundary_coordinates']
            record_id = row[ID_COLUMN]

            converted_data = convert_coords_format(original_data)

            if converted_data:
                success_count += 1
                json_output = json.dumps(converted_data, ensure_ascii=False)

                print("-" * 50)
                print(f"ID: {record_id}")
                # print(f"转换结果: {json_output}")

                # --- 修改 2: 使用 write_cur 进行更新 ---
                update_sql = f'UPDATE "{DB_SCHEMA}"."{TABLE_NAME}" SET boundary_coordinates = %s WHERE {ID_COLUMN} = %s'
                write_cur.execute(update_sql, (json_output, record_id))

                if success_count % 1000 == 0:
                    conn.commit()
                    print(f"--- 已提交 {success_count} 条数据 ---")

        # 循环结束后提交剩余事务
        conn.commit()

        print("=" * 50)
        print(f"处理完成，共成功转换 {success_count} 条数据。")

    except Exception as e:
        print(f"发生错误: {e}")
        # 如果出错回滚
        if conn: conn.rollback()
    finally:
        # 关闭游标和连接
        if read_cur: read_cur.close()
        if write_cur: write_cur.close()
        if conn:
            conn.close()
            print("数据库连接已关闭")


if __name__ == '__main__':
    main()
