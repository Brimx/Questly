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

## Caso de estudio con método del curso: Antes y después

Siguiendo la metodología requerida para la Entrega 2, se documenta a continuación el caso de optimización sobre una de las consultas de reunión más frecuentes: la búsqueda de hábitos por usuario (`habito_tarea.usuario_id`).

### 1. Consulta evaluada

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id_habito, nombre, frecuencia
FROM habito_tarea
WHERE usuario_id = 250;
```

### 2. Plan antes de crear el índice (`EXPLAIN ANALYZE`)

Sin índice secundario en la FK `usuario_id`, PostgreSQL se ve forzado a realizar un escaneo secuencial completo sobre todas las páginas de la tabla:

```text
Seq Scan on habito_tarea  (cost=0.00..625.00 rows=60 width=23) (actual time=0.025..0.985 rows=60.00 loops=1)
  Filter: (usuario_id = 250)
  Rows Removed by Filter: 29940
  Buffers: shared hit=250
Planning:
  Buffers: shared hit=21
Planning Time: 0.177 ms
Execution Time: 1.002 ms
```

### 3. Índice creado

```sql
CREATE INDEX idx_habito_tarea_usuario ON habito_tarea (usuario_id);
```

### 4. Plan después de crear el índice (`EXPLAIN ANALYZE`)

Con el índice B-Tree disponible, el planificador utiliza un escaneo por mapa de bits (`Bitmap Index Scan` + `Bitmap Heap Scan`), accediendo directamente a las páginas relevantes:

```text
Bitmap Heap Scan on habito_tarea  (cost=4.75..146.21 rows=60 width=23) (actual time=0.080..0.115 rows=60.00 loops=1)
  Recheck Cond: (usuario_id = 250)
  Heap Blocks: exact=60
  Buffers: shared hit=60 read=2
  ->  Bitmap Index Scan on idx_habito_tarea_usuario  (cost=0.00..4.74 rows=60 width=0) (actual time=0.069..0.069 rows=60.00 loops=1)
        Index Cond: (usuario_id = 250)
        Index Searches: 1
        Buffers: shared read=2
Planning:
  Buffers: shared hit=17
Planning Time: 0.087 ms
Execution Time: 0.127 ms
```

### 5. Conclusión y análisis comparativo

- **Costo estimado:** Se redujo de `625.00` a `146.21` (reducción del 76.6 %).
- **Bloques I/O accedidos (Buffers):** Pasó de leer 250 páginas en memoria a solo 62 páginas (60 en tabla + 2 de índice), disminuyendo la presión sobre la memoria en un 75.2 %.
- **Filas descartadas:** Se eliminó por completo el descarte innecesario de 29 940 filas.
- **Tiempo de ejecución:** Mejoró de `1.002 ms` a `0.127 ms`, lo que representa una aceleración de **~7.9x** en la consulta.
- **Justificación:** Dado que las relaciones `usuario_persona` → `habito_tarea` son centrales en la aplicación para listar tableros, calcular rachas y verificar cumplimientos, este índice sobre la clave foránea es indispensable para la escalabilidad del sistema.

## Método y resultados complementarios de la ejecución local

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
