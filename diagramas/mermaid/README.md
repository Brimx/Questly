# Fuentes Mermaid de Questly

Cada archivo `.mmd` es un diagrama completo y se puede copiar directamente en Mermaid Live Editor o editar desde un visor compatible. Se usa `flowchart` para representar Chen con rectángulos, rombos y conectores sin flechas; no usar `erDiagram`, porque genera patas de cuervo.

- `Questly-EER-Chen.mmd`: modelo completo, ocho entidades, relaciones, cardinalidades y atributos.
- `Questly-Usuarios-Habitos-Chen.mmd`: usuario, hábito, metas y recordatorios.
- `Questly-Perfil-Chen.mmd`: usuario, ánimo y habilidades.
- `Questly-Seguimiento-Chen.mmd`: cumplimiento y estadísticas derivadas.
- `Questly-Recompensas-Chen.mmd`: recompensas, asociaciones y obtenciones.

**Limitación visual:** Mermaid no tiene una forma de óvalo Chen en la versión del renderizador disponible; los atributos se expresan como cápsulas (`([atributo])`). Las claves están subrayadas en el texto. El MCP validó la sintaxis de los cinco archivos.
