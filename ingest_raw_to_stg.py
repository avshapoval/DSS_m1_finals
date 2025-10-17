import csv
import os
import psycopg2
from psycopg2.extras import execute_batch
from dotenv import load_dotenv

load_dotenv()

CONN_PARAMS = {
    'host': os.getenv('GP_HOST'),
    'port': int(os.getenv('GP_PORT', 6432)),
    'database': os.getenv('GP_DATABASE'),
    'user': os.getenv('GP_USER'),
    'password': os.getenv('GP_PASSWORD'),
    'sslmode': os.getenv('GP_SSL_MODE', 'verify-full'),
    'sslrootcert': os.getenv('GP_SSL_ROOT_CERT')
}

CSV_PATH = os.getenv('CSV_PATH', 'SampleSuperstore.csv')
SCHEMA = os.getenv('GP_SCHEMA', 'student51')
TABLE = os.getenv('STG_TABLE', 'stg_sample_superstore')

def load_csv_to_greenplum():
    conn = psycopg2.connect(**CONN_PARAMS)
    cursor = conn.cursor()
    cursor.execute(f'TRUNCATE TABLE {SCHEMA}.{TABLE};')
    
    insert_sql = f"""
    INSERT INTO {SCHEMA}.{TABLE} (
        ship_mode, segment, country, city, state, postal_code, region,
        category, sub_category, sales, quantity, discount, profit
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    rows = []
    with open(CSV_PATH, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append((
                row['Ship Mode'], row['Segment'], row['Country'], row['City'],
                row['State'], row['Postal Code'], row['Region'], row['Category'],
                row['Sub-Category'],
                float(row['Sales']) if row['Sales'] else None,
                int(row['Quantity']) if row['Quantity'] else None,
                float(row['Discount']) if row['Discount'] else None,
                float(row['Profit']) if row['Profit'] else None
            ))
    
    execute_batch(cursor, insert_sql, rows, page_size=500)
    conn.commit()
    cursor.close()
    conn.close()
    print(f"Загружено {len(rows)} строк в {SCHEMA}.{TABLE}")


load_csv_to_greenplum()