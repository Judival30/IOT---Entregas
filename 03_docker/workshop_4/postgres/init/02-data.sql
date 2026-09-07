INSERT INTO academia.students (name, email) VALUES
    ('Ana', 'ana@example.com'),
    ('Luis', 'luis@example.com'),
    ('Marta', 'marta@example.com'),
    ('Carlos', 'carlos@example.com');

INSERT INTO academia.teachers (name, email) VALUES
    ('Prof. Gomez', 'gomez@example.com'),
    ('Prof. Ramirez', 'ramirez@example.com');

INSERT INTO academia.courses (name, credits, teacher_id) VALUES
    ('Cloud Computing', 3, 1),
    ('Internet of Things', 4, 1),
    ('Bases de Datos', 3, 2),
    ('Redes', 3, 2);

INSERT INTO academia.enrollments (student_id, course_id) VALUES
    (1, 1),
    (1, 2),
    (2, 1),
    (2, 3),
    (3, 2),
    (3, 4),
    (4, 1);
