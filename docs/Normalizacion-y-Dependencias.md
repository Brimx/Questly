# Normalización y dependencias funcionales

Auditoría del esquema implementado en `migraciones/001_esquema_questly.sql`. Se evalúan las tablas base; `estadistica_habito` es una vista calculada y no almacena hechos redundantes.

## Primera forma normal (1FN)

Las columnas almacenan valores atómicos y no hay grupos repetidos ni listas dentro de una celda. Los hábitos, recordatorios, registros de ánimo y cumplimientos se representan en filas separadas. La asociación N:M entre usuarios y recompensas se descompone en `usuario_recompensa`.

## Segunda forma normal (2FN)

Las tablas con clave primaria simple no tienen dependencias parciales. `usuario_recompensa` tiene PK compuesta `(usuario_id, recompensa_id)` y su único atributo no clave, `fecha_obtencion`, describe la obtención de ese par completo. No depende solo del usuario ni solo de la recompensa.

## Tercera forma normal (3FN)

Los atributos no clave dependen de una clave candidata, de toda la clave y de nada más que la clave; no se almacenan atributos de otras entidades junto a sus referencias:

- Los datos de usuario se guardan en `usuario_persona`, no se repiten en hábitos, ánimo o habilidades.
- Los atributos de `recompensa` no se copian a `usuario_recompensa`; la tabla asociativa conserva las dos FK y la fecha de obtención.
- Metas, recordatorios y cumplimientos se separan de `habito_tarea` porque son hechos con existencia y cardinalidad propias.
- Las claves alternativas se protegen con `UNIQUE`: `correo`, `recompensa.nombre`, `(habilidad.nombre_habilidad, habilidad.usuario_id)` y `(cumplimiento.habito_id, cumplimiento.fecha_cumplimiento)`.
- `estadistica_habito` calcula totales, porcentaje y racha desde hábitos y cumplimientos. No se duplican valores derivados que puedan quedar desactualizados.

## Dependencias funcionales principales

- `id_usuario → correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel`; `correo` también identifica un usuario.
- `id_habito → nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, usuario_id`.
- `id_meta → descripcion, valor_objetivo, fecha_limite, habito_id`.
- `id_recompensa → nombre, descripcion, puntos_necesarios, habito_id`; `nombre` es único.
- `(usuario_id, recompensa_id) → fecha_obtencion`.
- `id_recordatorio → fecha_hora, mensaje, repeticion, habito_id`.
- `id_habilidad → nombre_habilidad, descripcion, nivel_habilidad, tipo_origen, usuario_id`; además, `(nombre_habilidad, usuario_id)` es único.
- `id_animo → estado_actual, comentario, fecha_registro, usuario_id`.
- `id_cumplimiento → fecha_cumplimiento, habito_id`; la pareja `(habito_id, fecha_cumplimiento)` también es única.

## Decisiones y límites

- `meta.habito_id` y `recompensa.habito_id` son opcionales; la nulabilidad no introduce dependencias parciales ni transitivas.
- No se modela `Alumno` como subtipo: `rol` es atributo de usuario.
- `puntos_experiencia` y `nivel` se mantienen como atributos independientes porque no se definió una regla de negocio que derive uno del otro. Si se fija una fórmula para `nivel`, debe revisarse si conviene calcularlo en vez de almacenarlo.
- La vista `estadistica_habito` tiene granularidad de un registro por hábito y deriva sus métricas de `Cumplimiento`; no se usa como tabla de hechos.
