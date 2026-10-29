# Requisitos e interrogatorio — Questly

## Requisitos funcionales

1. Registrar nuevos usuarios con información personal (nombre, correo, fecha de nacimiento).
2. Permitir a los usuarios crear hábitos o tareas con nombre, frecuencia, fechas e importancia.
3. Registrar el cumplimiento diario de hábitos o tareas por parte del usuario.
4. Permitir establecer metas asociadas a hábitos o de forma independiente.
5. Mostrar estadísticas y gráficos del progreso del usuario a lo largo del tiempo.
6. Registrar y mostrar recompensas obtenidas al acumular puntos de experiencia.
7. Permitir consultar el historial de progreso y estado de ánimo de cada usuario.
8. Generar reportes del nivel de cumplimiento de hábitos en un período determinado.
9. Configurar recordatorios asociados a hábitos o tareas.

## Supuestos y decisiones de diseño

Las siguientes ambigüedades fueron identificadas durante el análisis del dominio. Cada una documenta la decisión tomada y su impacto en el diseño.

---

### S1 — Existencia de hábitos sin usuario

**Ambigüedad:** ¿Puede existir un hábito o tarea en el sistema sin estar asociado a un usuario?

**Decisión:** No. Un hábito pertenece siempre a un usuario registrado. No tiene sentido de negocio que exista un hábito sin dueño. Si un usuario es eliminado del sistema, todos sus hábitos y tareas se eliminan automáticamente.

**Implicación en diseño:** La clave foránea `Id_usuario` en `Habito_tarea` tiene política `ON DELETE CASCADE`. Participación total de `Habito_tarea` en la relación con `Usuario_persona`.

---

### S2 — Naturaleza del registro de ánimo

**Ambigüedad:** ¿El campo `estado_actual` de la entidad `Animo` representa el estado presente del usuario o un historial de registros?

**Decisión:** El ánimo se registra de forma dinámica: cada vez que el usuario reporta cómo se siente, se crea un nuevo registro con marca de tiempo. Esto permite construir un historial y generar estadísticas sobre el estado emocional a lo largo del tiempo.

**Implicación en diseño:** La entidad `Animo` debe incluir el atributo `fecha_registro` (TIMESTAMP NOT NULL), que no aparece en el diagrama EER inicial. **Este atributo debe agregarse al diagrama en la corrección.** La relación entre `Usuario_persona` y `Animo` es 1:N.

---

### S3 — Cálculo de estadísticas

**Ambigüedad:** ¿Los valores de `total_completado`, `porcentaje_cumplido` y `racha_actual` se almacenan como datos fijos o se calculan en tiempo real?

**Decisión:** Las estadísticas se calculan de forma dinámica a partir de los registros de cumplimiento existentes en el sistema. No se almacenan como valores estáticos que requieran actualización manual. En la implementación se materializarán como consultas o vistas calculadas.

**Decisión de implementación:** Se almacenan los eventos en `Cumplimiento`; `estadistica_habito` es una vista calculada, no una tabla editable. Resume cada hábito desde su primer período hasta el período actual (o su fecha final): frecuencia diaria por día calendario, semanal por semana ISO (lunes a domingo) y mensual por mes calendario. El porcentaje es períodos completados / períodos esperados. La racha cuenta períodos consecutivos completados hasta el último período esperado.

---

### S4 — Independencia de las metas

**Ambigüedad:** ¿Una meta debe estar obligatoriamente ligada a un hábito específico?

**Decisión:** No. Una meta puede existir de forma independiente sin depender de un hábito (ej: "leer 12 libros este año", "ahorrar para un viaje"). La asociación con un hábito es opcional.

**Implicación en diseño:** La clave foránea hacia `Habito_tarea` en la tabla `Meta` es nullable. Si el hábito asociado se elimina, la meta no se elimina; la FK se anula. Política: `ON DELETE SET NULL`.

---

### S5 — Origen de las habilidades

**Ambigüedad:** ¿Las habilidades son exclusivamente predefinidas por el sistema o también las puede crear el usuario?

**Decisión:** Las habilidades pueden tener dos orígenes: el sistema (habilidades predefinidas que se desbloquean automáticamente, como en un RPG) o el propio usuario (habilidades personalizadas que el usuario define según sus intereses).

**Decisión de implementación:** `Habilidad` incluye `tipo_origen` (`sistema` | `usuario`) y siempre pertenece a un usuario, que es quien tiene el progreso de esa habilidad. El origen distingue una habilidad predefinida por el sistema de una personalizada por el usuario.

---

### S6 — Especialización de usuarios

**Decisión:** No se modelan `Alumno` ni otros subtipos de usuario. Los roles se guardan en `Usuario_persona.rol`; no hay atributos exclusivos por subtipo que justifiquen una especialización.

### S7 — Borrado de recordatorios

**Decisión:** Si se elimina un hábito, se eliminan sus recordatorios (`ON DELETE CASCADE`), porque no tienen sentido sin el hábito asociado.

### S8 — Recompensas obtenidas

**Decisión:** `Usuario_Recompensa` registra la fecha en que cada usuario obtiene una recompensa. La clave compuesta `(usuario_id, recompensa_id)` limita a una obtención por usuario y recompensa. La recompensa no se puede borrar si ya fue otorgada (`ON DELETE RESTRICT`).
