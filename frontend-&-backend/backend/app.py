from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
from datetime import date
import os
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)
load_dotenv()

DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_HOST = os.environ.get("DB_HOST")
DB_PORT = os.environ.get("DB_PORT")


def create_table_and_populate():

    # Connect to the PostgreSQL database
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
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
    return 'Table created and populated with standard values'

create_table_and_populate()


def get_emission_info(vehicle, fuel_type):
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        cursor = conn.cursor()

        query = '''
        SELECT fuel_consumption, emission_factor
        FROM emission_info
        WHERE vehicle = %s AND fuel= %s
        '''
        cursor.execute(query, (vehicle, fuel_type))
        data = cursor.fetchone()

        cursor.close()
        conn.close()

        if data:
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
def cal_emission(distance, distance_unit, passengers, fuel, vehicle):
    emission_info = get_emission_info(vehicle, fuel)

    if emission_info:
        fuel_consumption = emission_info['fuel_consumption']
        emission_factor = emission_info['emission_factor']

        # Convert distance to kilometers if it's not in kilometers
        if distance_unit == 'miles':
            distance *= 1.60934

        # Calculate carbon emissions
        print(distance)
        print(fuel_consumption)
        print(emission_factor)
        print(passengers)
        carbon_emission = (distance * fuel_consumption/100)/passengers * emission_factor
        # carbon_emission = distance * emission_factor * passengers
        rounded_emission = round(carbon_emission, 2)
        return rounded_emission
    else:
        return None

# ... (Previous code)


@app.route('/calculate', methods=['POST'])
def get_data():
    data = request.json  # Get JSON data from the POST request
    distance = data.get('distance')
    distance_unit = data.get('distanceUnit')
    passengers = data.get('numberOfPassengers')
    fuel = data.get('fuelType')
    active_tab = data.get('active_tab')

    if active_tab == 'ex2-tabs-1':
        selected_vehicle = 'Car'
    elif active_tab == 'ex2-tabs-2':
        selected_vehicle = 'Bus'
    elif active_tab == 'ex2-tabs-3':
        selected_vehicle = 'Shuttle'
    else:
        selected_vehicle = 'Unknown'

    user_emission = cal_emission(distance, distance_unit, passengers, fuel, selected_vehicle)
    # Calculate carbon emissions for all vehicles
    emissions = {}
    suggestions = []

    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )
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

        # Check if passenger count is within the allowed range
        if passengers > max_passengers:
            continue

        carbon_emission = cal_emission(distance, distance_unit, passengers, fuel2, vehicle)
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

    cursor.close()
    conn.close()

    # Return the results as JSON
    result = {
        'emissions': emissions,
        'suggestions': suggestions
    }

    return jsonify(result)


@app.route('/store_data', methods=['POST'])
def receive_selected_plan():
    try:
        data = request.get_json()
        print("Received data from the frontend:")
        print(data)
             
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        cursor = conn.cursor()

        plan = data['suggestions']['carbon_emission'] if data['suggestions'] else None
        original = data['emissions']['carbon_emission']
        if plan is None:
            reduction = 0
        else:
            reduction = original - plan
        user_email = 'sanarahman930@gmail.com'
        current_date = date.today()
        # Save data to progress_tracker table
        cursor.execute('''
            INSERT INTO progress_tracker (original_emission, plan_used, reduction_observed, email, date)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id
        ''', (original, plan, reduction, user_email, current_date))
        conn.commit()

        return jsonify({'message': 'Success'}), 200
    except Exception as e:
        print(e)
        return jsonify({'error': str(e)}), 400


@app.route('/get_progress_data', methods=['GET'])
def get_progress_data():
    try:
        email = request.args.get('email')  # Get the email parameter from the request
        # Query the progress_tracker table to fetch data by email
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        cursor = conn.cursor()

        cursor.execute('''
            SELECT id, original_emission, plan_used, reduction_observed, date
            FROM progress_tracker
            WHERE email = %s
        ''', (email,))
        progress_data = cursor.fetchall()  # Fetch all matching records

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
        # print("pROCESS DATA"+progress_data_list)
        return jsonify(progress_data_list), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 400


if __name__ == '__main__':
    app.run(debug=True)
