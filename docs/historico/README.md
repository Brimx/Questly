# Archivos históricos de Entrega 1

Estos archivos se conservan como referencia y **no deben ejecutarse** en la secuencia de instalación:

- `Questly-Entrega-1-original.sql`: SQL que estaba en `migraciones/` antes de la revisión.
- `Questly-Entrega-1-revisada.sql`: SQL recibido para comparar y fusionar. Sus correcciones se incorporaron en la migración canónica, conservando la lógica válida y ajustándola a los requisitos.
- `Diagrama-EER-Entrega-1.png`: imagen del EER anterior.

## Fusión y cambios conservados

Se conservaron las restricciones de dominio, claves únicas, hábitos, recordatorios, metas, habilidades y recompensas obtenidas que sí correspondían al problema. La versión recibida también se archivó sin alterarla. En la versión vigente:

- se separan DDL, semillas y consultas, y se eliminan los `DROP TABLE` destructivos del flujo de instalación;
- las metas pueden ser independientes (`habito_id` nullable, `ON DELETE SET NULL`);
- el estado de ánimo conserva hora (`TIMESTAMP`);
- las habilidades distinguen origen de sistema/usuario;
- los cumplimientos son eventos; la antigua tabla estática `estadistica` se reemplaza por `estadistica_habito`, una vista derivada;
- se registra la obtención N:M de recompensas con fecha;
- se descarta `Alumno` y `Tutor` como subtipos por decisión de dominio: `rol` queda en `Usuario_persona`.

El esquema vigente se crea con `migraciones/001_esquema_questly.sql`; los datos de ejemplo se cargan con `migraciones/002_datos_semilla.sql`.
