# Sustentación Questly

Deck HTML autocontenido para la sustentación de la Entrega 2.

- **Archivo:** [`Sustentacion-Questly.html`](Sustentacion-Questly.html)
- **Formato:** escenario fijo 1920×1080 (16:9) escalado al navegador.
- **Diagramas:** SVG copiados desde `../diagramas/` a `assets/`.
- **Fuente de contenido:** `Guia_Sustentacion_Base_Datos_Questly_Corregida.pdf`, `migraciones/001_esquema_questly.sql`, `migraciones/002_datos_semilla.sql` y `docs/Esquema-Relacional-Questly.md`.

## Orden de exposición

| Bloque | Diapositivas | Contenido |
|---|---|---|
| 01 | 3–7 | Modelo: nueve tablas, relaciones, vista calculada. Compañero 1. |
| 02 | 8–14 | Diagramas: EER completo, cambios en el EER y subdiagramas. Compañero 4 (solo el EER). |
| 03 | 15–19 | Atributos nuevos, restricciones de dominio, integridad y reglas de borrado. Compañero 3. |
| 04 | 20–25 | DROP/INSERT/DELETE, migración vigente, consultas de métricas y FAQ. Compañero 2. |
| Cierre | 26–27 | Tres ideas y cierre. |

Los nombres no aparecen en las diapositivas; el orden anterior es solo para repartir la exposición.

## Navegación

- `→`, `↓`, `Espacio`, `PgDn`: siguiente.
- `←`, `↑`, `PgUp`: anterior.
- `F`: pantalla completa.
- `E`: modo edición (texto editable). `Ctrl+S` descarga el HTML con los cambios.
- Rueda del ratón y deslizamiento táctil también navegan.

## Exportar a PDF

```sh
bash ~/.agents/skills/frontend-slides/scripts/export-pdf.sh \
  presentacion/Sustentacion-Questly.html \
  presentacion/Sustentacion-Questly.pdf
```

El primer uso descarga Chromium para Playwright. Las animaciones no se conservan en el PDF.
