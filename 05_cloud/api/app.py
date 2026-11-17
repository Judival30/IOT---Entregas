import os

import boto3
import psycopg2
import psycopg2.extras
from flask import Flask, jsonify, request
from werkzeug.utils import secure_filename

app = Flask(__name__)

s3 = boto3.client("s3", region_name=os.getenv("AWS_REGION", "us-east-1"))


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "db"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "equipment"),
        user=os.getenv("DB_USER", "equipment"),
        password=os.getenv("DB_PASSWORD", ""),
    )


def query(sql, params=None, one=False, commit=False):
    conn = get_connection()
    try:
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(sql, params)
            result = None
            if cur.description:
                result = cur.fetchone() if one else cur.fetchall()
        if commit:
            conn.commit()
        return result
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def employee_to_json(row):
    return {
        "id": row["id"],
        "nombre": row["name"],
        "correo": row["email"],
        "departamento": row["department"],
    }


def equipment_to_json(row):
    return {
        "id": row["id"],
        "codigo_interno": row["internal_code"],
        "tipo": row["type"],
        "marca": row["brand"],
        "modelo": row["model"],
        "numero_serie": row["serial_number"],
        "estado": row["status"],
        "fecha_adquisicion": str(row["acquisition_date"]) if row["acquisition_date"] else None,
        "empleado_id": row["employee_id"],
    }


def get_equipment(equipment_id):
    return query("SELECT * FROM equipment WHERE id = %s", (equipment_id,), one=True)


@app.errorhandler(psycopg2.errors.UniqueViolation)
def handle_unique(error):
    return jsonify({"error": "Ya existe un registro con esos datos unicos"}), 409


@app.errorhandler(psycopg2.Error)
def handle_db_error(error):
    return jsonify({"error": "Error en la base de datos"}), 500


@app.get("/health")
def health():
    db_status = "ok"
    try:
        query("SELECT 1")
    except Exception:
        db_status = "error"
    body = {
        "status": "ok" if db_status == "ok" else "error",
        "service": "equipment-api",
        "version": os.getenv("APP_VERSION", "1.0"),
        "database": db_status,
    }
    return jsonify(body), 200 if db_status == "ok" else 503


@app.get("/empleados")
def list_employees():
    rows = query("SELECT * FROM employees ORDER BY id")
    return jsonify([employee_to_json(r) for r in rows])


@app.post("/empleados")
def create_employee():
    data = request.get_json(silent=True) or {}
    if not data.get("nombre") or not data.get("correo"):
        return jsonify({"error": "nombre y correo son obligatorios"}), 400
    row = query(
        "INSERT INTO employees (name, email, department) VALUES (%s, %s, %s) RETURNING *",
        (data["nombre"], data["correo"], data.get("departamento")),
        one=True,
        commit=True,
    )
    return jsonify(employee_to_json(row)), 201


@app.get("/empleados/<int:employee_id>")
def get_employee(employee_id):
    row = query("SELECT * FROM employees WHERE id = %s", (employee_id,), one=True)
    if not row:
        return jsonify({"error": "Empleado no encontrado"}), 404
    return jsonify(employee_to_json(row))


@app.get("/equipos")
def list_equipment():
    rows = query("SELECT * FROM equipment ORDER BY id")
    return jsonify([equipment_to_json(r) for r in rows])


@app.post("/equipos")
def create_equipment():
    data = request.get_json(silent=True) or {}
    if not data.get("codigo_interno") or not data.get("tipo"):
        return jsonify({"error": "codigo_interno y tipo son obligatorios"}), 400
    row = query(
        "INSERT INTO equipment (internal_code, type, brand, model, serial_number, status, acquisition_date) "
        "VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING *",
        (
            data["codigo_interno"],
            data["tipo"],
            data.get("marca"),
            data.get("modelo"),
            data.get("numero_serie"),
            data.get("estado", "DISPONIBLE"),
            data.get("fecha_adquisicion"),
        ),
        one=True,
        commit=True,
    )
    return jsonify(equipment_to_json(row)), 201


@app.get("/equipos/<int:equipment_id>")
def get_equipment_by_id(equipment_id):
    row = get_equipment(equipment_id)
    if not row:
        return jsonify({"error": "Equipo no encontrado"}), 404
    return jsonify(equipment_to_json(row))


@app.put("/equipos/<int:equipment_id>")
def update_equipment(equipment_id):
    current = get_equipment(equipment_id)
    if not current:
        return jsonify({"error": "Equipo no encontrado"}), 404
    data = request.get_json(silent=True) or {}
    row = query(
        "UPDATE equipment SET internal_code = %s, type = %s, brand = %s, model = %s, "
        "serial_number = %s, status = %s, acquisition_date = %s WHERE id = %s RETURNING *",
        (
            data.get("codigo_interno", current["internal_code"]),
            data.get("tipo", current["type"]),
            data.get("marca", current["brand"]),
            data.get("modelo", current["model"]),
            data.get("numero_serie", current["serial_number"]),
            data.get("estado", current["status"]),
            data.get("fecha_adquisicion", current["acquisition_date"]),
            equipment_id,
        ),
        one=True,
        commit=True,
    )
    return jsonify(equipment_to_json(row))


@app.post("/equipos/<int:equipment_id>/asignar")
def assign_equipment(equipment_id):
    data = request.get_json(silent=True) or {}
    employee_id = data.get("empleado_id")
    if not employee_id:
        return jsonify({"error": "empleado_id es obligatorio"}), 400
    equipment = get_equipment(equipment_id)
    if not equipment:
        return jsonify({"error": "Equipo no encontrado"}), 404
    employee = query("SELECT * FROM employees WHERE id = %s", (employee_id,), one=True)
    if not employee:
        return jsonify({"error": "Empleado no encontrado"}), 404
    if equipment["status"] != "DISPONIBLE":
        return jsonify({"error": "El equipo no esta disponible"}), 409
    query(
        "INSERT INTO assignments (equipment_id, employee_id) VALUES (%s, %s)",
        (equipment_id, employee_id),
        commit=True,
    )
    row = query(
        "UPDATE equipment SET status = 'ASIGNADO', employee_id = %s WHERE id = %s RETURNING *",
        (employee_id, equipment_id),
        one=True,
        commit=True,
    )
    return jsonify(equipment_to_json(row))


@app.post("/equipos/<int:equipment_id>/mantenimientos")
def create_maintenance(equipment_id):
    if not get_equipment(equipment_id):
        return jsonify({"error": "Equipo no encontrado"}), 404
    data = request.get_json(silent=True) or {}
    if not data.get("tipo"):
        return jsonify({"error": "tipo es obligatorio"}), 400
    row = query(
        "INSERT INTO maintenance (equipment_id, type, description, cost) "
        "VALUES (%s, %s, %s, %s) RETURNING *",
        (equipment_id, data["tipo"], data.get("descripcion"), data.get("costo")),
        one=True,
        commit=True,
    )
    return jsonify({
        "id": row["id"],
        "equipo_id": row["equipment_id"],
        "fecha": str(row["maintenance_date"]),
        "tipo": row["type"],
        "descripcion": row["description"],
        "costo": float(row["cost"]) if row["cost"] is not None else None,
    }), 201


@app.get("/equipos/<int:equipment_id>/historial")
def equipment_history(equipment_id):
    equipment = get_equipment(equipment_id)
    if not equipment:
        return jsonify({"error": "Equipo no encontrado"}), 404
    assignments = query(
        "SELECT a.assigned_at, e.name FROM assignments a "
        "JOIN employees e ON e.id = a.employee_id WHERE a.equipment_id = %s",
        (equipment_id,),
    )
    maintenances = query(
        "SELECT maintenance_date, type FROM maintenance WHERE equipment_id = %s",
        (equipment_id,),
    )
    history = []
    for a in assignments:
        history.append({
            "fecha": a["assigned_at"].strftime("%Y-%m-%d"),
            "evento": "Asignacion",
            "detalle": a["name"],
        })
    for m in maintenances:
        history.append({
            "fecha": m["maintenance_date"].strftime("%Y-%m-%d"),
            "evento": "Mantenimiento",
            "detalle": m["type"],
        })
    history.sort(key=lambda item: item["fecha"])
    return jsonify({"equipo": equipment["internal_code"], "historial": history})


@app.post("/equipos/<int:equipment_id>/documentos")
def upload_document(equipment_id):
    equipment = get_equipment(equipment_id)
    if not equipment:
        return jsonify({"error": "Equipo no encontrado"}), 404
    file = request.files.get("file")
    if not file or not file.filename:
        return jsonify({"error": "Debe enviar un archivo en el campo 'file'"}), 400
    file_name = secure_filename(file.filename)
    if not file_name:
        return jsonify({"error": "Nombre de archivo no valido"}), 400
    key = f"equipos/{equipment['internal_code']}/{file_name}"
    try:
        s3.upload_fileobj(file, os.environ["S3_BUCKET"], key)
    except Exception:
        return jsonify({"error": "No se pudo subir el archivo a S3"}), 502
    row = query(
        "INSERT INTO documents (equipment_id, file_name, s3_key) VALUES (%s, %s, %s) RETURNING *",
        (equipment_id, file_name, key),
        one=True,
        commit=True,
    )
    return jsonify({
        "id": row["id"],
        "equipo_id": equipment_id,
        "nombre_archivo": row["file_name"],
        "s3_key": row["s3_key"],
    }), 201


@app.get("/equipos/<int:equipment_id>/documentos")
def list_documents(equipment_id):
    if not get_equipment(equipment_id):
        return jsonify({"error": "Equipo no encontrado"}), 404
    rows = query(
        "SELECT * FROM documents WHERE equipment_id = %s ORDER BY id",
        (equipment_id,),
    )
    return jsonify([
        {
            "id": r["id"],
            "nombre_archivo": r["file_name"],
            "s3_key": r["s3_key"],
            "fecha": str(r["created_at"]),
        }
        for r in rows
    ])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
