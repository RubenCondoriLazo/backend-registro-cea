from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)

# Database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'onlinestore_db'
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username = %s AND password = %s", (username, password))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user:
        return jsonify({'success': True, 'user': user})
    return jsonify({'success': False, 'message': 'Credenciales incorrectas'})

@app.route('/api/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM products")
    products = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(products)

@app.route('/api/products', methods=['POST'])
def add_product():
    data = request.json
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO products (name, description, price, stock, seller_id, image_url)
        VALUES (%s, %s, %s, %s, %s, %s)
    """, (data['name'], data['description'], data['price'], data['stock'], data['seller_id'], data['image_url']))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'success': True})

@app.route('/api/orders', methods=['POST'])
def place_order():
    data = request.json
    # data: buyer_id, total, items: [{product_id, quantity, price}]
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("INSERT INTO orders (buyer_id, total) VALUES (%s, %s)", (data['buyer_id'], data['total']))
    order_id = cursor.lastrowid
    
    for item in data['items']:
        cursor.execute("INSERT INTO order_items (order_id, product_id, quantity, price) VALUES (%s, %s, %s, %s)",
                       (order_id, item['product_id'], item['quantity'], item['price']))
        # Update stock
        cursor.execute("UPDATE products SET stock = stock - %s WHERE id = %s", (item['quantity'], item['product_id']))
        
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'success': True, 'order_id': order_id})

@app.route('/api/stats/admin', methods=['GET'])
def get_admin_stats():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT COUNT(*) as total_sales FROM orders")
    total_sales = cursor.fetchone()['total_sales']
    cursor.execute("SELECT SUM(total) as total_revenue FROM orders")
    total_revenue = cursor.fetchone()['total_revenue']
    cursor.close()
    conn.close()
    return jsonify({'total_sales': total_sales, 'total_revenue': total_revenue})

if __name__ == '__main__':
    app.run(debug=True, port=5001)
