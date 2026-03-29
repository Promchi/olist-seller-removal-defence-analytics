import psycopg2

def get_connection():
    conn = psycopg2.connect(
        host="localhost",
        database="OList",
        user="postgres",
        password="chiemela",
        port="5432"
    )
    return conn

# Test the connection
if __name__ == "__main__":
    try:
        conn = get_connection()
        print("Connection successful!")
        conn.close()
    except Exception as e:
        print(f"Connection failed: {e}")