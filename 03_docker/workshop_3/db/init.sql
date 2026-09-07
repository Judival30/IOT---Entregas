CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

INSERT INTO products (name, price) VALUES
    ('Laptop', 3500000),
    ('Mouse', 80000),
    ('Teclado mecanico', 250000),
    ('Monitor 27"', 1200000),
    ('Webcam HD', 180000),
    ('Audifonos', 320000);
