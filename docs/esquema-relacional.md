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
| *Id_habito* | Habito_tarea | Pendiente — Entrega 2 | Se evaluará si los recordatorios deben preservarse como historial o eliminarse con el hábito. |

---

### Meta (**Id_meta**, descripcion, valor_objetivo, fecha_limite, *Id_usuario*, *Id_habito*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | La meta pertenece al usuario; sin él no tiene dueño. |
| *Id_habito* | Habito_tarea | `SET NULL` | La meta puede sobrevivir sin su hábito (ver Supuesto S5). La FK se anula, no se elimina la meta. |

---

### Estadistica (**Id_estadistica**, total_completado, porcentaje_cumplido, racha_actual, *Id_habito*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_habito* | Habito_tarea | `CASCADE` | Las estadísticas son inseparables del hábito que las genera. |

---

### Habilidad (**Id_habilidad**, nombre_habilidad, descripcion, nivel_habilidad, tipo_origen)

Sin claves foráneas. Las habilidades son entidades independientes del sistema.

---

### Recompensa (**Id_recompensa**, nombre, descripcion, puntos_necesarios)

Sin claves foráneas. Las recompensas son entidades globales del sistema.

---

### Grupo (**Id_grupo**, nombre_grupo, descripcion, fecha_creacion, *Id_usuario_lider*)

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario_lider* | Usuario_persona | `SET NULL` | Si el líder abandona o es eliminado, el grupo no desaparece; queda sin líder hasta que se asigne uno nuevo. |

---

### Usuario_Habilidad (**Id_usuario**, **Id_habilidad**, fecha_obtenida)

Tabla intermedia N:M entre Usuario_persona y Habilidad.

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | Si el usuario se elimina, sus habilidades desbloqueadas desaparecen con él. |
| *Id_habilidad* | Habilidad | `CASCADE` | Si el sistema retira una habilidad, también se elimina de los usuarios que la tenían. |

---

### Usuario_Grupo_Membresia (**Id_usuario**, **Id_grupo**, rol_en_grupo, fecha_ingreso)

Tabla intermedia N:M entre Usuario_persona y Grupo.

| FK | Referencia | Política de borrado | Justificación |
|---|---|---|---|
| *Id_usuario* | Usuario_persona | `CASCADE` | Si el usuario se elimina, su membresía en todos los grupos desaparece. |
| *Id_grupo* | Grupo | `CASCADE` | Si el grupo se elimina, sus membresías dejan de existir. |

---

## Observaciones sobre el EER

Las siguientes correcciones deben reflejarse en el diagrama actualizado:

1. **`Animo.fecha_registro`** — Atributo faltante. Necesario para el historial dinámico.
2. **`Habilidad.tipo_origen`** — Atributo faltante. Distingue habilidades del sistema vs. del usuario.
3. **Tablas intermedias N:M** — `Usuario_Habilidad` y `Usuario_Grupo_Membresia` deben dibujarse explícitamente en el EER (la guía penaliza relaciones M:N sin su tabla intermedia visible).
4. **`Meta.Id_habito`** — Debe marcarse como atributo opcional (nullable) en el diagrama.
