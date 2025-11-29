import sqlite3
import csv

# 1. Setup Database
conn = sqlite3.connect('geonames.db')
cursor = conn.cursor()

cursor.execute('''
CREATE TABLE cities (
    name TEXT,
    country TEXT,
    lat REAL,
    lng REAL
)
''')

# 2. Read the Text File and Insert
print("Reading cities15000.txt...")
count = 0
with open('cities15000.txt', 'r', encoding='utf-8') as f:
    reader = csv.reader(f, delimiter='\t')
    for row in reader:
        # GeoNames Format: 
        # [0]id, [1]name, [2]ascii, [3]alt_names, [4]lat, [5]lng, ... [8]country_code
        name = row[1]
        lat = float(row[4])
        lng = float(row[5])
        country = row[8] # Country Code (e.g., US, GB)

        cursor.execute('INSERT INTO cities VALUES (?, ?, ?, ?)', (name, country, lat, lng))
        count += 1

# 3. Optimize (Create Index for Speed)
print("Indexing...")
cursor.execute('CREATE INDEX idx_lat_lng ON cities (lat, lng)')

conn.commit()
conn.close()
print(f"Done! Created geonames.db with {count} cities.")