-- Datos ficticios para desarrollo y pruebas. Ejecutar después de 001_esquema_questly.sql.

INSERT INTO usuario_persona
    (correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel)
VALUES
    ('maria@example.invalid', 'María Gómez', 'aprendiz', '1995-03-15', 'Mejorar mis hábitos de estudio', 1250, 3),
    ('carlos@example.invalid', 'Carlos Ruiz', 'aprendiz', '2000-07-22', 'Ser constante con el ejercicio', 450, 1),
    ('laura@example.invalid', 'Laura López', 'maestro', '1988-11-05', 'Compartir técnicas de productividad', 8900, 12),
    ('juan@example.invalid', 'Juan Pérez', 'aprendiz', '2002-01-30', 'Organizar mi tiempo', 320, 1),
    ('sofia@example.invalid', 'Sofía Torres', 'aprendiz', '2003-05-18', NULL, 0, 1);

INSERT INTO recompensa (nombre, descripcion, puntos_necesarios)
VALUES
    ('Insignia Bronce', 'Completar diez hábitos', 500),
    ('Insignia Plata', 'Completar cincuenta hábitos', 2000),
    ('Insignia Oro', 'Completar cien hábitos', 5000),
    ('Medalla Constancia', 'Mantener una racha de treinta días', 1500),
    ('Título Maestro', 'Alcanzar el nivel diez', 8000),
    ('Insignia Platino', 'Completar quinientos hábitos', 20000);

INSERT INTO habito_tarea
    (nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, usuario_id)
SELECT datos.nombre, datos.importancia, datos.minutos, datos.inicio, datos.fin, datos.frecuencia, u.id_usuario
FROM (VALUES
    ('Meditar diez minutos', 'alta', 10, CURRENT_DATE - 6, NULL::date, 'diaria', 'maria@example.invalid'),
    ('Leer veinte páginas', 'alta', 30, CURRENT_DATE - 14, NULL::date, 'diaria', 'maria@example.invalid'),
    ('Hacer ejercicio', 'alta', 45, CURRENT_DATE - 21, NULL::date, 'semanal', 'carlos@example.invalid'),
    ('Estudiar teoría del color', 'alta', 60, CURRENT_DATE - 30, NULL::date, 'diaria', 'maria@example.invalid'),
    ('Tomar dos litros de agua', 'media', NULL, CURRENT_DATE - 9, NULL::date, 'diaria', 'laura@example.invalid'),
    ('Escribir en el diario', 'baja', 15, CURRENT_DATE - 14, NULL::date, 'diaria', 'juan@example.invalid'),
    ('Practicar inglés', 'media', 20, CURRENT_DATE - 18, NULL::date, 'diaria', 'carlos@example.invalid'),
    ('Ordenar el escritorio', 'baja', 10, CURRENT_DATE - 28, NULL::date, 'semanal', 'sofia@example.invalid'),
    ('Planificar la semana', 'alta', 30, CURRENT_DATE - 35, NULL::date, 'semanal', 'laura@example.invalid'),
    ('Aprender una receta nueva', 'baja', 40, CURRENT_DATE - 60, NULL::date, 'mensual', 'juan@example.invalid')
) AS datos(nombre, importancia, minutos, inicio, fin, frecuencia, correo_usuario)
JOIN usuario_persona AS u ON u.correo = datos.correo_usuario;

INSERT INTO meta (descripcion, valor_objetivo, fecha_limite, habito_id)
SELECT datos.descripcion, datos.objetivo, datos.fecha_limite, h.id_habito
FROM (VALUES
    ('Completar una semana de meditación', 7, CURRENT_DATE + 20, 'Meditar diez minutos'),
    ('Leer doce libros este año', 12, CURRENT_DATE + 90, NULL),
    ('Mantener tres semanas de ejercicio', 3, CURRENT_DATE + 30, 'Hacer ejercicio'),
    ('Escribir veinte entradas de diario', 20, CURRENT_DATE + 45, 'Escribir en el diario')
) AS datos(descripcion, objetivo, fecha_limite, nombre_habito)
LEFT JOIN habito_tarea AS h ON h.nombre = datos.nombre_habito;

INSERT INTO recordatorio (fecha_hora, mensaje, repeticion, habito_id)
SELECT CURRENT_TIMESTAMP + datos.demora, datos.mensaje, datos.repeticion, h.id_habito
FROM (VALUES
    ('Meditar diez minutos', INTERVAL '1 hour', 'Hora de meditar', 'diaria'),
    ('Leer veinte páginas', INTERVAL '8 hours', 'Leer antes de dormir', 'diaria'),
    ('Hacer ejercicio', INTERVAL '1 day', 'Día de entrenamiento', 'semanal'),
    ('Planificar la semana', INTERVAL '2 days', 'Revisar el plan semanal', 'semanal')
) AS datos(nombre_habito, demora, mensaje, repeticion)
JOIN habito_tarea AS h ON h.nombre = datos.nombre_habito;

INSERT INTO habilidad (nombre_habilidad, descripcion, nivel_habilidad, tipo_origen, usuario_id)
SELECT datos.nombre, datos.descripcion, datos.nivel, datos.origen, u.id_usuario
FROM (VALUES
    ('Disciplina', 'Mantener constancia', 5, 'sistema', 'maria@example.invalid'),
    ('Gestión del tiempo', 'Organizar actividades', 3, 'usuario', 'maria@example.invalid'),
    ('Concentración', 'Mantener el enfoque', 4, 'sistema', 'maria@example.invalid'),
    ('Resistencia física', 'Sostener el esfuerzo físico', 2, 'sistema', 'carlos@example.invalid'),
    ('Creatividad', 'Generar ideas nuevas', 7, 'usuario', 'laura@example.invalid'),
    ('Organización', 'Ordenar tareas y espacios', 5, 'usuario', 'juan@example.invalid')
) AS datos(nombre, descripcion, nivel, origen, correo_usuario)
JOIN usuario_persona AS u ON u.correo = datos.correo_usuario;

INSERT INTO animo (estado_actual, comentario, fecha_registro, usuario_id)
SELECT datos.estado, datos.comentario, CURRENT_TIMESTAMP - datos.antiguedad, u.id_usuario
FROM (VALUES
    ('excelente', 'Terminé mis prioridades del día', INTERVAL '1 day', 'maria@example.invalid'),
    ('bien', 'Avancé con el entrenamiento', INTERVAL '2 days', 'carlos@example.invalid'),
    ('normal', 'Día tranquilo', INTERVAL '3 days', 'laura@example.invalid'),
    ('estresado', 'Tengo varias entregas pendientes', INTERVAL '1 hour', 'juan@example.invalid'),
    ('bien', 'Me siento con energía', INTERVAL '4 days', 'maria@example.invalid')
) AS datos(estado, comentario, antiguedad, correo_usuario)
JOIN usuario_persona AS u ON u.correo = datos.correo_usuario;

INSERT INTO cumplimiento (fecha_cumplimiento, habito_id)
SELECT datos.fecha, h.id_habito
FROM (VALUES
    ('Meditar diez minutos', CURRENT_DATE - 5),
    ('Meditar diez minutos', CURRENT_DATE - 3),
    ('Meditar diez minutos', CURRENT_DATE - 1),
    ('Meditar diez minutos', CURRENT_DATE),
    ('Leer veinte páginas', CURRENT_DATE - 2),
    ('Leer veinte páginas', CURRENT_DATE),
    ('Hacer ejercicio', CURRENT_DATE - 14),
    ('Hacer ejercicio', CURRENT_DATE - 7),
    ('Hacer ejercicio', CURRENT_DATE),
    ('Estudiar teoría del color', CURRENT_DATE - 1),
    ('Estudiar teoría del color', CURRENT_DATE),
    ('Tomar dos litros de agua', CURRENT_DATE - 1),
    ('Tomar dos litros de agua', CURRENT_DATE),
    ('Escribir en el diario', CURRENT_DATE - 3),
    ('Escribir en el diario', CURRENT_DATE),
    ('Ordenar el escritorio', CURRENT_DATE - 7),
    ('Ordenar el escritorio', CURRENT_DATE),
    ('Planificar la semana', CURRENT_DATE - 7),
    ('Planificar la semana', CURRENT_DATE)
) AS datos(nombre_habito, fecha)
JOIN habito_tarea AS h ON h.nombre = datos.nombre_habito;

INSERT INTO usuario_recompensa (usuario_id, recompensa_id, fecha_obtencion)
SELECT u.id_usuario, r.id_recompensa, datos.fecha
FROM (VALUES
    ('maria@example.invalid', 'Insignia Bronce', CURRENT_DATE - 20),
    ('maria@example.invalid', 'Medalla Constancia', CURRENT_DATE - 5),
    ('laura@example.invalid', 'Insignia Bronce', CURRENT_DATE - 30),
    ('laura@example.invalid', 'Insignia Plata', CURRENT_DATE - 10),
    ('carlos@example.invalid', 'Insignia Bronce', CURRENT_DATE - 2)
) AS datos(correo_usuario, nombre_recompensa, fecha)
JOIN usuario_persona AS u ON u.correo = datos.correo_usuario
JOIN recompensa AS r ON r.nombre = datos.nombre_recompensa;
