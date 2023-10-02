import subprocess
import sys

# Install psycopg2-binary using pip and specify the target directory (/tmp/)
subprocess.call(
    "pip install psycopg2-binary flask -t /tmp/ --no-cache-dir".split(),
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)

# Add the target directory (/tmp/) to sys.path
sys.path.insert(0, "/tmp/")
from flask import Flask, request, jsonify
import os
import json
import psycopg2

DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]
DB_HOST = os.environ["DB_HOST"]
# userpool = os.environ.get("userpool")
# clientid = os.environ.get("clientid")


def create_tables():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        cursor = conn.cursor()

        # Create the "emission_info" table
        create_table_query = '''
        CREATE TABLE IF NOT EXISTS emission_info (
            id SERIAL PRIMARY KEY,
            vehicle VARCHAR(255),
            fuel_consumption FLOAT,
            emission_factor FLOAT,
            fuel VARCHAR(255),
            max_passengers INT
        )
        '''
        cursor.execute(create_table_query)
        conn.commit()

        cursor.execute('''
        CREATE TABLE IF NOT EXISTS progress_tracker (
            id SERIAL PRIMARY KEY,
            original_emission FLOAT,
            plan_used FLOAT,
            reduction_observed FLOAT,
            email VARCHAR(255),
            date DATE
        )
        ''')
        conn.commit()

        # Insert standard values into the table
        # Check if the table is empty
        cursor.execute("SELECT COUNT(*) FROM emission_info")
        row_count = cursor.fetchone()[0]

        # If the table is empty (row_count is 0), then add data
        if row_count == 0:
            insert_query = '''
            INSERT INTO emission_info (vehicle, fuel_consumption, emission_factor, fuel, max_passengers)
            VALUES
                ('Car', 6.67, 2.3, 'Petroleum', 4),
                ('Car', 5.6, 2.1, 'Gasoline', 4),
                ('Bus', 25, 3.0, 'Diesel', 60),
                ('Shuttle', 8.33, 2.68, 'Diesel', 30),
                ('Shuttle', 30, 2.31, 'Gasoline', 30)
            '''
            cursor.execute(insert_query)
            conn.commit()
        
        cursor.close()
        conn.close()
        return 'Table created and populated with standard values'
    except Exception as e:
        return str(e)


def lambda_handler(event, context):
    try:
        res = create_tables()  # Replace with your actual function call
        response = json.dumps(res)
    except Exception as e:
        # If there's an error, construct an error response with the error message
        response = {
            "statusCode": 500,  # HTTP status code for an internal server error
            "body": json.dumps({"error": str(e)}),
           
        }
    
    return response