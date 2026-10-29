-- Banco de consultas de negocio para Questly.
-- Requiere migraciones/001_esquema_questly.sql y 002_datos_semilla.sql.

-- 1. ¿Qué hábitos activos tiene cada usuario y cuál es su frecuencia?
SELECT u.nombre AS usuario, h.nombre AS habito, h.frecuencia, h.nivel_importancia
FROM usuario_persona AS u
JOIN habito_tarea AS h ON h.usuario_id = u.id_usuario
WHERE h.fecha_final IS NULL OR h.fecha_final >= CURRENT_DATE
ORDER BY u.nombre, h.nombre;

-- 2. ¿Cuántas veces completó cada usuario cada hábito durante los últimos siete días?
SELECT u.nombre AS usuario, h.nombre AS habito,
       COUNT(c.id_cumplimiento) AS cumplimientos_7_dias
FROM usuario_persona AS u
JOIN habito_tarea AS h ON h.usuario_id = u.id_usuario
LEFT JOIN cumplimiento AS c
       ON c.habito_id = h.id_habito
      AND c.fecha_cumplimiento >= CURRENT_DATE - 6
      AND c.fecha_cumplimiento <= CURRENT_DATE
GROUP BY u.id_usuario, u.nombre, h.id_habito, h.nombre
ORDER BY u.nombre, cumplimientos_7_dias DESC;

-- 3. ¿Qué usuarios todavía no han obtenido ninguna recompensa?
SELECT u.id_usuario, u.nombre, u.correo
FROM usuario_persona AS u
LEFT JOIN usuario_recompensa AS ur ON ur.usuario_id = u.id_usuario
WHERE ur.usuario_id IS NULL
ORDER BY u.nombre;

-- 4. ¿Qué usuarios administran al menos dos hábitos?
SELECT u.id_usuario, u.nombre, COUNT(h.id_habito) AS cantidad_habitos
FROM usuario_persona AS u
JOIN habito_tarea AS h ON h.usuario_id = u.id_usuario
GROUP BY u.id_usuario, u.nombre
HAVING COUNT(h.id_habito) >= 2
ORDER BY cantidad_habitos DESC, u.nombre;

-- 5. ¿Qué recompensas obtuvo cada usuario y en qué fecha?
SELECT u.nombre AS usuario, r.nombre AS recompensa, ur.fecha_obtencion
FROM usuario_persona AS u
JOIN usuario_recompensa AS ur ON ur.usuario_id = u.id_usuario
JOIN recompensa AS r ON r.id_recompensa = ur.recompensa_id
ORDER BY ur.fecha_obtencion DESC, u.nombre;

-- 6. ¿Qué hábitos están por vencer y a quién pertenecen? (metas ligadas a hábitos)
SELECT u.nombre AS usuario, h.nombre AS habito, m.descripcion AS meta,
       m.fecha_limite, m.valor_objetivo
FROM meta AS m
JOIN habito_tarea AS h ON h.id_habito = m.habito_id
JOIN usuario_persona AS u ON u.id_usuario = h.usuario_id
WHERE m.fecha_limite BETWEEN CURRENT_DATE AND CURRENT_DATE + 30
ORDER BY m.fecha_limite, u.nombre;

-- 7. ¿Cuál es el porcentaje de cumplimiento y la racha actual por hábito?
-- Consulta la vista definida en 001_esquema_questly.sql.
SELECT u.nombre AS usuario, h.nombre AS habito,
       e.total_completado, e.porcentaje_cumplido, e.racha_actual
FROM estadistica_habito AS e
JOIN habito_tarea AS h ON h.id_habito = e.id_habito
JOIN usuario_persona AS u ON u.id_usuario = e.usuario_id
ORDER BY e.porcentaje_cumplido DESC NULLS LAST, h.nombre;

-- 8. ¿Cuántos hábitos de cada frecuencia están registrados y cuáles frecuencias tienen varios?
SELECT frecuencia, COUNT(*) AS cantidad_habitos
FROM habito_tarea
GROUP BY frecuencia
HAVING COUNT(*) >= 2
ORDER BY cantidad_habitos DESC;

-- 9. ¿Cómo se distribuyen los registros de ánimo por usuario y estado?
SELECT u.nombre AS usuario, a.estado_actual, COUNT(*) AS cantidad_registros
FROM usuario_persona AS u
JOIN animo AS a ON a.usuario_id = u.id_usuario
GROUP BY u.id_usuario, u.nombre, a.estado_actual
ORDER BY u.nombre, cantidad_registros DESC;

-- 10. ¿Qué usuarios completaron hábitos de alta importancia esta semana?
WITH actividad_semanal AS (
    SELECT c.habito_id, COUNT(*) AS completados
    FROM cumplimiento AS c
    WHERE c.fecha_cumplimiento >= date_trunc('week', CURRENT_DATE)::date
      AND c.fecha_cumplimiento < date_trunc('week', CURRENT_DATE)::date + 7
    GROUP BY c.habito_id
)
SELECT u.nombre AS usuario, h.nombre AS habito, a.completados
FROM actividad_semanal AS a
JOIN habito_tarea AS h ON h.id_habito = a.habito_id
JOIN usuario_persona AS u ON u.id_usuario = h.usuario_id
WHERE h.nivel_importancia = 'alta'
ORDER BY a.completados DESC, u.nombre;
