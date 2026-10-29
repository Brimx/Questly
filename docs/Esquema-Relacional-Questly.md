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

## Diccionario de datos detallado

### 1. `usuario_persona`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_usuario` | `integer` | No | PK, IDENTITY | Identificador único del usuario. |
| `correo` | `varchar(150)` | No | UNIQUE | Correo electrónico y clave alternativa para autenticación. |
| `nombre` | `varchar(100)` | No | — | Nombre completo o alias visible. |
| `rol` | `varchar(20)` | No | DEFAULT `'aprendiz'`, CHECK | Jerarquía del usuario (`aprendiz`, `maestro`, `experto`). |
| `fecha_nacimiento` | `date` | Sí | — | Fecha de nacimiento para cálculo demográfico y edad. |
| `descripcion_tu` | `text` | Sí | — | Biografía o perfil personal del usuario. |
| `puntos_experiencia` | `integer` | No | DEFAULT 0, CHECK (`>= 0`) | Puntos de experiencia (XP) acumulados. |
| `nivel` | `integer` | No | DEFAULT 1, CHECK (`>= 1`) | Nivel de progresión gamificada alcanzado. |

### 2. `habito_tarea`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_habito` | `integer` | No | PK, IDENTITY | Identificador único del hábito o tarea. |
| `nombre` | `varchar(150)` | No | — | Título del hábito a desarrollar o tarea a ejecutar. |
| `nivel_importancia` | `varchar(20)` | No | DEFAULT `'media'`, CHECK | Prioridad asignada (`alta`, `media`, `baja`). |
| `tiempo_invertido` | `integer` | Sí | CHECK (`> 0`) | Estimación de minutos por sesión. |
| `fecha_inicio` | `date` | No | DEFAULT `CURRENT_DATE` | Inicio del seguimiento del hábito. |
| `fecha_final` | `date` | Sí | CHECK (`>= fecha_inicio`) | Fin previsto o límite opcional del hábito. |
| `frecuencia` | `varchar(30)` | No | DEFAULT `'diaria'`, CHECK | Periodicidad de cumplimiento (`diaria`, `semanal`, `mensual`). |
| `usuario_id` | `integer` | No | FK → `usuario_persona(id_usuario)` ON DELETE CASCADE | Propietario del hábito. |

### 3. `meta`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_meta` | `integer` | No | PK, IDENTITY | Identificador único de la meta. |
| `descripcion` | `varchar(255)` | No | — | Descripción del objetivo a lograr. |
| `valor_objetivo` | `integer` | No | CHECK (`> 0`) | Meta numérica cuantificable a alcanzar. |
| `fecha_limite` | `date` | Sí | — | Fecha límite propuesta para cumplir la meta. |
| `habito_id` | `integer` | Sí | FK → `habito_tarea(id_habito)` ON DELETE SET NULL | Hábito asociado (opcional, sobrevive a su borrado). |

### 4. `recompensa`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_recompensa` | `integer` | No | PK, IDENTITY | Identificador único de la recompensa. |
| `nombre` | `varchar(100)` | No | UNIQUE | Título de la insignia o reconocimiento. |
| `descripcion` | `text` | Sí | — | Descripción del logro que premia. |
| `puntos_necesarios` | `integer` | No | CHECK (`> 0`) | Experiencia requerida para desbloquearla. |
| `habito_id` | `integer` | Sí | FK → `habito_tarea(id_habito)` ON DELETE SET NULL | Hábito específico asociado (opcional). |

### 5. `usuario_recompensa`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `usuario_id` | `integer` | No | PK comp., FK → `usuario_persona` ON DELETE CASCADE | Usuario que desbloqueó la recompensa. |
| `recompensa_id` | `integer` | No | PK comp., FK → `recompensa` ON DELETE RESTRICT | Recompensa obtenida (historial protegido). |
| `fecha_obtencion` | `date` | No | DEFAULT `CURRENT_DATE` | Fecha exacta en la que se otorgó la recompensa. |

### 6. `recordatorio`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_recordatorio` | `integer` | No | PK, IDENTITY | Identificador único del recordatorio. |
| `fecha_hora` | `timestamp` | No | — | Fecha y hora programada para el aviso. |
| `mensaje` | `varchar(255)` | No | — | Texto de la notificación. |
| `repeticion` | `varchar(30)` | No | DEFAULT `'única'`, CHECK | Repetición (`única`, `diaria`, `semanal`, `mensual`). |
| `habito_id` | `integer` | No | FK → `habito_tarea(id_habito)` ON DELETE CASCADE | Hábito al que corresponde la alerta. |

### 7. `habilidad`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_habilidad` | `integer` | No | PK, IDENTITY | Identificador único de la habilidad. |
| `nombre_habilidad` | `varchar(100)` | No | UNIQUE con `usuario_id` | Nombre de la destreza evaluada. |
| `descripcion` | `text` | Sí | — | Definición de la habilidad. |
| `nivel_habilidad` | `integer` | No | DEFAULT 1, CHECK (`BETWEEN 1 AND 10`) | Rango de progreso alcanzado. |
| `tipo_origen` | `varchar(10)` | No | CHECK (`'sistema'`, `'usuario'`) | Origen predefinido o personalizado por el usuario. |
| `usuario_id` | `integer` | No | FK → `usuario_persona(id_usuario)` ON DELETE CASCADE | Usuario titular de la habilidad. |

### 8. `animo`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_animo` | `integer` | No | PK, IDENTITY | Identificador único del registro de ánimo. |
| `estado_actual` | `varchar(30)` | No | CHECK (`'excelente'`, `'bien'`, `'normal'`, `'triste'`, `'estresado'`) | Estado de ánimo seleccionado. |
| `comentario` | `text` | Sí | — | Reflexión o notas sobre el estado emocional. |
| `fecha_registro` | `timestamp` | No | DEFAULT `CURRENT_TIMESTAMP` | Marca temporal del registro. |
| `usuario_id` | `integer` | No | FK → `usuario_persona(id_usuario)` ON DELETE CASCADE | Usuario que reportó su estado. |

### 9. `cumplimiento`
| Columna | Tipo previsto | Nulable | Restricciones / Defecto | Significado de negocio |
|---|---|---|---|---|
| `id_cumplimiento` | `integer` | No | PK, IDENTITY | Identificador único del evento de cumplimiento. |
| `fecha_cumplimiento` | `date` | No | UNIQUE con `habito_id` | Día calendario del cumplimiento registrado. |
| `habito_id` | `integer` | No | FK → `habito_tarea(id_habito)` ON DELETE CASCADE | Hábito ejecutado por el usuario. |

## Índices de claves foráneas

PostgreSQL no crea índices automáticamente en el lado que referencia una FK. La migración agrega índices para las consultas previstas: hábitos por usuario; metas, recompensas y recordatorios por hábito; recompensas obtenidas por recompensa; habilidades por usuario; ánimo por usuario y fecha; y cumplimientos por fecha. Las claves primarias y `UNIQUE` ya crean sus propios índices. La evidencia de `EXPLAIN ANALYZE` está en [Evidencia-Indices.md](Evidencia-Indices.md).

## Correspondencia con el EER Chen

El EER completo está en [`diagramas/Questly-EER-Chen.png`](../diagramas/Questly-EER-Chen.png) y usa exclusivamente notación Chen. Muestra las ocho entidades base y todas las relaciones. `Usuario_Recompensa` se representa conceptualmente como la relación N:M `obtiene`, con `fecha_obtencion` como atributo; en el esquema físico se implementa con una tabla asociativa y PK compuesta. `estadistica_habito` es una vista derivada, no una entidad almacenada. Se descarta la entidad `Alumno`; `rol` es un atributo de usuario. El EER general prioriza la estructura y las cardinalidades; los subdiagramas de perfil, usuarios/hábitos, seguimiento y recompensas detallan los atributos de cada área. El resto figura en este diccionario relacional.
