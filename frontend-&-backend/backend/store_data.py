import subprocess
import sys

# Install psycopg2-binary using pip and specify the target directory (/tmp/)
subprocess.call(
    "pip install psycopg2-binary flask datetime -t /tmp/ --no-cache-dir".split(),
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL,
)

# Add the target directory (/tmp/) to sys.path
sys.path.insert(0, "/tmp/")
from flask import Flask, request, jsonify
from datetime import date
import os
import json
import psycopg2


DB_NAME = "postgres"
DB_USER = "postgres"
DB_PASSWORD = "postgres"
DB_HOST = os.environ["DB_HOST"]

def store_data_handler(event, context):
    try:
        data = json.loads(event['body'])
        plan = data['suggestions']['carbon_emission'] if data['suggestions'] else None
        original = data['emissions']['carbon_emission']
        user_email = data.get('email')
        conn = None
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
        )

        if plan is None:
            reduction = 0
        else:
            reduction = original - plan
        
        current_date = date.today()
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO progress_tracker (original_emission, plan_used, reduction_observed, email, date)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id
        ''', (original, plan, reduction, user_email, current_date))
        conn.commit()
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Success'})
        }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Hi'})
        }