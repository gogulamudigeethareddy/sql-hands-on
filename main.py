import psycopg2
import pandas as pd
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Define your connection parameters
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

# Create a cursor
cur = conn.cursor()

# Execute a sample query
cur.execute("SELECT version();")

# Fetch and print result
db_version = cur.fetchone()
print("PostgreSQL version:", db_version)

# Close cursor and connection
cur.close()
conn.close()


# Create a cursor
cur = conn.cursor()

# Load the CSV file into a DataFrame
data = pd.read_csv('/Users/geethareddy/Downloads/acbb2271e66c10a5b73aacf82ca82784-e38afe62e088394d61ed30884dd50a6826eee0a8/employees.csv')

# Define the table name
table_name = "employees"

# Get column names and data types from the DataFrame
columns = list(data.columns)
data_types = {
    "int64": "INTEGER",
    "float64": "REAL",
    "object": "TEXT"
}
column_definitions = ", ".join([f"{col} {data_types[str(data[col].dtype)]}" for col in columns])

# Create the table if it doesn't exist
create_table_query = f"CREATE TABLE IF NOT EXISTS {table_name} ({column_definitions});"
cur.execute(create_table_query)
print(f"Table '{table_name}' created successfully.")

# Iterate over the DataFrame and insert data into the table
for index, row in data.iterrows():
    cur.execute(
        f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({', '.join(['%s'] * len(columns))})",
        tuple(row)
    )
    print(f"Inserted row {index + 1} into {table_name}")

# Commit the transaction
conn.commit()

# Close cursor and connection
cur.close()
conn.close()

print("Data loaded successfully into the database.")
