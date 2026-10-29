# Questly — Sistema de Progreso y Gestión de Hábitos

Plataforma de seguimiento de hábitos, tareas y objetivos personales o grupales con mecánicas de gamificación (niveles, experiencia, misiones, recompensas). Inspirada en juegos RPG para mantener la motivación del usuario.

## Integrantes

| Nombre             | GitHub   |
|--------------------|----------|
| Santiago Montenegro Muñoz | @Brimx  |
| Juan Tamayo Cordoba       | @juantamayocordoba |
| Cristian Andres Pérez     | —        |
| María Romero Fuentes      | —        |

**Institución:** Universidad Popular del Cesar · Facultad de Ingenierías y Tecnológicas  
**Asignatura:** Base de Datos I · Semestre 2026  
**Motor:** PostgreSQL 16+  
**Repositorio:** https://github.com/Brimx/Questly  
**Entrega actual:** tag `entrega-1`

>  *Questly* es el nombre actual del mismo sistema.

## Estructura del repositorio

```
questly/
├── docs/
│   ├── Planteamiento.md           # Descripción del dominio y problema
│   ├── Requisitos-y-Supuestos.md  # Requisitos funcionales e interrogatorio
│   ├── Esquema-Relacional-Questly.md      # Esquema relacional con políticas de FK
│   └── Questly-Presentacion.pdf       # PDF entrega
├── diagramas/                     # Copias visibles del PDF, fuente en docs/*.pdf
│   ├── Diagrama-EER-Chen.png
│   └── README.md                  # Fuente y desfase conocido vs docs/
└── migraciones/                   # Scripts SQL numerados (desde Entrega 2)
```

## Etiquetas de entrega

| Tag | Contenido |
|-----|-----------|
| `entrega-1` | Planteamiento, EER y esquema relacional |
| `entrega-2` | Implementación SQL, consultas y normalización |
| `entrega-final` | Sistema completo con funciones, triggers y seguridad |
