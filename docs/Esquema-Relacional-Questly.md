# Esquema relacional — Questly

Convenciones: atributos de **clave primaria en negrita**, *clave foránea en cursiva*.  
Las políticas de borrado se documentan con su justificación.

---

## Relaciones

### Usuario_persona (**Id_usuario**, correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel)

---

### Habito_tarea (**Id_habito**, nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, *Id_usuario*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | Un hábito no tiene razón de existir sin su usuario. Se elimina junto con él. |

---

### Animo (**Id_animo**, estado_actual, comentario, fecha_registro, *Id_usuario*)

> ⚠️ `fecha_registro` debe agregarse al EER (ver Supuesto S3).

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | El historial de ánimo pertenece al usuario; sin él carece de contexto. |

---

### Recordatorio (**Id_recordatorio**, fecha_hora, mensaje, repeticion, *Id_habito*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_habito* | Habito_tarea | `CASCADE` | Un recordatorio solo tiene sentido asociado a su hábito (`Id_habito` es obligatorio). Se elimina junto con él. |

---

### Meta (**Id_meta**, descripcion, valor_objetivo, fecha_limite, *Id_habito*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_habito* | Habito_tarea | `CASCADE` | La meta se define sobre un hábito (`Id_habito` es obligatorio); si el hábito se elimina, la meta pierde su objeto y se elimina con él. |

---

### Estadistica (**Id_estadistica**, total_completado, porcentaje_cumplido, racha_actual, fecha_inicio_periodo, fecha_fin_periodo, *Id_usuario*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | Las estadísticas describen el desempeño de un usuario en un periodo; sin el usuario carecen de sentido. |

---

### Habilidad (**Id_habilidad**, nombre_habilidad, descripcion, nivel_habilidad, *Id_usuario*)

Un mismo usuario no puede tener dos habilidades con el mismo `nombre_habilidad` (`UNIQUE (nombre_habilidad, Id_usuario)`).

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | La habilidad pertenece al usuario que la desarrolla; sin él carece de dueño. |

---

### Recompensa (**Id_recompensa**, nombre, descripcion, puntos_necesarios, *Id_habito*)

`Id_habito` es opcional (puede ser nulo): una recompensa puede ser global del sistema o estar ligada a un hábito.

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_habito* | Habito_tarea | `CASCADE` | Si la recompensa está ligada a un hábito y este se elimina, la recompensa se elimina con él. |

---

## Observaciones sobre el EER

Las siguientes correcciones deben reflejarse en el diagrama actualizado:

1. **`Animo.fecha_registro`** — Atributo faltante. Necesario para el historial dinámico.
2. **`Meta`** — Se asocia únicamente a `Habito_tarea` (`Id_habito` obligatorio); no tiene relación directa con `Usuario_persona`.
3. **`Estadistica`** — Se asocia a `Usuario_persona` (no a `Habito_tarea`) e incluye `fecha_inicio_periodo` y `fecha_fin_periodo`.
4. **`Habilidad`** — Se asocia directamente a `Usuario_persona` (`Id_usuario`); no hay tabla intermedia N:M ni atributo `tipo_origen`.
5. **`Recompensa.Id_habito`** — Debe marcarse como atributo opcional (nullable) en el diagrama.
