# Questly — Sistema de progreso y gestión de hábitos

Questly permite dar seguimiento a hábitos, tareas y metas con mecánicas de progreso y recompensas. Proyecto académico para Base de Datos I, PostgreSQL 16+.

**Entrega actual:** preparación de Entrega 2; la etiqueta de Git se crea después de validar el contenido final.

## Estructura

- `docs/Planteamiento.md`: descripción del dominio y problema.
- `docs/Requisitos-y-Supuestos.md`: requisitos y decisiones de diseño.
- `docs/Esquema-Relacional-Questly.md`: relaciones, claves, restricciones y correspondencia con el EER.
- `docs/Normalizacion-y-Dependencias.md`: auditoría de normalización.
- `docs/Evidencia-Indices.md`: índices y mediciones de consultas.
- `docs/historico/`: fuentes de Entrega 1 conservadas como referencia; no ejecutar.
- `diagramas/Questly-EER-Chen.png` y cuatro subdiagramas: EER y detalles por dominio, exclusivamente en notación Chen. Las fuentes editables Mermaid están en `diagramas/mermaid/`. Véase `diagramas/README.md`.
- `migraciones/001_esquema_questly.sql`: crea el esquema en una base vacía.
- `migraciones/002_datos_semilla.sql`: carga datos de demostración.
- `consultas/001_consultas_negocio.sql`: consultas de ejemplo.

## Instalación local

Ejecutar en orden sobre una base PostgreSQL vacía:

```sh
psql -d questly -f migraciones/001_esquema_questly.sql
psql -d questly -f migraciones/002_datos_semilla.sql
```

Las consultas de negocio se ejecutan aparte. No ejecutar los SQL archivados en `docs/historico/`.
