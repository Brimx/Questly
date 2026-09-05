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
9. Permitir que los usuarios se organicen en grupos y colaboren en misiones compartidas.
10. Configurar recordatorios asociados a hábitos o tareas.

## Supuestos y decisiones de diseño

Las siguientes ambigüedades fueron identificadas durante el análisis del dominio. Cada una documenta la decisión tomada y su impacto en el diseño.

---

### S1 — Existencia de hábitos sin usuario

**Ambigüedad:** ¿Puede existir un hábito o tarea en el sistema sin estar asociado a un usuario?

**Decisión:** No. Un hábito pertenece siempre a un usuario registrado. No tiene sentido de negocio que exista un hábito sin dueño. Si un usuario es eliminado del sistema, todos sus hábitos y tareas se eliminan automáticamente.

**Implicación en diseño:** La clave foránea `Id_usuario` en `Habito_tarea` tiene política `ON DELETE CASCADE`. Participación total de `Habito_tarea` en la relación con `Usuario_persona`.

---

### S2 — Pertenencia de usuarios a grupos

**Ambigüedad:** ¿Puede un usuario pertenecer a más de un grupo simultáneamente?

**Decisión:** Sí. Un usuario puede ser miembro de múltiples grupos al mismo tiempo. Por ejemplo, un usuario puede pertenecer a un grupo de hábitos de ejercicio y a otro de lectura en paralelo.

**Implicación en diseño:** La relación entre `Usuario` y `Grupo` es N:M. Se requiere una tabla intermedia `Usuario_Grupo_Membresia` que registre qué usuario pertenece a qué grupo, incluyendo su rol (líder o miembro) y la fecha de ingreso.

---

### S3 — Naturaleza del registro de ánimo

**Ambigüedad:** ¿El campo `estado_actual` de la entidad `Animo` representa el estado presente del usuario o un historial de registros?

**Decisión:** El ánimo se registra de forma dinámica: cada vez que el usuario reporta cómo se siente, se crea un nuevo registro con marca de tiempo. Esto permite construir un historial y generar estadísticas sobre el estado emocional a lo largo del tiempo.

**Implicación en diseño:** La entidad `Animo` debe incluir el atributo `fecha_registro` (TIMESTAMP NOT NULL), que no aparece en el diagrama EER inicial. **Este atributo debe agregarse al diagrama en la corrección.** La relación entre `Usuario_persona` y `Animo` es 1:N.

---

### S4 — Cálculo de estadísticas

**Ambigüedad:** ¿Los valores de `total_completado`, `porcentaje_cumplido` y `racha_actual` se almacenan como datos fijos o se calculan en tiempo real?

**Decisión:** Las estadísticas se calculan de forma dinámica a partir de los registros de cumplimiento existentes en el sistema. No se almacenan como valores estáticos que requieran actualización manual. En la implementación se materializarán como consultas o vistas calculadas.

**Implicación en diseño:** La tabla `Estadistica` es conceptual en esta entrega. Su estructura de implementación definitiva (tabla actualizable vs. vista calculada) se definirá en la Entrega 2.

---

### S5 — Independencia de las metas

**Ambigüedad:** ¿Una meta debe estar obligatoriamente ligada a un hábito específico?

**Decisión:** No. Una meta puede existir de forma independiente sin depender de un hábito (ej: "leer 12 libros este año", "ahorrar para un viaje"). La asociación con un hábito es opcional.

**Implicación en diseño:** La clave foránea hacia `Habito_tarea` en la tabla `Meta` es nullable. Si el hábito asociado se elimina, la meta no se elimina; la FK se anula. Política: `ON DELETE SET NULL`.

---

### S6 — Origen de las habilidades

**Ambigüedad:** ¿Las habilidades son exclusivamente predefinidas por el sistema o también las puede crear el usuario?

**Decisión:** Las habilidades pueden tener dos orígenes: el sistema (habilidades predefinidas que se desbloquean automáticamente, como en un RPG) o el propio usuario (habilidades personalizadas que el usuario define según sus intereses).

**Implicación en diseño:** La entidad `Habilidad` debe incluir el atributo `tipo_origen` (VARCHAR: 'sistema' | 'usuario') para distinguir ambos casos.

---

## Decisiones pendientes (Entrega 2)

Las siguientes ambigüedades no tienen suficiente información aún para decidir y se resolverán en la siguiente entrega:

- **Recompensas:** ¿Cómo se registra que un usuario obtiene una recompensa? ¿Existe una tabla intermedia `Usuario_Recompensa`?
- **Recordatorios:** ¿Qué política de borrado aplica cuando se elimina el hábito asociado a un recordatorio?
- **Roles en grupo:** ¿Qué permisos específicos tiene un líder de grupo frente a un miembro regular?
