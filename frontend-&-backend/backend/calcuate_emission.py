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

DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_HOST = os.environ.get("DB_HOST")


def get_emission_info(conn, vehicle, fuel_type):
    try:
        cursor = conn.cursor()
        query = '''
        SELECT fuel_consumption, emission_factor
        FROM emission_info
        WHERE vehicle = %s AND fuel = %s
        '''
        cursor.execute(query, (vehicle, fuel_type))
        data = cursor.fetchone()
        if data:
            print(data)
            return {
                'fuel_consumption': data[0],
                'emission_factor': data[1]
            }
        else:
            return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Implement your actual calculation logic here
def cal_emission(distance, distance_unit, passengers, fuel, vehicle, conn):
    emission_info = get_emission_info(conn, vehicle, fuel)

    if emission_info:
        fuel_consumption = emission_info['fuel_consumption']
        emission_factor = emission_info['emission_factor']
        # Convert distance to kilometers if it's not in kilometers
        if distance_unit == 'miles':
            distance *= 1.60934
        
        # Calculate carbon emissions
        carbon_emission = (distance * fuel_consumption / 100) / passengers * emission_factor
        rounded_emission = round(carbon_emission, 2)
        return rounded_emission
    else:
        return None
    

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        distance = body.get('distance')
        distance_unit = body.get('distanceUnit')
        passengers = body.get('numberOfPassengers')
        fuel = body.get('fuelType')
        selected_vehicle = body.get('active_tab')
    except KeyError:
        return {
            'statusCode': 400,
            'body': json.dumps({'message': 'Invalid input data'})
        }

    conn = None
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
        )
        
        user_emission = cal_emission(distance, distance_unit, passengers, fuel, selected_vehicle, conn)
        print("printing....")
        print(user_emission)
        emissions = {}
        suggestions = []
        cursor = conn.cursor()
        query = '''
        SELECT vehicle, fuel, max_passengers
        FROM emission_info
        '''
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            vehicle = row[0]
            fuel2 = row[1]
            max_passengers = row[2]
            print(vehicle)
            print(fuel2)
            print(max_passengers)
            if passengers > max_passengers:
                continue
            
            carbon_emission = cal_emission(distance, distance_unit, passengers, fuel2, vehicle, conn)
            print(carbon_emission)
            if vehicle == selected_vehicle and fuel == fuel2:
                emissions['selected_vehicle'] = {
                    'vehicle': vehicle,
                    'fuel': fuel,
                    'carbon_emission': carbon_emission
                }
            if carbon_emission < user_emission:
                suggestions.append({
                    'vehicle': vehicle,
                    'fuel': fuel2,
                    'carbon_emission': carbon_emission
                })
        result = {
            'emissions': emissions,
            'suggestions': suggestions
        }
        
        if conn:
            conn.close()
            
        r = json.dumps(result)
        return {
            'statusCode': 200,
            'body': r
        }
    except Exception as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'message': 'Hi'})
        }
