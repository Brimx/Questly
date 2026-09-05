# Diccionario de datos inicial — Questly

Versión: Entrega 1. Sujeto a cambios en Entrega 2 según la implementación real en PostgreSQL.

> Convenciones: **PK** = clave primaria · *FK* = clave foránea · NN = NOT NULL · N = nullable

---

## Usuario_persona

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_usuario** | SERIAL | NN | Identificador único del usuario. Clave primaria autoincrementada. |
| correo | VARCHAR(100) | NN | Correo electrónico. Debe ser único en el sistema. Usado para identificación. |
| nombre | VARCHAR(100) | NN | Nombre completo del usuario. |
| rol | VARCHAR(20) | NN | Rol dentro del sistema (ej: `'usuario'`, `'admin'`). Define permisos generales. |
| fecha_nacimiento | DATE | N | Fecha de nacimiento del usuario. Opcional; puede usarse para personalización futura. |
| descripcion_tu | TEXT | N | Descripción o biografía personal ingresada por el usuario. |
| puntos_experiencia | INT | NN | Puntos acumulados al completar hábitos y misiones. Valor inicial: 0. |
| nivel | INT | NN | Nivel del usuario, derivado de `puntos_experiencia`. Valor inicial: 1. |

---

## Habito_tarea

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_habito** | SERIAL | NN | Identificador único del hábito o tarea. Clave primaria. |
| *Id_usuario* | INT | NN | FK → `Usuario_persona`. Usuario dueño del hábito. `ON DELETE CASCADE`. |
| nombre | VARCHAR(150) | NN | Nombre descriptivo del hábito o tarea (ej: "Correr 30 minutos"). |
| nivel_importancia | INT | NN | Prioridad del hábito: 1 = baja, 2 = media, 3 = alta. |
| tiempo_invertido | INT | N | Tiempo estimado o acumulado en minutos para completar el hábito. |
| fecha_inicio | DATE | NN | Fecha en que comienza el seguimiento del hábito. |
| fecha_final | DATE | N | Fecha estimada de finalización. NULL si el hábito es indefinido (ej: hábito diario permanente). |
| frecuencia | VARCHAR(20) | NN | Periodicidad del hábito: `'diario'`, `'semanal'`, `'mensual'`, etc. |

---

## Animo

> ⚠️ El atributo `fecha_registro` no aparece en el EER inicial pero es necesario para el historial dinámico (ver Supuesto S3). Debe agregarse al diagrama.

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_animo** | SERIAL | NN | Identificador único del registro de ánimo. Clave primaria. |
| *Id_usuario* | INT | NN | FK → `Usuario_persona`. Usuario al que pertenece el registro. `ON DELETE CASCADE`. |
| estado_actual | VARCHAR(30) | NN | Estado de ánimo registrado (ej: `'feliz'`, `'neutral'`, `'triste'`, `'estresado'`). |
| comentario | TEXT | N | Nota opcional del usuario sobre su estado de ánimo en ese momento. |
| fecha_registro | TIMESTAMP | NN | **Atributo faltante en EER.** Marca de tiempo del registro; necesaria para construir historial. |

---

## Recordatorio

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_recordatorio** | SERIAL | NN | Identificador único del recordatorio. Clave primaria. |
| *Id_habito* | INT | NN | FK → `Habito_tarea`. Hábito al que está asociado el recordatorio. Política de borrado pendiente (ver Entrega 2). |
| fecha_hora | TIMESTAMP | NN | Fecha y hora exacta en que se activa el recordatorio. |
| mensaje | TEXT | NN | Contenido del recordatorio que se muestra al usuario. |
| repeticion | VARCHAR(20) | N | Frecuencia de repetición: `'ninguna'`, `'diaria'`, `'semanal'`. NULL si es único. |

---

## Meta

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_meta** | SERIAL | NN | Identificador único de la meta. Clave primaria. |
| *Id_usuario* | INT | NN | FK → `Usuario_persona`. Usuario dueño de la meta. `ON DELETE CASCADE`. |
| *Id_habito* | INT | N | FK → `Habito_tarea`. NULL si la meta es independiente de un hábito. `ON DELETE SET NULL`. |
| descripcion | TEXT | NN | Descripción clara de lo que se quiere lograr (ej: "Leer 12 libros este año"). |
| valor_objetivo | NUMERIC(10,2) | N | Valor cuantificable que representa el logro (ej: 30 días, 10 km, 12 libros). NULL si la meta es cualitativa. |
| fecha_limite | DATE | N | Fecha límite para alcanzar la meta. NULL si no tiene plazo definido. |

---

## Estadistica

> Las estadísticas son calculadas dinámicamente (ver Supuesto S4). La implementación definitiva se decidirá en Entrega 2.

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_estadistica** | SERIAL | NN | Identificador único del registro. Clave primaria. |
| *Id_habito* | INT | NN | FK → `Habito_tarea`. Hábito al que corresponden las estadísticas. `ON DELETE CASCADE`. |
| total_completado | INT | NN | Número total de veces que el hábito fue marcado como completado. Valor inicial: 0. |
| porcentaje_cumplido | NUMERIC(5,2) | N | Porcentaje de cumplimiento sobre el período de seguimiento. Calculado dinámicamente. |
| racha_actual | INT | NN | Días o períodos consecutivos en que el hábito fue completado sin interrupción. Valor inicial: 0. |

---

## Habilidad

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_habilidad** | SERIAL | NN | Identificador único de la habilidad. Clave primaria. |
| nombre_habilidad | VARCHAR(100) | NN | Nombre de la habilidad (ej: `'Disciplina'`, `'Meditación diaria'`). |
| descripcion | TEXT | N | Descripción de lo que representa la habilidad o cómo se desbloquea. |
| nivel_habilidad | INT | NN | Nivel actual de la habilidad. Valor inicial: 1. |
| tipo_origen | VARCHAR(20) | NN | Indica si la habilidad fue creada por el `'sistema'` o por el `'usuario'` (ver Supuesto S6). |

---

## Recompensa

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_recompensa** | SERIAL | NN | Identificador único de la recompensa. Clave primaria. |
| nombre | VARCHAR(100) | NN | Nombre de la recompensa (ej: `'Racha de fuego'`, `'Maestro del hábito'`). |
| descripcion | TEXT | N | Descripción de lo que representa la recompensa y cómo se obtiene. |
| puntos_necesarios | INT | NN | Puntos de experiencia requeridos para que el usuario la desbloquee. Debe ser > 0. |

---

## Tablas intermedias (relaciones N:M)

### Usuario_Habilidad

Registra qué habilidades ha desbloqueado cada usuario.

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_usuario** | INT | NN | FK → `Usuario_persona`. `ON DELETE CASCADE`. |
| **Id_habilidad** | INT | NN | FK → `Habilidad`. `ON DELETE CASCADE`. |
| fecha_obtenida | DATE | NN | Fecha en que el usuario desbloqueó la habilidad. |

PK compuesta: (`Id_usuario`, `Id_habilidad`)

---

### Grupo

Representa un grupo de usuarios que colaboran en misiones compartidas.

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_grupo** | SERIAL | NN | Identificador único del grupo. Clave primaria. |
| *Id_usuario_lider* | INT | N | FK → `Usuario_persona`. Usuario que lidera el grupo. `ON DELETE SET NULL`. |
| nombre_grupo | VARCHAR(100) | NN | Nombre del grupo. |
| descripcion | TEXT | N | Descripción del propósito del grupo. |
| fecha_creacion | DATE | NN | Fecha en que se creó el grupo. |

---

### Usuario_Grupo_Membresia

Registra la pertenencia de usuarios a grupos (relación N:M entre Usuario y Grupo).

| Columna | Tipo | Nulable | Descripción |
|---|---|---|---|
| **Id_usuario** | INT | NN | FK → `Usuario_persona`. `ON DELETE CASCADE`. |
| **Id_grupo** | INT | NN | FK → `Grupo`. `ON DELETE CASCADE`. |
| rol_en_grupo | VARCHAR(20) | N | Rol del usuario en el grupo: `'lider'` o `'miembro'`. |
| fecha_ingreso | DATE | NN | Fecha en que el usuario se unió al grupo. |

PK compuesta: (`Id_usuario`, `Id_grupo`)
