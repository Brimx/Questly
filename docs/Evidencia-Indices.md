# Índices y evidencia con `EXPLAIN ANALYZE`

La migración define índices para las FK y filtros previstos. Las claves primarias y restricciones `UNIQUE` ya generan índices propios en PostgreSQL.

## Índices explícitos

| Índice | Uso previsto |
|---|---|
| `idx_habito_tarea_usuario (usuario_id)` | Listar hábitos de un usuario y resolver la FK al eliminarlo. |
| `idx_meta_habito (habito_id)` | Buscar metas asociadas y resolver la FK del hábito. |
| `idx_recompensa_habito (habito_id)` | Buscar recompensas asociadas y resolver la FK del hábito. |
| `idx_usuario_recompensa_recompensa (recompensa_id)` | Consultar obtenciones por recompensa; la PK compuesta ya cubre búsquedas por usuario. |
| `idx_recordatorio_habito (habito_id)` | Listar recordatorios y resolver su borrado en cascada. |
| `idx_habilidad_usuario (usuario_id)` | Consultar habilidades y resolver su borrado en cascada. |
| `idx_animo_usuario_fecha (usuario_id, fecha_registro)` | Historial de ánimo de una persona ordenado o filtrado por tiempo. |
| `idx_cumplimiento_fecha (fecha_cumplimiento)` | Reportes y filtros de cumplimiento por período. |

La restricción única de `cumplimiento(habito_id, fecha_cumplimiento)` crea un índice compuesto que también sirve para búsquedas por hábito. La PK compuesta de `usuario_recompensa(usuario_id, recompensa_id)` cubre el lado de usuario.

## Método y resultados de la ejecución local

Se instalaron migración y semillas en una base PostgreSQL temporal; después se añadieron datos sintéticos para que el planificador tuviera volumen suficiente para comparar índices. La prueba usó aproximadamente 20 000 filas por tabla consultada, ejecutó `ANALYZE` y midió cuatro filtros representativos. La base temporal y sus datos se eliminaron al terminar; no forman parte de las semillas versionadas.

Consultas ejecutadas:

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_habito FROM habito_tarea WHERE usuario_id = 505;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_animo FROM animo
WHERE usuario_id = 505
  AND fecha_registro >= CURRENT_TIMESTAMP - INTERVAL '14 days';

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_recordatorio FROM recordatorio WHERE habito_id = 15011;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id_cumplimiento FROM cumplimiento
WHERE fecha_cumplimiento >= CURRENT_DATE - 7;
```

Resumen del plan obtenido en la ejecución local:

| Filtro | Plan observado | Índice usado | Tiempo observado |
|---|---|---|---:|
| Hábitos por usuario | `Bitmap Heap Scan` + `Bitmap Index Scan` | `idx_habito_tarea_usuario` | 0.183 ms |
| Ánimo por usuario y fecha | `Index Scan` | `idx_animo_usuario_fecha` | 0.052 ms |
| Recordatorios por hábito | `Index Scan` | `idx_recordatorio_habito` | 0.023 ms |
| Cumplimientos recientes | `Bitmap Heap Scan` + `Bitmap Index Scan` | `idx_cumplimiento_fecha` | 0.213 ms |

Los tiempos son una observación de una ejecución local, no un benchmark ni una promesa de rendimiento. El plan elegido puede variar según el volumen, distribución, versión, caché y estadísticas del entorno; con las pocas filas de las semillas es normal que PostgreSQL prefiera un escaneo secuencial.
