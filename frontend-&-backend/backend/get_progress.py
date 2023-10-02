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

DB_NAME = "postgres"
DB_USER =  "postgres"
DB_PASSWORD = "postgres"
DB_HOST = os.environ["DB_HOST"]


def get_progress_handler(event, context):
    try:
        # Extract the email parameter from the event
        email = event.get('queryStringParameters', {}).get('email')
        
        if not email:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Email parameter is missing'})
            }
        

        # Query the progress_tracker table to fetch data by email
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        cursor = conn.cursor()
        
    
        cursor.execute('''
            SELECT id, original_emission, plan_used, reduction_observed, date
            FROM progress_tracker
            WHERE email = %s
        ''', (email,))
        progress_data = cursor.fetchall()  # Fetch all matching records
        print(progress_data)
        # Convert the progress_data to a list of dictionaries
        
        progress_data_list = [
            {
                'id': row[0],
                'originalEmission': row[1],
                'newEmission': row[2],
                'reduction': row[3],
                'date': row[4].strftime('%Y-%m-%d') if row[4] else None,
            }
            for row in progress_data
        ]
        
        d = json.dumps(progress_data_list)
        return {
            'statusCode': 200,
            'body': d
        }
    except Exception as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': str(e)})
        }