# Diagramas Chen de Questly

## Diagramas

Todos los archivos finales usan notación Chen: entidades en rectángulos, atributos en óvalos y relaciones en rombos. Las cardinalidades se indican como mínimo..máximo en cada extremo.

- `Questly-EER-Chen.png` / `.svg`: vista general con las ocho entidades base y todas las relaciones.
- `Questly-Usuarios-Habitos-Chen.png` / `.svg`: atributos completos de usuario, hábito, meta y recordatorio.
- `Questly-Perfil-Chen.png` / `.svg`: atributos de usuario, ánimo e habilidad.
- `Questly-Seguimiento-Chen.png` / `.svg`: hábito, eventos de cumplimiento y métricas derivadas.
- `Questly-Recompensas-Chen.png` / `.svg`: recompensas, asociación opcional con hábitos y obtenciones N:M.
- `Questly-Diagramas-Chen.html`: visor HTML interactivo con zoom y navegación para todos los diagramas.

`Usuario_Recompensa` se representa conceptualmente como la relación `obtiene`, con `fecha_obtencion` como atributo; físicamente se implementa mediante una tabla asociativa con PK compuesta. `estadistica_habito` no aparece como entidad porque es una vista derivada de `Cumplimiento`; sus métricas se muestran como atributos derivados en el subdiagrama de seguimiento.

## Fuentes Mermaid editables

Los códigos completos para editar/renderizar con Mermaid están en [`mermaid/`](mermaid/README.md) (`Questly-EER-Chen.mmd` y los cuatro subdiagramas). Se validaron con el MCP Mermaid usando `flowchart`, no `erDiagram`, para evitar patas de cuervo.

Mermaid no ofrece óvalos Chen nativos: las cápsulas de los `.mmd` representan los atributos de forma aproximada. Los diagramas finales SVG y PNG de este directorio mantienen fidelidad geométrica estricta (óvalos Chen, rombos y rectángulos con fondo blanco) y se toman como la representación gráfica oficial.
