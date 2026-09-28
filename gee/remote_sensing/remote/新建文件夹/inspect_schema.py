import psycopg2
import os

conn = psycopg2.connect(
    host=os.getenv('DB_HOST', '<REDACTED_DB_HOST>'),
    port=int(os.getenv('DB_PORT', 5433)),
    user=os.getenv('DB_USER', 'postgres'),
    password=os.getenv('DB_PASSWORD', '<REDACTED_DB_PASSWORD>'),
    database=os.getenv('DB_DATABASE', 'remote_sensing')
)

cursor = conn.cursor()
cursor.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'gee_tasks'")
columns = cursor.fetchall()
for col in columns:
    print(f"{col[0]}: {col[1]}")

conn.close()
