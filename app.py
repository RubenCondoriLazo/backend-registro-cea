from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
import os

app = Flask(__name__)
CORS(app)

# Database configuration (Use environment variables for production)
db_config = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', ''),
    'database': os.environ.get('DB_NAME', 'cea_ruben_db'),
    'port': int(os.environ.get('DB_PORT', 3306))
}

def get_db_connection():
    try:
        return mysql.connector.connect(**db_config)
    except Exception as e:
        print(f"Error connecting to DB: {e}")
        return None

@app.route('/api/login', methods=['POST'])
def login():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    conn = get_db_connection()
    if not conn: return jsonify({'success': False, 'message': 'DB Error'})
    
    cursor = conn.cursor(dictionary=True)
    query = """
        SELECT u.*, r.name as role 
        FROM users u 
        JOIN roles r ON u.role_id = r.id 
        WHERE u.username = %s AND u.password = %s
    """
    cursor.execute(query, (username, password))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if user:
        return jsonify({'success': True, 'user': user})
    return jsonify({'success': False, 'message': 'Credenciales incorrectas'})

@app.route('/api/cea/modules', methods=['GET'])
def get_modules():
    area = request.args.get('area') # 'Humanistica' or 'Tecnica'
    level_id = request.args.get('level_id')
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if area == 'Humanistica':
        cursor.execute("SELECT * FROM modules WHERE subject_id IS NOT NULL")
    elif area == 'Tecnica':
        if level_id:
            cursor.execute("SELECT * FROM modules WHERE level_id = %s", (level_id,))
        else:
            cursor.execute("SELECT * FROM modules WHERE level_id IS NOT NULL")
    else:
        cursor.execute("SELECT * FROM modules")
        
    modules = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(modules)

@app.route('/api/cea/grades', methods=['POST'])
def post_grade():
    data = request.json
    # data: student_id, module_id, teacher_id, score
    score = int(data['score'])
    status = 'APROBADO' if score >= 51 else 'REPROBADO'
    
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO grades (student_id, module_id, teacher_id, score, status)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE score = VALUES(score), status = VALUES(status)
    """, (data['student_id'], data['module_id'], data['teacher_id'], score, status))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'success': True, 'status': status})

@app.route('/api/cea/grades', methods=['GET'])
def get_all_grades():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    query = """
        SELECT g.*, m.name as module_name, m.subject_id, m.level_id, u.full_name as student_name, u.rude_number
        FROM grades g
        JOIN modules m ON g.module_id = m.id
        JOIN users u ON g.student_id = u.id
    """
    cursor.execute(query)
    grades = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify(grades)

@app.route('/api/cea/centralizador', methods=['GET'])
def get_centralizador():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    # Get all students with their formal info
    cursor.execute("SELECT id, full_name, carnet, rude_number, gender, area_type FROM users WHERE role_id = 4")
    students = cursor.fetchall()
    
    # Get all grades for aggregation
    cursor.execute("""
        SELECT student_id, module_id, score, status 
        FROM grades
    """)
    all_grades = cursor.fetchall()
    
    # Organize report
    report = []
    for s in students:
        s_grades = [g for g in all_grades if g['student_id'] == s['id']]
        avg_score = sum(g['score'] for g in s_grades) / len(s_grades) if s_grades else 0
        report.append({
            'rude': s['rude_number'],
            'name': s['full_name'],
            'carnet': s['carnet'],
            'gender': s['gender'],
            'area': s['area_type'],
            'average': round(avg_score, 2),
            'modules_passed': len([g for g in s_grades if g['status'] == 'APROBADO']),
            'total_modules': len(s_grades)
        })
        
    cursor.close()
    conn.close()
    return jsonify(report)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
