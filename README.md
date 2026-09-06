# Questly — Sistema de Progreso y Gestión de Hábitos

Plataforma de seguimiento de hábitos, tareas y objetivos personales o grupales con mecánicas de gamificación (niveles, experiencia, misiones, recompensas). Inspirada en juegos RPG para mantener la motivación del usuario.

## Integrantes

| Nombre             | GitHub   |
|--------------------|----------|
| Santiago Montenegro | @Brimx  |
| Juan Tamayo         | @juantamayocordoba |
| Cristian Pérez     | —        |
| María Mercedes     | —        |

**Institución:** Universidad Popular del Cesar · Facultad de Ingenierías y Tecnológicas  
**Asignatura:** Base de Datos I · Semestre 2026  
**Motor:** PostgreSQL 16+  
**Repositorio:** https://github.com/Brimx/Questly  
**Entrega actual:** tag `entrega-1`

> Nota: el PDF original se titula *Goshi*; *Questly* es el nombre actual del mismo sistema.

## Estructura del repositorio

```
questly/
├── docs/
│   ├── planteamiento.md           # Descripción del dominio y problema
│   ├── requisitos-y-supuestos.md  # Requisitos funcionales e interrogatorio
│   ├── diccionario-de-datos.md    # Diccionario inicial tabla por tabla
│   ├── esquema-relacional.md      # Esquema relacional con políticas de FK
│   └── Questly_Entrega1.pdf       # PDF entrega (no modificar)
├── diagramas/                     # Copias visibles del PDF, fuente en docs/*.pdf
│   ├── eer-chen.png
│   ├── esquema-relacional.png
│   ├── especializacion-usuario.png
│   └── README.md                  # Fuente y desfase conocido vs docs/
└── migraciones/                   # Scripts SQL numerados (desde Entrega 2)
```

## Etiquetas de entrega

| Tag | Contenido |
|-----|-----------|
| `entrega-1` | Planteamiento, EER, esquema relacional y diccionario de datos |
| `entrega-2` | Implementación SQL, consultas y normalización *(pendiente)* |
| `entrega-final` | Sistema completo con funciones, triggers y seguridad *(pendiente)* |
