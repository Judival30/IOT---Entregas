import os
from decimal import Decimal

import psycopg
from flask import Flask, jsonify, request
from psycopg.rows import dict_row

app = Flask(__name__)

INSTANCE = os.getenv("INSTANCE", "api-local")
DB_CONFIG = {
    "host": os.getenv("DB_HOST", "db"),
    "dbname": os.getenv("DB_NAME", "shop"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.getenv("DB_PASSWORD", "postgres"),
}


def get_connection():
    return psycopg.connect(**DB_CONFIG, row_factory=dict_row)


def serialize(product):
    """Convierte los tipos de PostgreSQL a tipos JSON simples."""
    return {
        "id": product["id"],
        "name": product["name"],
        "price": float(product["price"]) if isinstance(product["price"], Decimal) else product["price"],
    }


@app.get("/products")
def list_products():
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute("SELECT id, name, price FROM products ORDER BY id;")
        products = [serialize(row) for row in cur.fetchall()]
    return jsonify({"served_by": INSTANCE, "products": products})


@app.get("/products/<int:product_id>")
def get_product(product_id):
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute("SELECT id, name, price FROM products WHERE id = %s;", (product_id,))
        row = cur.fetchone()
    if row is None:
        return jsonify({"served_by": INSTANCE, "error": "not found"}), 404
    return jsonify({"served_by": INSTANCE, "product": serialize(row)})


@app.post("/products")
def create_product():
    data = request.get_json(silent=True) or {}
    name = data.get("name")
    price = data.get("price")
    if name is None or price is None:
        return jsonify({"served_by": INSTANCE, "error": "name and price are required"}), 400
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            "INSERT INTO products (name, price) VALUES (%s, %s) RETURNING id, name, price;",
            (name, price),
        )
        row = cur.fetchone()
    return jsonify({"served_by": INSTANCE, "product": serialize(row)}), 201


@app.put("/products/<int:product_id>")
def update_product(product_id):
    data = request.get_json(silent=True) or {}
    name = data.get("name")
    price = data.get("price")
    if name is None or price is None:
        return jsonify({"served_by": INSTANCE, "error": "name and price are required"}), 400
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute(
            "UPDATE products SET name = %s, price = %s WHERE id = %s RETURNING id, name, price;",
            (name, price, product_id),
        )
        row = cur.fetchone()
    if row is None:
        return jsonify({"served_by": INSTANCE, "error": "not found"}), 404
    return jsonify({"served_by": INSTANCE, "product": serialize(row)})


@app.delete("/products/<int:product_id>")
def delete_product(product_id):
    with get_connection() as conn, conn.cursor() as cur:
        cur.execute("DELETE FROM products WHERE id = %s RETURNING id;", (product_id,))
        row = cur.fetchone()
    if row is None:
        return jsonify({"served_by": INSTANCE, "error": "not found"}), 404
    return jsonify({"served_by": INSTANCE, "deleted": product_id})


@app.get("/health")
def health():
    try:
        with get_connection() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        db_ok = True
    except Exception:
        db_ok = False
    status = 200 if db_ok else 503
    return jsonify({"served_by": INSTANCE, "db": db_ok}), status


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
