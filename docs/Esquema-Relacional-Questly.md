# Esquema relacional — Questly

Esquema implementado por `migraciones/001_esquema_questly.sql`. Las tablas almacenan hechos del dominio; `estadistica_habito` es una vista calculada.

Convenciones: **negrita** = clave primaria; *cursiva* = clave foránea; `?` = nullable.

## Relaciones

### Usuario_persona
`Usuario_persona(**id_usuario**, correo, nombre, rol, fecha_nacimiento?, descripcion_tu?, puntos_experiencia, nivel)`

- `correo` es único.
- `rol` ∈ {`aprendiz`, `maestro`, `experto`}.
- `puntos_experiencia >= 0`; `nivel >= 1`.
- No hay subtipos de usuario: los roles son un atributo.

### Habito_tarea
`Habito_tarea(**id_habito**, nombre, nivel_importancia, tiempo_invertido?, fecha_inicio, fecha_final?, frecuencia, *usuario_id*)`

- `usuario_id → Usuario_persona.id_usuario`, `NOT NULL`, `ON DELETE CASCADE`.
- `nivel_importancia` ∈ {`alta`, `media`, `baja`}; `frecuencia` ∈ {`diaria`, `semanal`, `mensual`}.
- `tiempo_invertido` es nulo o positivo; `fecha_final` es nula o no anterior a `fecha_inicio`.

### Meta
`Meta(**id_meta**, descripcion, valor_objetivo, fecha_limite?, *habito_id?*)`

- `habito_id → Habito_tarea.id_habito`, nullable, `ON DELETE SET NULL`: una meta puede ser independiente y sobrevive al borrado del hábito.
- `valor_objetivo > 0`.

### Recompensa
`Recompensa(**id_recompensa**, nombre, descripcion?, puntos_necesarios, *habito_id?*)`

- `nombre` es único; `puntos_necesarios > 0`.
- `habito_id → Habito_tarea.id_habito`, nullable, `ON DELETE SET NULL`: una recompensa puede ser global y no se pierde si se borra el hábito relacionado.

### Usuario_Recompensa
`Usuario_Recompensa(**_*usuario_id*_**, **_*recompensa_id*_**, fecha_obtencion)`

- PK compuesta: `(usuario_id, recompensa_id)`; cada usuario puede obtener una vez cada recompensa.
- `usuario_id → Usuario_persona.id_usuario`, `ON DELETE CASCADE`.
- `recompensa_id → Recompensa.id_recompensa`, `ON DELETE RESTRICT` para conservar el historial de recompensas otorgadas.

### Recordatorio
`Recordatorio(**id_recordatorio**, fecha_hora, mensaje, repeticion, *habito_id*)`

- `habito_id → Habito_tarea.id_habito`, `NOT NULL`, `ON DELETE CASCADE`.
- `repeticion` ∈ {`única`, `diaria`, `semanal`, `mensual`}.

### Habilidad
`Habilidad(**id_habilidad**, nombre_habilidad, descripcion?, nivel_habilidad, tipo_origen, *usuario_id*)`

- `usuario_id → Usuario_persona.id_usuario`, `NOT NULL`, `ON DELETE CASCADE`.
- `UNIQUE (nombre_habilidad, usuario_id)`.
- `nivel_habilidad` ∈ [1, 10]; `tipo_origen` ∈ {`sistema`, `usuario`}.

### Animo
`Animo(**id_animo**, estado_actual, comentario?, fecha_registro, *usuario_id*)`

- `usuario_id → Usuario_persona.id_usuario`, `NOT NULL`, `ON DELETE CASCADE`.
- `fecha_registro` es `TIMESTAMP NOT NULL` para conservar la hora del registro.
- `estado_actual` ∈ {`excelente`, `bien`, `normal`, `triste`, `estresado`}.

### Cumplimiento
`Cumplimiento(**id_cumplimiento**, fecha_cumplimiento, *habito_id*)`

- `habito_id → Habito_tarea.id_habito`, `NOT NULL`, `ON DELETE CASCADE`.
- `UNIQUE (habito_id, fecha_cumplimiento)` evita registrar dos cumplimientos del mismo hábito en un día.

## Vista calculada

`estadistica_habito(id_habito, usuario_id, total_completado, porcentaje_cumplido, racha_actual)` resume cada hábito desde su inicio hasta el período actual o su fecha final. No se insertan estadísticas manualmente: la vista calcula los valores desde `Cumplimiento`.

- Frecuencia diaria: períodos por día calendario.
- Frecuencia semanal: semanas ISO, de lunes a domingo.
- Frecuencia mensual: meses calendario.
- El porcentaje es períodos completados / períodos esperados × 100. La racha cuenta períodos consecutivos completados hasta el último período esperado.

## Índices de claves foráneas

PostgreSQL no crea índices automáticamente en el lado que referencia una FK. La migración agrega índices para las consultas previstas: hábitos por usuario; metas, recompensas y recordatorios por hábito; recompensas obtenidas por recompensa; habilidades por usuario; ánimo por usuario y fecha; y cumplimientos por fecha. Las claves primarias y `UNIQUE` ya crean sus propios índices. La evidencia de `EXPLAIN ANALYZE` está en [Evidencia-Indices.md](Evidencia-Indices.md).

## Correspondencia con el EER Chen

El EER completo está en [`diagramas/Questly-EER-Chen.png`](../diagramas/Questly-EER-Chen.png) y usa exclusivamente notación Chen. Muestra las ocho entidades base y todas las relaciones. `Usuario_Recompensa` se representa conceptualmente como la relación N:M `obtiene`, con `fecha_obtencion` como atributo; en el esquema físico se implementa con una tabla asociativa y PK compuesta. `estadistica_habito` es una vista derivada, no una entidad almacenada. Se descarta la entidad `Alumno`; `rol` es un atributo de usuario. El EER general prioriza la estructura y las cardinalidades; los subdiagramas de perfil, usuarios/hábitos, seguimiento y recompensas detallan los atributos de cada área. El resto figura en este diccionario relacional.
