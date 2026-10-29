-- Questly - Primera entrega (PostgreSQL)

DROP TABLE IF EXISTS usuario_recompensa CASCADE;
DROP TABLE IF EXISTS estadistica CASCADE;
DROP TABLE IF EXISTS animo CASCADE;
DROP TABLE IF EXISTS recordatorio CASCADE;
DROP TABLE IF EXISTS meta CASCADE;
DROP TABLE IF EXISTS habito_tarea CASCADE;
DROP TABLE IF EXISTS habilidad CASCADE;
DROP TABLE IF EXISTS recompensa CASCADE;
DROP TABLE IF EXISTS usuario_persona CASCADE;

----------------------------------------------------------------------------------
CREATE TABLE usuario_persona (
    id_usuario         SERIAL,
    correo             VARCHAR(150) NOT NULL,
    nombre             VARCHAR(100) NOT NULL,
    rol                VARCHAR(50)  NOT NULL DEFAULT 'aprendiz',
    fecha_nacimiento   DATE,
    descripcion_tu     VARCHAR(500),
    puntos_experiencia INTEGER      NOT NULL DEFAULT 0,
    nivel              INTEGER      NOT NULL DEFAULT 1,
    CONSTRAINT pk_usuario_persona PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_correo UNIQUE (correo),
    CONSTRAINT ck_rol_valido CHECK (rol IN ('aprendiz', 'maestro', 'experto')),
    CONSTRAINT ck_puntos_no_negativos CHECK (puntos_experiencia >= 0),
    CONSTRAINT ck_nivel_minimo CHECK (nivel >= 1)
);

----------------------------------------------------------------------------------
CREATE TABLE habito_tarea (
    id_habito         SERIAL,
    nombre            VARCHAR(150) NOT NULL,
    nivel_importancia VARCHAR(20)  NOT NULL DEFAULT 'media',
    tiempo_invertido  INTEGER,
    fecha_inicio      DATE         NOT NULL DEFAULT CURRENT_DATE,
    fecha_final       DATE,
    frecuencia        VARCHAR(30)  NOT NULL DEFAULT 'diaria',
    usuario_id        INTEGER      NOT NULL,
    CONSTRAINT pk_habito_tarea PRIMARY KEY (id_habito),
    CONSTRAINT ck_importancia_valida CHECK (nivel_importancia IN ('alta', 'media', 'baja')),
    CONSTRAINT ck_tiempo_positivo CHECK (tiempo_invertido IS NULL OR tiempo_invertido > 0),
    CONSTRAINT ck_fechas_habito CHECK (fecha_final IS NULL OR fecha_final >= fecha_inicio),
    CONSTRAINT ck_frecuencia_valida CHECK (frecuencia IN ('diaria', 'semanal', 'mensual')),
    -- CASCADE: un hábito no tiene razón de existir sin su usuario.
    CONSTRAINT fk_habito_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario_persona (id_usuario) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
CREATE TABLE recompensa (
    id_recompensa     SERIAL,
    nombre            VARCHAR(100) NOT NULL,
    descripcion       VARCHAR(500),
    puntos_necesarios INTEGER      NOT NULL,
    habito_id         INTEGER,
    CONSTRAINT pk_recompensa PRIMARY KEY (id_recompensa),
    CONSTRAINT uq_recompensa_nombre UNIQUE (nombre),
    CONSTRAINT ck_puntos_necesarios_positivo CHECK (puntos_necesarios > 0),
    -- SET NULL: la recompensa puede ser global; si el hábito se borra, la recompensa sigue existiendo.
    CONSTRAINT fk_recompensa_habito FOREIGN KEY (habito_id)
        REFERENCES habito_tarea (id_habito) ON DELETE SET NULL
);

----------------------------------------------------------------------------------
-- Tabla intermedia (relación muchos a muchos): un usuario gana muchas recompensas
-- y una recompensa la pueden ganar muchos usuarios.
CREATE TABLE usuario_recompensa (
    usuario_id      INTEGER NOT NULL,
    recompensa_id   INTEGER NOT NULL,
    fecha_obtencion DATE    NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT pk_usuario_recompensa PRIMARY KEY (usuario_id, recompensa_id),
    -- CASCADE: si el usuario se elimina, se elimina su historial de logros.
    CONSTRAINT fk_ur_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario_persona (id_usuario) ON DELETE CASCADE,
    -- RESTRICT: no se puede borrar una recompensa que ya fue otorgada.
    CONSTRAINT fk_ur_recompensa FOREIGN KEY (recompensa_id)
        REFERENCES recompensa (id_recompensa) ON DELETE RESTRICT
);

----------------------------------------------------------------------------------
CREATE TABLE meta (
    id_meta        SERIAL,
    descripcion    VARCHAR(255) NOT NULL,
    valor_objetivo INTEGER      NOT NULL,
    fecha_limite   DATE,
    habito_id      INTEGER      NOT NULL,
    CONSTRAINT pk_meta PRIMARY KEY (id_meta),
    CONSTRAINT ck_valor_objetivo_positivo CHECK (valor_objetivo > 0),
    -- CASCADE: la meta se define sobre un hábito; sin él pierde su objeto.
    CONSTRAINT fk_meta_habito FOREIGN KEY (habito_id)
        REFERENCES habito_tarea (id_habito) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
CREATE TABLE recordatorio (
    id_recordatorio SERIAL,
    fecha_hora      TIMESTAMP    NOT NULL,
    mensaje         VARCHAR(255) NOT NULL,
    repeticion      VARCHAR(30)  NOT NULL DEFAULT 'única',
    habito_id       INTEGER      NOT NULL,
    CONSTRAINT pk_recordatorio PRIMARY KEY (id_recordatorio),
    CONSTRAINT ck_repeticion_valida CHECK (repeticion IN ('única', 'diaria', 'semanal', 'mensual')),
    -- CASCADE: un recordatorio solo tiene sentido con su hábito.
    CONSTRAINT fk_recordatorio_habito FOREIGN KEY (habito_id)
        REFERENCES habito_tarea (id_habito) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
CREATE TABLE habilidad (
    id_habilidad     SERIAL,
    nombre_habilidad VARCHAR(100) NOT NULL,
    descripcion      VARCHAR(500),
    nivel_habilidad  INTEGER      NOT NULL DEFAULT 1,
    usuario_id       INTEGER      NOT NULL,
    CONSTRAINT pk_habilidad PRIMARY KEY (id_habilidad),
    CONSTRAINT uq_habilidad_usuario UNIQUE (nombre_habilidad, usuario_id),
    CONSTRAINT ck_nivel_habilidad_rango CHECK (nivel_habilidad BETWEEN 1 AND 10),
    -- CASCADE: la habilidad pertenece al usuario que la desarrolla.
    CONSTRAINT fk_habilidad_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario_persona (id_usuario) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
CREATE TABLE animo (
    id_animo       SERIAL,
    estado_actual  VARCHAR(30) NOT NULL,
    comentario     VARCHAR(500),
    fecha_registro DATE        NOT NULL DEFAULT CURRENT_DATE,
    usuario_id     INTEGER     NOT NULL,
    CONSTRAINT pk_animo PRIMARY KEY (id_animo),
    CONSTRAINT ck_estado_actual_valido CHECK (estado_actual IN ('excelente', 'bien', 'normal', 'triste', 'estresado')),
    -- CASCADE: el historial de ánimo pertenece al usuario.
    CONSTRAINT fk_animo_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario_persona (id_usuario) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
CREATE TABLE estadistica (
    id_estadistica       SERIAL,
    total_completado     INTEGER NOT NULL DEFAULT 0,
    porcentaje_cumplido  INTEGER NOT NULL DEFAULT 0,
    racha_actual         INTEGER NOT NULL DEFAULT 0,
    fecha_inicio_periodo DATE    NOT NULL,
    fecha_fin_periodo    DATE    NOT NULL,
    usuario_id           INTEGER NOT NULL,
    CONSTRAINT pk_estadistica PRIMARY KEY (id_estadistica),
    CONSTRAINT ck_total_no_negativo CHECK (total_completado >= 0),
    CONSTRAINT ck_porcentaje_rango CHECK (porcentaje_cumplido BETWEEN 0 AND 100),
    CONSTRAINT ck_racha_no_negativa CHECK (racha_actual >= 0),
    CONSTRAINT ck_periodo_valido CHECK (fecha_fin_periodo >= fecha_inicio_periodo),
    -- CASCADE: las estadísticas describen a un usuario; sin él no tienen sentido.
    CONSTRAINT fk_estadistica_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario_persona (id_usuario) ON DELETE CASCADE
);

----------------------------------------------------------------------------------
-- DATOS DE PRUEBA
-- Usuario 6 y 'Insignia Platino' no se relacionan con nada.
----------------------------------------------------------------------------------
INSERT INTO usuario_persona (correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel) VALUES
    ('mariagomez@goshi.com', 'Maria Gomez', 'aprendiz', '1995-03-15', 'Quiero mejorar mis habitos de estudio', 1250, 3),
    ('carlosruiz@goshi.com', 'Carlos Ruiz', 'aprendiz', '2000-07-22', 'Buscando constancia en el ejercicio', 450, 1),
    ('lauraLopez@goshi.com', 'Laura Lopez', 'maestro', '1988-11-05', 'Experta en productividad', 8900, 12),
    ('juanpablo@goshi.com', 'Juan Pablo', 'aprendiz', '2002-01-30', 'Necesito organizar mi tiempo', 320, 1),
    ('andreamartines@goshi.com', 'Andrea Martines', 'experto', '1992-09-12', 'Mentalidad de crecimiento', 4500, 7),
    ('sofiaperez@goshi.com', 'Sofia Perez', 'aprendiz', '2003-05-18', NULL, 0, 1);

INSERT INTO recompensa (nombre, descripcion, puntos_necesarios) VALUES
    ('Insignia Bronce', 'Completar 10 habitos', 500),
    ('Insignia Plata', 'Completar 50 habitos', 2000),
    ('Insignia Oro', 'Completar 100 habitos', 5000),
    ('Medalla Constancia', '30 dias de racha', 1500),
    ('Titulo Maestro', 'Alcanzar nivel 10', 8000),
    ('Insignia Platino', 'Completar 500 habitos', 20000);

INSERT INTO usuario_recompensa (usuario_id, recompensa_id, fecha_obtencion) VALUES
    (1, 1, '2026-02-10'),
    (1, 4, '2026-03-05'),
    (3, 1, '2026-01-20'),
    (3, 2, '2026-02-25'),
    (3, 3, '2026-04-02'),
    (3, 5, '2026-04-20'),
    (5, 1, '2026-03-15'),
    (5, 2, '2026-04-10');

INSERT INTO habito_tarea (nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, usuario_id) VALUES
    ('Meditar 10 minutos', 'alta', 10, '2026-01-01', NULL, 'diaria', 1),
    ('Leer 20 paginas', 'alta', 30, '2026-01-01', NULL, 'diaria', 1),
    ('Hacer ejercicio', 'alta', 45, '2026-01-15', NULL, 'diaria', 2),
    ('Estudiar teoria del color', 'alta', 60, '2026-02-01', '2026-05-30', 'diaria', 1),
    ('Tomar 2L de agua', 'media', NULL, '2026-03-01', NULL, 'diaria', 3),
    ('Escribir en diario', 'baja', 15, '2026-01-10', NULL, 'diaria', 4),
    ('Practicar ingles', 'media', 20, '2026-02-15', NULL, 'diaria', 2),
    ('Ordenar escritorio', 'baja', 10, '2026-03-20', NULL, 'semanal', 5),
    ('Planificar semana', 'alta', 30, '2026-01-05', NULL, 'semanal', 3),
    ('Aprender receta nueva', 'baja', 40, '2026-04-01', NULL, 'mensual', 4);

INSERT INTO meta (descripcion, valor_objetivo, fecha_limite, habito_id) VALUES
    ('Completar 30 dias de meditación', 30, '2026-02-01', 1),
    ('Leer 10 libros completos', 10, '2026-12-31', 2),
    ('Bajar 5 kg de peso', 5, '2026-06-30', 3),
    ('Aprobar examen de SQL', 1, '2026-05-30', 4),
    ('Alcanzar 90 días de hidratación', 90, '2026-12-31', 5),
    ('Escribir 50 entradas de diario', 50, '2026-12-31', 6),
    ('Aprobar examen de humanidades', 1, '2026-08-30', 7),
    ('Completar 25 paginas de Homestuck', 25, '2026-12-31', 9);

INSERT INTO recordatorio (fecha_hora, mensaje, repeticion, habito_id) VALUES
    ('2026-05-01 07:00:00', '¡Tiempo de meditar! Busca un lugar tranquilo', 'diaria', 1),
    ('2026-05-01 20:00:00', 'No olvides leer 20 paginas antes de dormir', 'diaria', 2),
    ('2026-05-01 06:30:00', 'A ejercitarse!!! Ponte las zapatillas', 'diaria', 3),
    ('2026-05-01 18:00:00', 'Hora de estudiar SQL', 'diaria', 4),
    ('2026-05-02 10:00:00', 'Toma tu primer litro de agua', 'diaria', 5),
    ('2026-05-03 21:00:00', 'Escribe en tu diario antes de dormir', 'diaria', 6);

INSERT INTO habilidad (nombre_habilidad, descripcion, nivel_habilidad, usuario_id) VALUES
    ('Disciplina', 'Capacidad de mantener constancia', 5, 1),
    ('Gestion del tiempo', 'Organizar actividades eficientemente', 3, 1),
    ('Concentracion', 'Mantener enfoque en tareas', 4, 1),
    ('Resistencia física', 'Aguante para ejercicio', 2, 2),
    ('Fluidez lectora', 'Velocidad y comprension lectora', 6, 3),
    ('Paciencia', 'Tolerancia a la frustracion', 4, 3),
    ('Creatividad', 'Capacidad de generar ideas', 7, 5),
    ('Organizacion', 'Orden en tareas y espacio', 5, 4),
    ('Memoria', 'Retención de informacion', 4, 2),
    ('Adaptabilidad', 'Capacidad de ajustarse a cambios', 6, 5),
    ('Comunicacion', 'Expresar ideas claramente', 7, 3),
    ('Autocontrol', 'Manejo de impulsos', 5, 1);

INSERT INTO animo (estado_actual, comentario, fecha_registro, usuario_id) VALUES
    ('excelente', 'Dia productivo, cumplí todas mis metas', '2026-04-25', 1),
    ('bien', 'Avancé en lectura pero me faltó ejercicio', '2026-04-25', 2),
    ('normal', 'Dia regular sin sobresaltos', '2026-04-25', 3),
    ('triste', 'No llegué a hacer nada', '2026-04-25', 4),
    ('excelente', 'Me sentí muy enfocado', '2026-04-25', 5),
    ('bien', 'Medité 10 minutos y me sentí tranquilo', '2026-04-26', 1),
    ('estresado', 'Mucho trabajo, poco tiempo', '2026-04-26', 2),
    ('excelente', 'Terminé un libro importante', '2026-04-26', 3),
    ('normal', 'Cumplí con lo mínimo', '2026-04-26', 4),
    ('bien', 'Buena sesión de ejercicio', '2026-04-26', 5),
    ('excelente', 'Racha de 7 días cumplida', '2026-04-27', 1),
    ('triste', 'Me lesioné y no pude entrenar', '2026-04-27', 2),
    ('bien', 'Avance constante en el proyecto de P3', '2026-04-27', 1),
    ('normal', 'Dia libre', '2026-04-27', 3),
    ('excelente', 'Logré la meta semanal', '2026-04-27', 4);

INSERT INTO estadistica (total_completado, porcentaje_cumplido, racha_actual, fecha_inicio_periodo, fecha_fin_periodo, usuario_id) VALUES
    (24, 80, 7, '2026-04-18', '2026-04-24', 1),
    (18, 60, 3, '2026-04-18', '2026-04-24', 2),
    (28, 93, 12, '2026-04-18', '2026-04-24', 3),
    (15, 50, 2, '2026-04-18', '2026-04-24', 4),
    (26, 86, 8, '2026-04-18', '2026-04-24', 5),
    (28, 93, 10, '2026-04-11', '2026-04-17', 1),
    (20, 66, 4, '2026-04-11', '2026-04-17', 2),
    (30, 100, 14, '2026-04-11', '2026-04-17', 3);

----------------------------------------------------------------------------------
-- DEMOSTRACIÓN: restricciones rechazando datos (ejecutar de a una)
----------------------------------------------------------------------------------
-- ERROR: violates check constraint "ck_rol_valido"
-- INSERT INTO usuario_persona (correo, nombre, rol) VALUES ('x@goshi.com', 'Test', 'gremio');

-- ERROR: duplicate key value violates unique constraint "uq_usuario_correo"
-- INSERT INTO usuario_persona (correo, nombre) VALUES ('mariagomez@goshi.com', 'Otra Maria');

-- ERROR: violates check constraint "ck_fechas_habito"
-- INSERT INTO habito_tarea (nombre, fecha_inicio, fecha_final, usuario_id) VALUES ('Prueba', '2026-05-10', '2026-05-01', 1);

-- ERROR: violates foreign key constraint "fk_habito_usuario"
-- INSERT INTO habito_tarea (nombre, usuario_id) VALUES ('Prueba', 999);

-- ERROR: violates foreign key constraint "fk_ur_recompensa" (RESTRICT)
-- DELETE FROM recompensa WHERE id_recompensa = 1;

----------------------------------------------------------------------------------
-- CONSULTAS
----------------------------------------------------------------------------------
-- Usuarios con nivel mayor que 3.
SELECT nombre, correo, nivel, puntos_experiencia FROM usuario_persona WHERE nivel >= 3;

-- Habitos de importancia alta.
SELECT nombre, nivel_importancia, tiempo_invertido, frecuencia FROM habito_tarea WHERE nivel_importancia = 'alta';

-- Habitos que no tengan frecuencia diaria.
SELECT nombre, frecuencia FROM habito_tarea WHERE frecuencia != 'diaria';

-- Usuarios con un rango de nivel entre 5 y 10.
SELECT nombre, nivel FROM usuario_persona WHERE nivel BETWEEN 5 AND 10;

-- Habitos de los usuarios 1, 2 y 3.
SELECT nombre, usuario_id, nivel_importancia FROM habito_tarea WHERE usuario_id IN (1, 2, 3);

-- Habilidad que contenga la palabra "Capacidad" en su descripcion (ojo con mayusculas).
SELECT nombre_habilidad, descripcion FROM habilidad WHERE descripcion LIKE '%Capacidad%';

-- Nombre de la habilidad que empiece con C (ojo con mayusculas).
SELECT nombre_habilidad FROM habilidad WHERE nombre_habilidad LIKE 'C%';

-- Usuarios con descripcion null y no null.
SELECT nombre, correo FROM usuario_persona WHERE descripcion_tu IS NULL;
SELECT nombre, descripcion_tu FROM usuario_persona WHERE descripcion_tu IS NOT NULL;

-- Habilidades ordenadas por nivel descendente.
SELECT nombre_habilidad, nivel_habilidad, usuario_id FROM habilidad ORDER BY nivel_habilidad DESC;

-- Los tres habitos con mayor tiempo invertido.
SELECT nombre, tiempo_invertido FROM habito_tarea WHERE tiempo_invertido IS NOT NULL ORDER BY tiempo_invertido DESC LIMIT 3;

-- Estados de animo distintos.
SELECT DISTINCT estado_actual FROM animo;

-- Habitos con fecha final antes de 2026-06-01.
SELECT nombre, fecha_inicio, fecha_final FROM habito_tarea WHERE fecha_final < '2026-06-01';

-- Usuarios que se llamen Lopez o Martines (ILIKE ignora mayusculas).
SELECT nombre, correo FROM usuario_persona WHERE nombre ILIKE '%lopez' OR nombre ILIKE '%martines';

-- Estadisticas con porcentaje cumplido desde 80%, descendente.
SELECT usuario_id, porcentaje_cumplido, racha_actual, fecha_inicio_periodo, fecha_fin_periodo
FROM estadistica WHERE porcentaje_cumplido >= 80 ORDER BY porcentaje_cumplido DESC;

-- Habitos que no sean de importancia alta ni media.
SELECT nombre, nivel_importancia FROM habito_tarea WHERE nivel_importancia NOT IN ('alta', 'media');

-- Recordatorios diarios ordenados por fecha y hora ascendente.
SELECT mensaje, fecha_hora, repeticion FROM recordatorio WHERE repeticion = 'diaria' ORDER BY fecha_hora ASC;

-- Habilidades del usuario 1 con nivel mayor que 3, descendente.
SELECT nombre_habilidad, nivel_habilidad FROM habilidad WHERE usuario_id = 1 AND nivel_habilidad > 3 ORDER BY nivel_habilidad DESC;

-- Recompensas ganadas por cada usuario (incluye usuarios sin ninguna).
SELECT u.nombre, r.nombre AS recompensa, ur.fecha_obtencion
FROM usuario_persona u
LEFT JOIN usuario_recompensa ur ON ur.usuario_id = u.id_usuario
LEFT JOIN recompensa r ON r.id_recompensa = ur.recompensa_id;

----------------------------------------------------------------------------------
-- ELIMINACIONES
----------------------------------------------------------------------------------
-- Eliminar id del recordatorio 4.
DELETE FROM recordatorio WHERE id_recordatorio = 4;

-- Eliminar habitos con fecha final antes de 2026-06-01.
DELETE FROM habito_tarea WHERE fecha_final < '2026-06-01';

-- Eliminar animos de estado normal.
DELETE FROM animo WHERE estado_actual = 'normal';
