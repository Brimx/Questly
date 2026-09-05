# Diagramas — Entrega 1

Fuente original sin modificar: `docs/Questly_Entrega1.pdf`, páginas 3-4.
El PDF no se altera por requisito de la entrega. Estas imágenes son copias
visibles para que el diagrama exista también en el repositorio
(la guía exige: *lo que no está en el repositorio no existe*).

| Archivo | Contenido | Página PDF |
|---|---|---|
| `eer-chen.png` | EER notación Chen (8 entidades) | p.3 |
| `esquema-relacional.png` | Esquema relacional pata de gallo | p.3 |
| `especializacion-usuario.png` | Especialización Usuario Individual/Grupo | p.4 |

## Desfase conocido vs `docs/*.md` (para Entrega 2)

1. Falta `Grupo` y las intermedias `Usuario_Habilidad`, `Usuario_Grupo_Membresia` en el dibujo (el .md ya las define).
2. Faltan `Animo.fecha_registro` (S3) y `Habilidad.tipo_origen` (S6) en el dibujo.
3. `Meta.Id_habito` debe marcarse opcional (S5).
4. Especialización de Usuario sin justificación: definir si se implementa o se descarta.
5. `Recordatorio`: definir política de borrado (hoy pendiente).

Ver detalle en `docs/esquema-relacional.md` § Observaciones y `docs/requisitos-y-supuestos.md`.
