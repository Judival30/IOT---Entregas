CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    department VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS equipment (
    id SERIAL PRIMARY KEY,
    internal_code VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(50) NOT NULL,
    brand VARCHAR(80),
    model VARCHAR(80),
    serial_number VARCHAR(100) UNIQUE,
    status VARCHAR(30) NOT NULL DEFAULT 'DISPONIBLE',
    acquisition_date DATE,
    employee_id INTEGER REFERENCES employees(id)
);

CREATE TABLE IF NOT EXISTS assignments (
    id SERIAL PRIMARY KEY,
    equipment_id INTEGER NOT NULL REFERENCES equipment(id),
    employee_id INTEGER NOT NULL REFERENCES employees(id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS maintenance (
    id SERIAL PRIMARY KEY,
    equipment_id INTEGER NOT NULL REFERENCES equipment(id),
    maintenance_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    type VARCHAR(50),
    description TEXT,
    cost NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    equipment_id INTEGER NOT NULL REFERENCES equipment(id),
    file_name VARCHAR(255) NOT NULL,
    s3_key VARCHAR(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO employees (name, email, department) VALUES
('Ana Torres', 'ana@empresa.com', 'Tecnología'),
('Carlos Gómez', 'carlos@empresa.com', 'Finanzas'),
('Laura Martínez', 'laura@empresa.com', 'Recursos Humanos'),
('Pedro Ramírez', 'pedro@empresa.com', 'Ventas'),
('Sofía Herrera', 'sofia@empresa.com', 'Operaciones')
ON CONFLICT (email) DO NOTHING;

INSERT INTO equipment (internal_code, type, brand, model, serial_number, status, acquisition_date) VALUES
('LAP-0010', 'Laptop', 'Lenovo', 'ThinkPad E14', 'ABC123456', 'DISPONIBLE', '2025-03-15'),
('LAP-0011', 'Laptop', 'Dell', 'Latitude 5440', 'DEL987654', 'DISPONIBLE', '2025-04-02'),
('MON-0020', 'Monitor', 'LG', '27UL500', 'LGM555123', 'DISPONIBLE', '2025-05-20'),
('TEC-0030', 'Teclado', 'Logitech', 'K380', 'LOG111222', 'DISPONIBLE', '2025-06-10'),
('CEL-0040', 'Celular', 'Samsung', 'Galaxy A54', 'SAM333444', 'DISPONIBLE', '2025-07-01'),
('IMP-0050', 'Impresora', 'HP', 'LaserJet Pro M404', 'HPI777888', 'DISPONIBLE', '2025-08-12')
ON CONFLICT (internal_code) DO NOTHING;
