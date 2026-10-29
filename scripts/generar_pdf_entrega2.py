import os
import sys
from pathlib import Path
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, KeepTogether, PageBreak, HRFlowable
)
from reportlab.pdfgen import canvas

BASE_DIR = Path('/home/santi/Proyectos/questly')
DOCS_DIR = BASE_DIR / 'docs'
DIAG_DIR = BASE_DIR / 'diagramas'
PDF_PATH = DOCS_DIR / 'Questly-Entrega-2.pdf'

class NumberedCanvas(canvas.Canvas):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        if self._pageNumber == 1:
            return  # No headers or footers on cover page
        self.saveState()
        self.setFont("Helvetica-Bold", 8)
        self.setFillColor(colors.HexColor("#475569"))
        self.drawString(40, 755, "QUESTLY — SISTEMA DE PROGRESO Y GESTIÓN DE HÁBITOS")
        self.setFont("Helvetica", 8)
        self.drawRightString(572, 755, "SEGUNDA ENTREGA • BASES DE DATOS I")
        self.setStrokeColor(colors.HexColor("#cbd5e1"))
        self.setLineWidth(0.6)
        self.line(40, 747, 572, 747)

        self.line(40, 40, 572, 40)
        self.drawString(40, 28, "Documento de Entrega 2 • Repositorio: github.com/Brimx/Questly (Etiqueta: entrega-2)")
        page_text = f"Página {self._pageNumber} de {page_count}"
        self.drawRightString(572, 28, page_text)
        self.restoreState()

def build_pdf():
    doc = SimpleDocTemplate(
        str(PDF_PATH),
        pagesize=letter,
        leftMargin=40,
        rightMargin=40,
        topMargin=50,
        bottomMargin=50
    )

    styles = getSampleStyleSheet()

    c_primary = colors.HexColor("#0f172a")     # Slate 900
    c_secondary = colors.HexColor("#1e293b")   # Slate 800
    c_accent = colors.HexColor("#0f766e")      # Teal 700
    c_muted = colors.HexColor("#475569")       # Slate 600
    c_text = colors.HexColor("#1e293b")

    title_cover = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=30,
        leading=36,
        textColor=c_primary,
        alignment=0
    )
    sub_cover = ParagraphStyle(
        'CoverSub',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=15,
        leading=20,
        textColor=c_accent,
        alignment=0
    )
    tag_cover = ParagraphStyle(
        'CoverTag',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=11,
        leading=16,
        textColor=c_muted,
        alignment=0
    )
    h1 = ParagraphStyle(
        'Heading1_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=14,
        leading=18,
        textColor=c_primary,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )
    h2 = ParagraphStyle(
        'Heading2_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=15,
        textColor=c_accent,
        spaceBefore=8,
        spaceAfter=4,
        keepWithNext=True
    )
    body = ParagraphStyle(
        'Body_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13,
        textColor=c_text,
        spaceAfter=5
    )
    caption = ParagraphStyle(
        'Caption_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Oblique',
        fontSize=8,
        leading=11,
        textColor=c_muted,
        alignment=1,
        spaceBefore=3,
        spaceAfter=6
    )
    th_style = ParagraphStyle(
        'TH_Custom',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=8,
        leading=10,
        textColor=colors.white,
        alignment=0
    )
    td_style = ParagraphStyle(
        'TD_Custom',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=7.5,
        leading=9.5,
        textColor=c_text,
        alignment=0
    )
    td_bold = ParagraphStyle(
        'TDBold_Custom',
        parent=td_style,
        fontName='Helvetica-Bold'
    )
    code_snippet = ParagraphStyle(
        'CodeSnippet',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=7,
        leading=9.5,
        textColor=colors.HexColor("#0f172a"),
        backColor=colors.HexColor("#f1f5f9"),
        borderPadding=3,
        spaceAfter=4
    )

    story = []

    # ==========================
    # PORTADA
    # ==========================
    story.append(Spacer(1, 30))
    story.append(Paragraph("SEGUNDA ENTREGA • BASES DE DATOS I", ParagraphStyle('SuperHeader', fontName='Helvetica-Bold', fontSize=10, leading=12, textColor=c_accent)))
    story.append(Spacer(1, 10))
    story.append(Paragraph("Questly", title_cover))
    story.append(Paragraph("Sistema de Progreso y Gestión de Hábitos", sub_cover))
    story.append(Spacer(1, 6))
    story.append(Paragraph("Documento Ejecutivo de Implementación y Navegación del Repositorio", tag_cover))
    story.append(Spacer(1, 20))

    story.append(HRFlowable(width="100%", thickness=2, color=c_accent, spaceBefore=0, spaceAfter=20))

    repo_box = [
        [Paragraph("<b>Repositorio GitHub oficial:</b>", body), Paragraph("<font color='#0f766e'><u>https://github.com/Brimx/Questly</u></font>", body)],
        [Paragraph("<b>Etiqueta Git de entrega:</b>", body), Paragraph("<b><font color='#0f766e'>entrega-2</font></b> (commit a6d6827)", body)],
        [Paragraph("<b>Motor de base de datos:</b>", body), Paragraph("PostgreSQL 16+ (Validado en PostgreSQL 18.6)", body)],
        [Paragraph("<b>Semestre académico:</b>", body), Paragraph("2026-II • Programa de Ingeniería de Sistemas", body)],
        [Paragraph("<b>Institución:</b>", body), Paragraph("Universidad Popular del Cesar (UPC)", body)],
        [Paragraph("<b>Ubicación y Fecha:</b>", body), Paragraph("Valledupar, Cesar • Octubre de 2026", body)],
    ]
    t_box = Table(repo_box, colWidths=[160, 372])
    t_box.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,-1), colors.HexColor("#f8fafc")),
        ('BOX', (0,0), (-1,-1), 1, colors.HexColor("#cbd5e1")),
        ('INNERGRID', (0,0), (-1,-1), 0.5, colors.HexColor("#e2e8f0")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 10),
        ('RIGHTPADDING', (0,0), (-1,-1), 10),
    ]))
    story.append(t_box)

    story.append(Spacer(1, 35))
    story.append(Paragraph("INTEGRANTES DEL GRUPO", ParagraphStyle('IntLabel', fontName='Helvetica-Bold', fontSize=10, leading=12, textColor=c_primary)))
    story.append(Spacer(1, 8))

    integrantes_data = [
        ["Juan Tamayo Córdoba", "juan.tamayo.cordoba@gmail.com"],
        ["María Romero Fuentes", "maria.romero@unicesar.edu.co"],
        ["Santiago Montenegro Muñoz", "santi00nn@gmail.com"],
        ["Cristian Andrés Pérez", "cristian.perez@unicesar.edu.co"],
    ]
    t_int = Table([[Paragraph(f"<b>{row[0]}</b>", body), Paragraph(row[1], body)] for row in integrantes_data], colWidths=[240, 292])
    t_int.setStyle(TableStyle([
        ('LINEBELOW', (0,0), (-1,-1), 0.5, colors.HexColor("#e2e8f0")),
        ('TOPPADDING', (0,0), (-1,-1), 5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 5),
        ('LEFTPADDING', (0,0), (-1,-1), 0),
    ]))
    story.append(t_int)

    story.append(PageBreak())

    # ==========================
    # PÁGINA 2: RESUMEN Y NAVEGACIÓN
    # ==========================
    story.append(Paragraph("1. Resumen Ejecutivo y Guía de Navegación", h1))
    story.append(Paragraph(
        "Questly es una plataforma diseñada para convertir la formación de hábitos en una experiencia gamificada "
        "inspirada en los juegos de rol (RPG). La <b>Entrega 2 — Implementación</b> materializa el modelo conceptual "
        "en una base de datos relacional robusta en PostgreSQL 16+, con integridad declarativa estricta, datos semilla "
        "coherentes, auditoría de normalización formal, banco de consultas de negocio y evidencia experimental de optimización "
        "con índices medidos mediante <code>EXPLAIN (ANALYZE, BUFFERS)</code>.",
        body
    ))
    story.append(Spacer(1, 4))
    story.append(Paragraph("<b>Mapeo de Entregables en el Repositorio Git</b>", h2))
    story.append(Paragraph(
        "Correspondencia entre los requerimientos de la rúbrica y los archivos del repositorio oficial (etiqueta <code>entrega-2</code>):",
        body
    ))

    nav_data = [
        [Paragraph("Requisito de la Guía", th_style), Paragraph("Ruta en el Repositorio", th_style), Paragraph("Descripción y Contenido Clave", th_style)],
        [
            Paragraph("<b>Observaciones Entrega 1</b>", td_style),
            Paragraph("<code>docs/historico/README.md</code>", td_style),
            Paragraph("Resumen de retroalimentación recibida y justificación técnica de cambios respecto a Entrega 1.", td_style)
        ],
        [
            Paragraph("<b>DDL de Migraciones</b>", td_style),
            Paragraph("<code>migraciones/001_esquema_questly.sql</code>", td_style),
            Paragraph("Esquema completo reconstruible en base vacía (9 tablas físicas, restricciones y vista calculada).", td_style)
        ],
        [
            Paragraph("<b>Datos Semilla</b>", td_style),
            Paragraph("<code>migraciones/002_datos_semilla.sql</code>", td_style),
            Paragraph("Población coherente y suficiente para todas las consultas (usuarios, hábitos, cumplimientos, etc.).", td_style)
        ],
        [
            Paragraph("<b>Auditoría Normalización</b>", td_style),
            Paragraph("<code>docs/Normalizacion-y-Dependencias.md</code>", td_style),
            Paragraph("Dependencias funcionales del dominio, análisis riguroso de 1FN, 2FN, 3FN/BCNF y justificaciones.", td_style)
        ],
        [
            Paragraph("<b>Banco de Consultas</b>", td_style),
            Paragraph("<code>consultas/001_consultas_negocio.sql</code>", td_style),
            Paragraph("10 consultas comentadas con variedad: reuniones 3+ tablas, IS NULL, GROUP BY/HAVING, CTE y vista.", td_style)
        ],
        [
            Paragraph("<b>Índices con Evidencia</b>", td_style),
            Paragraph("<code>docs/Evidencia-Indices.md</code>", td_style),
            Paragraph("Caso de estudio antes/después con <code>EXPLAIN ANALYZE</code> en FK y tabla de índices secundarios.", td_style)
        ],
        [
            Paragraph("<b>Diccionario Actualizado</b>", td_style),
            Paragraph("<code>docs/Esquema-Relacional-Questly.md</code>", td_style),
            Paragraph("Diccionario columna por columna: tipos, nulabilidad, restricciones y significado de negocio.", td_style)
        ],
        [
            Paragraph("<b>Diagramas Chen Oficiales</b>", td_style),
            Paragraph("<code>diagramas/</code> y <code>diagramas/mermaid/</code>", td_style),
            Paragraph("Diagrama EER completo y 4 subdiagramas en SVG/PNG con notación Chen y fuentes Mermaid.", td_style)
        ],
    ]
    t_nav = Table(nav_data, colWidths=[125, 155, 252])
    t_nav.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cbd5e1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f8fafc")]),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_nav)

    # ==========================
    # PÁGINA 3: CORRECCIONES E1
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("2. Correcciones de la Entrega 1 Incorporadas", h1))
    story.append(Paragraph(
        "A partir de la retroalimentación recibida y el análisis profundo del problema, se refinó el modelo de datos. "
        "Las versiones preliminares se conservaron en <code>docs/historico/</code> sin alterar, integrando en el esquema vigente "
        "las siguientes mejoras fundamentales:", body
    ))
    correcciones = [
        ("Desacoplamiento de Scripts", "Se eliminaron instrucciones destructivas (<code>DROP TABLE</code>) del flujo estándar, separando DDL (migración 001), datos semilla (migración 002) y consultas de negocio."),
        ("Precisión Temporal en Ánimo", "La entidad <code>Animo</code> pasó de registrar una fecha simple a una marca temporal completa (<code>TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP</code>) para permitir análisis cronológicos intradía."),
        ("Independencia de Metas", "La clave foránea <code>habito_id</code> en <code>Meta</code> se definió como nullable con política <code>ON DELETE SET NULL</code>, permitiendo metas globales independientes del ciclo de vida de un hábito."),
        ("Eventos de Cumplimiento vs. Vistas Calculadas", "Se sustituyó la antigua tabla estática <code>estadistica</code> por un modelo de hechos basado en la entidad <code>Cumplimiento</code>. Las estadísticas de progreso (totales, porcentaje y racha) se generan dinámicamente mediante la vista <code>estadistica_habito</code>, erradicando anomalías de actualización."),
        ("Asociación N:M de Recompensas", "Se formalizó la tabla asociativa <code>Usuario_Recompensa</code> con clave primaria compuesta <code>(usuario_id, recompensa_id)</code> y atributo descriptivo <code>fecha_obtencion</code>, asegurando integridad histórica con <code>ON DELETE RESTRICT</code> sobre la recompensa."),
        ("Simplificación de Roles", "Se descartaron subtipos vacíos (<code>Alumno</code>, <code>Tutor</code>), modelando el rol como un atributo acotado en <code>Usuario_persona.rol</code> mediante restricción <code>CHECK</code>.")
    ]
    for title_c, desc_c in correcciones:
        story.append(Paragraph(f"• <b>{title_c}:</b> {desc_c}", body))
        story.append(Spacer(1, 2))

    story.append(Spacer(1, 10))
    story.append(Paragraph("3. Notación Chen y Arquitectura Conceptual", h1))
    story.append(Paragraph(
        "Cumpliendo con los lineamientos de diseño, todos los diagramas del sistema han sido elaborados "
        "estrictamente bajo <b>notación Chen</b>: entidades representadas en rectángulos, relaciones en rombos, "
        "atributos en elipses (con claves primarias subrayadas y atributos derivados con trazo discontinuo) y "
        "cardinalidades explícitas en formato <code>mín..máx</code> en cada extremo.", body
    ))
    story.append(Paragraph(
        "Para garantizar fidelidad geométrica, los diagramas finales se generaron en SVG vectorial con óvalos Chen y "
        "se renderizaron a PNG en alta definición, manteniendo las fuentes Mermaid editables en <code>diagramas/mermaid/</code>.", body
    ))

    # ==========================
    # PÁGINA 4: DIAGRAMA EER GENERAL
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("3.1 Diagrama EER General de Questly (Notación Chen)", h2))
    story.append(Paragraph(
        "El diagrama general comprende las ocho entidades base y todas sus relaciones funcionales, ofreciendo "
        "una visión arquitectónica completa de la plataforma:", body
    ))

    img_eer = DIAG_DIR / 'Questly-EER-Chen.png'
    if img_eer.exists():
        w_img = 510
        h_img = w_img / (6074 / 2776)
        story.append(Spacer(1, 6))
        story.append(Image(str(img_eer), width=w_img, height=h_img))
        story.append(Paragraph("<b>Figura 1:</b> Diagrama EER General de Questly en notación Chen (archivo: <code>diagramas/Questly-EER-Chen.png</code>).", caption))

    # ==========================
    # PÁGINA 5: SUBDIAGRAMAS USUARIOS Y HÁBITOS
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("3.2 Subdiagrama: Usuarios, Hábitos y Planificación", h2))
    story.append(Paragraph(
        "Detalla la estructura central de la aplicación: el usuario como gestor de hábitos, la planificación temporal "
        "de sus metas cuantificables y las alertas programadas mediante recordatorios:", body
    ))

    img_usr = DIAG_DIR / 'Questly-Usuarios-Habitos-Chen.png'
    if img_usr.exists():
        w_img = 490
        h_img = w_img / (3754 / 1534)
        story.append(Spacer(1, 6))
        story.append(Image(str(img_usr), width=w_img, height=h_img))
        story.append(Paragraph("<b>Figura 2:</b> Subdominio de Usuarios, Hábitos, Metas y Recordatorios (archivo: <code>diagramas/Questly-Usuarios-Habitos-Chen.png</code>).", caption))

    # ==========================
    # PÁGINA 6: SUBDIAGRAMAS PERFIL Y SEGUIMIENTO
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("3.3 Subdiagrama: Perfil, Estado de Ánimo y Habilidades", h2))
    story.append(Paragraph(
        "Ilustra el componente de progreso y RPG de Questly: experiencia acumulada, registro anímico con comentarios reflexivos y árbol de habilidades:", body
    ))

    img_perf = DIAG_DIR / 'Questly-Perfil-Chen.png'
    if img_perf.exists():
        w_img = 490
        h_img = w_img / (3736 / 902)
        story.append(Spacer(1, 4))
        story.append(Image(str(img_perf), width=w_img, height=h_img))
        story.append(Paragraph("<b>Figura 3:</b> Subdominio de Perfil, Estado de Ánimo y Habilidades (archivo: <code>diagramas/Questly-Perfil-Chen.png</code>).", caption))

    story.append(Spacer(1, 14))
    story.append(Paragraph("3.4 Subdiagrama: Seguimiento y Métricas Derivadas", h2))
    story.append(Paragraph(
        "Refleja el registro atómico de eventos en <code>Cumplimiento</code> y las métricas calculadas (óvalos con trazo discontinuo):", body
    ))

    img_seg = DIAG_DIR / 'Questly-Seguimiento-Chen.png'
    if img_seg.exists():
        w_img = 440
        h_img = w_img / (2646 / 852)
        story.append(Spacer(1, 4))
        story.append(Image(str(img_seg), width=w_img, height=h_img))
        story.append(Paragraph("<b>Figura 4:</b> Subdominio de Seguimiento y Métricas Derivadas (archivo: <code>diagramas/Questly-Seguimiento-Chen.png</code>).", caption))

    # ==========================
    # PÁGINA 7: SUBDIAGRAMA RECOMPENSAS
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("3.5 Subdiagrama: Catálogo y Obtención de Recompensas", h2))
    story.append(Paragraph(
        "Presenta el catálogo de reconocimientos vinculables opcionalmente a hábitos y la relación conceptual N:M <code>obtiene</code> entre usuarios y recompensas con el atributo de fecha de obtención:", body
    ))

    img_rec = DIAG_DIR / 'Questly-Recompensas-Chen.png'
    if img_rec.exists():
        w_img = 490
        h_img = w_img / (4232 / 1120)
        story.append(Spacer(1, 6))
        story.append(Image(str(img_rec), width=w_img, height=h_img))
        story.append(Paragraph("<b>Figura 5:</b> Subdominio de Recompensas y Obtenciones N:M (archivo: <code>diagramas/Questly-Recompensas-Chen.png</code>).", caption))

    story.append(Spacer(1, 16))
    story.append(Paragraph("Visor Web Interactivo", h2))
    story.append(Paragraph(
        "Además de las imágenes estáticas, se integró en <code>diagramas/Questly-Diagramas-Chen.html</code> un visor interactivo "
        "con controles de zoom, ajuste y desplazamiento horizontal para explorar fluidamente los diagramas vectoriales.", body
    ))

    # ==========================
    # PÁGINA 8: ESQUEMA Y DICCIONARIO
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("4. Esquema Relacional y Diccionario de Datos Físico", h1))
    story.append(Paragraph(
        "Especificación técnica de las tablas creadas en <code>migraciones/001_esquema_questly.sql</code>. "
        "Cada columna cuenta con tipo SQL previsto, nulabilidad, restricciones formales y propósito operacional:", body
    ))

    dict_rows = [
        [Paragraph("Columna", th_style), Paragraph("Tipo SQL", th_style), Paragraph("Nulable", th_style), Paragraph("Restricción / Defecto", th_style), Paragraph("Significado de Negocio", th_style)],
        
        # usuario_persona
        [Paragraph("<b>usuario_persona</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Usuarios registrados en la plataforma.", td_style)],
        [Paragraph("• id_usuario", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador primario subrogado.", td_style)],
        [Paragraph("• correo", td_style), Paragraph("varchar(150)", td_style), Paragraph("No", td_style), Paragraph("UNIQUE", td_style), Paragraph("Correo y clave alternativa de acceso.", td_style)],
        [Paragraph("• nombre", td_style), Paragraph("varchar(100)", td_style), Paragraph("No", td_style), Paragraph("—", td_style), Paragraph("Nombre completo o alias visible.", td_style)],
        [Paragraph("• rol", td_style), Paragraph("varchar(20)", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 'aprendiz', CHECK", td_style), Paragraph("Jerarquía: 'aprendiz', 'maestro', 'experto'.", td_style)],
        [Paragraph("• fecha_nacimiento", td_style), Paragraph("date", td_style), Paragraph("Sí", td_style), Paragraph("—", td_style), Paragraph("Fecha de nacimiento para cálculo de edad.", td_style)],
        [Paragraph("• descripcion_tu", td_style), Paragraph("text", td_style), Paragraph("Sí", td_style), Paragraph("—", td_style), Paragraph("Perfil biográfico del usuario.", td_style)],
        [Paragraph("• puntos_experiencia", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 0, CHECK (>=0)", td_style), Paragraph("XP acumulada por cumplir hábitos.", td_style)],
        [Paragraph("• nivel", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 1, CHECK (>=1)", td_style), Paragraph("Nivel alcanzado de progresión RPG.", td_style)],

        # habito_tarea
        [Paragraph("<b>habito_tarea</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Hábitos o tareas gestionadas por el usuario.", td_style)],
        [Paragraph("• id_habito", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador primario del hábito.", td_style)],
        [Paragraph("• nombre", td_style), Paragraph("varchar(150)", td_style), Paragraph("No", td_style), Paragraph("—", td_style), Paragraph("Título descriptivo del hábito.", td_style)],
        [Paragraph("• nivel_importancia", td_style), Paragraph("varchar(20)", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 'media', CHECK", td_style), Paragraph("Prioridad: 'alta', 'media' o 'baja'.", td_style)],
        [Paragraph("• tiempo_invertido", td_style), Paragraph("integer", td_style), Paragraph("Sí", td_style), Paragraph("CHECK (> 0)", td_style), Paragraph("Minutos estimados de dedicación diaria.", td_style)],
        [Paragraph("• fecha_inicio", td_style), Paragraph("date", td_style), Paragraph("No", td_style), Paragraph("DEFAULT CURRENT_DATE", td_style), Paragraph("Inicio formal del hábito.", td_style)],
        [Paragraph("• fecha_final", td_style), Paragraph("date", td_style), Paragraph("Sí", td_style), Paragraph("CHECK (>= fecha_inicio)", td_style), Paragraph("Fecha límite opcional de culminación.", td_style)],
        [Paragraph("• frecuencia", td_style), Paragraph("varchar(30)", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 'diaria', CHECK", td_style), Paragraph("Periodicidad: 'diaria', 'semanal', 'mensual'.", td_style)],
        [Paragraph("• usuario_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("FK → usuario_persona CASCADE", td_style), Paragraph("Propietario del hábito.", td_style)],

        # meta
        [Paragraph("<b>meta</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Metas y objetivos cuantificables.", td_style)],
        [Paragraph("• id_meta", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador de la meta.", td_style)],
        [Paragraph("• descripcion", td_style), Paragraph("varchar(255)", td_style), Paragraph("No", td_style), Paragraph("—", td_style), Paragraph("Descripción del objetivo a lograr.", td_style)],
        [Paragraph("• valor_objetivo", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("CHECK (> 0)", td_style), Paragraph("Cantidad numérica objetivo a alcanzar.", td_style)],
        [Paragraph("• fecha_limite", td_style), Paragraph("date", td_style), Paragraph("Sí", td_style), Paragraph("—", td_style), Paragraph("Fecha límite propuesta para cumplirla.", td_style)],
        [Paragraph("• habito_id", td_style), Paragraph("integer", td_style), Paragraph("Sí", td_style), Paragraph("FK → habito_tarea SET NULL", td_style), Paragraph("Hábito vinculado (sobrevive a su borrado).", td_style)],

        # recompensa
        [Paragraph("<b>recompensa</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Catálogo de insignias y medallas.", td_style)],
        [Paragraph("• id_recompensa", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador de la recompensa.", td_style)],
        [Paragraph("• nombre", td_style), Paragraph("varchar(100)", td_style), Paragraph("No", td_style), Paragraph("UNIQUE", td_style), Paragraph("Nombre único de la insignia.", td_style)],
        [Paragraph("• descripcion", td_style), Paragraph("text", td_style), Paragraph("Sí", td_style), Paragraph("—", td_style), Paragraph("Explicación del logro premiado.", td_style)],
        [Paragraph("• puntos_necesarios", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("CHECK (> 0)", td_style), Paragraph("Puntos de experiencia requeridos.", td_style)],
        [Paragraph("• habito_id", td_style), Paragraph("integer", td_style), Paragraph("Sí", td_style), Paragraph("FK → habito_tarea SET NULL", td_style), Paragraph("Hábito vinculado opcional.", td_style)],

        # usuario_recompensa
        [Paragraph("<b>usuario_recompensa</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Tabla asociativa para la relación N:M.", td_style)],
        [Paragraph("• usuario_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK comp., FK CASCADE", td_style), Paragraph("Usuario que obtuvo la recompensa.", td_style)],
        [Paragraph("• recompensa_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK comp., FK RESTRICT", td_style), Paragraph("Recompensa obtenida (historial protegido).", td_style)],
        [Paragraph("• fecha_obtencion", td_style), Paragraph("date", td_style), Paragraph("No", td_style), Paragraph("DEFAULT CURRENT_DATE", td_style), Paragraph("Fecha de otorgamiento del reconocimiento.", td_style)],

        # recordatorio
        [Paragraph("<b>recordatorio</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Notificaciones programadas.", td_style)],
        [Paragraph("• id_recordatorio", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador del recordatorio.", td_style)],
        [Paragraph("• fecha_hora", td_style), Paragraph("timestamp", td_style), Paragraph("No", td_style), Paragraph("—", td_style), Paragraph("Momento programado del aviso.", td_style)],
        [Paragraph("• mensaje", td_style), Paragraph("varchar(255)", td_style), Paragraph("No", td_style), Paragraph("—", td_style), Paragraph("Texto de la notificación.", td_style)],
        [Paragraph("• repeticion", td_style), Paragraph("varchar(30)", td_style), Paragraph("No", td_style), Paragraph("DEFAULT 'única', CHECK", td_style), Paragraph("Frecuencia: 'única', 'diaria', 'semanal', 'mensual'.", td_style)],
        [Paragraph("• habito_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("FK → habito_tarea CASCADE", td_style), Paragraph("Hábito al que corresponde la alerta.", td_style)],

        # habilidad
        [Paragraph("<b>habilidad</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Destrezas del usuario.", td_style)],
        [Paragraph("• id_habilidad", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador de la habilidad.", td_style)],
        [Paragraph("• nombre_habilidad", td_style), Paragraph("varchar(100)", td_style), Paragraph("No", td_style), Paragraph("UNIQUE con usuario_id", td_style), Paragraph("Nombre de la destreza entrenada.", td_style)],
        [Paragraph("• nivel_habilidad", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("CHECK (BETWEEN 1 AND 10)", td_style), Paragraph("Grado de dominio (escala 1 a 10).", td_style)],
        [Paragraph("• tipo_origen", td_style), Paragraph("varchar(10)", td_style), Paragraph("No", td_style), Paragraph("CHECK ('sistema','usuario')", td_style), Paragraph("Origen predefinido o personalizado.", td_style)],
        [Paragraph("• usuario_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("FK → usuario_persona CASCADE", td_style), Paragraph("Usuario que desarrolla la habilidad.", td_style)],

        # animo
        [Paragraph("<b>animo</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Registro del estado emocional del usuario.", td_style)],
        [Paragraph("• id_animo", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador del registro de ánimo.", td_style)],
        [Paragraph("• estado_actual", td_style), Paragraph("varchar(30)", td_style), Paragraph("No", td_style), Paragraph("CHECK (5 estados)", td_style), Paragraph("'excelente', 'bien', 'normal', 'triste', 'estresado'.", td_style)],
        [Paragraph("• comentario", td_style), Paragraph("text", td_style), Paragraph("Sí", td_style), Paragraph("—", td_style), Paragraph("Reflexión personal opcional.", td_style)],
        [Paragraph("• fecha_registro", td_style), Paragraph("timestamp", td_style), Paragraph("No", td_style), Paragraph("DEFAULT CURRENT_TIMESTAMP", td_style), Paragraph("Marca temporal precisa del reporte.", td_style)],
        [Paragraph("• usuario_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("FK → usuario_persona CASCADE", td_style), Paragraph("Usuario que registró su estado.", td_style)],

        # cumplimiento
        [Paragraph("<b>cumplimiento</b>", td_bold), Paragraph("<i>Tabla física</i>", td_style), Paragraph("—", td_style), Paragraph("—", td_style), Paragraph("Eventos atómicos de cumplimiento diario.", td_style)],
        [Paragraph("• id_cumplimiento", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("PK, IDENTITY", td_style), Paragraph("Identificador del evento.", td_style)],
        [Paragraph("• fecha_cumplimiento", td_style), Paragraph("date", td_style), Paragraph("No", td_style), Paragraph("UNIQUE con habito_id", td_style), Paragraph("Día calendario en que se ejecutó el hábito.", td_style)],
        [Paragraph("• habito_id", td_style), Paragraph("integer", td_style), Paragraph("No", td_style), Paragraph("FK → habito_tarea CASCADE", td_style), Paragraph("Hábito completado con éxito.", td_style)],
    ]

    t_dict = Table(dict_rows, colWidths=[90, 80, 40, 130, 192], repeatRows=1)
    t_dict.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cbd5e1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f8fafc")]),
        ('TOPPADDING', (0,0), (-1,-1), 2),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2),
    ]))
    story.append(t_dict)

    story.append(Spacer(1, 6))
    story.append(Paragraph("<b>Vista Calculada: <code>estadistica_habito</code></b>", h2))
    story.append(Paragraph(
        "Define dinámicamente las métricas de progreso sin persistir redundancia: "
        "<code>total_completado</code> (períodos exitosos), <code>porcentaje_cumplido</code> (tasa respecto a períodos esperados) "
        "y <code>racha_actual</code> (períodos consecutivos ininterrumpidos hasta la fecha actual). "
        "Soporta frecuencias diarias, semanales (semanas ISO) y mensuales.", body
    ))

    # ==========================
    # PÁGINA 9: NORMALIZACIÓN
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("5. Auditoría Formal de Normalización", h1))
    story.append(Paragraph(
        "El diseño fue sometido a una auditoría estricta de normalización para asegurar la ausencia de anomalías:", body
    ))
    norm_points = [
        ("1FN (Primera Forma Normal)", "Todos los atributos contienen valores escalares y atómicos; no existen arreglos anidados ni listas compuestas. Las relaciones N:M se descomponen formalmente en tablas puente asociativas."),
        ("2FN (Segunda Forma Normal)", "Cumple 1FN y ningún atributo no clave depende parcialmente de una clave candidata compuesta. La única tabla con clave compuesta es <code>usuario_recompensa(usuario_id, recompensa_id)</code>, y su atributo <code>fecha_obtencion</code> describe exclusivamente el hecho conjunto de la obtención."),
        ("3FN / BCNF (Tercera Forma Normal / Boyce-Codd)", "No existen dependencias transitivas entre atributos no clave. Toda determinante funcional es una superclave legítima. No se almacenan datos derivados estáticos (las estadísticas se calculan dinámicamente en la vista <code>estadistica_habito</code>)."),
        ("Dependencias Funcionales Formalizadas",
         "<br/>• <code>id_usuario → correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel</code>.<br/>"
         "• <code>id_habito → nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, usuario_id</code>.<br/>"
         "• <code>id_meta → descripcion, valor_objetivo, fecha_limite, habito_id</code>.<br/>"
         "• <code>id_recompensa → nombre, descripcion, puntos_necesarios, habito_id</code>.<br/>"
         "• <code>(usuario_id, recompensa_id) → fecha_obtencion</code>.<br/>"
         "• <code>id_recordatorio → fecha_hora, mensaje, repeticion, habito_id</code>.<br/>"
         "• <code>id_habilidad → nombre_habilidad, descripcion, nivel_habilidad, tipo_origen, usuario_id</code>.<br/>"
         "• <code>id_animo → estado_actual, comentario, fecha_registro, usuario_id</code>.<br/>"
         "• <code>id_cumplimiento → fecha_cumplimiento, habito_id</code>.")
    ]
    for np_title, np_desc in norm_points:
        story.append(Paragraph(f"• <b>{np_title}:</b> {np_desc}", body))
        story.append(Spacer(1, 2))

    # ==========================
    # PÁGINA 10: BANCO DE CONSULTAS
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("6. Banco de Consultas de Negocio", h1))
    story.append(Paragraph(
        "En <code>consultas/001_consultas_negocio.sql</code> se implementó un banco de 10 consultas operacionales reales "
        "que satisfacen con creces la variedad técnica exigida por la rúbrica:", body
    ))

    queries_data = [
        [Paragraph("N°", th_style), Paragraph("Pregunta de Negocio Respondida", th_style), Paragraph("Patrón Técnico Evaluado", th_style), Paragraph("Tablas Involucradas", th_style)],
        [Paragraph("1", td_bold), Paragraph("¿Qué hábitos activos tiene cada usuario y cuál es su frecuencia?", td_style), Paragraph("Filtrado condicional y reunión básica", td_style), Paragraph("usuario_persona, habito_tarea", td_style)],
        [Paragraph("2", td_bold), Paragraph("¿Cuántas veces completó cada usuario cada hábito en los últimos 7 días?", td_style), Paragraph("Reunión externa izquierda con agregación temporal", td_style), Paragraph("usuario, habito, cumplimiento", td_style)],
        [Paragraph("3", td_bold), Paragraph("¿Qué usuarios todavía no han obtenido ninguna recompensa?", td_style), Paragraph("<b>Patrón 'Los que no tienen'</b> (LEFT JOIN + IS NULL)", td_style), Paragraph("usuario_persona, usuario_recompensa", td_style)],
        [Paragraph("4", td_bold), Paragraph("¿Qué usuarios administran al menos dos hábitos?", td_style), Paragraph("<b>GROUP BY con HAVING</b> (agregación con filtro)", td_style), Paragraph("usuario_persona, habito_tarea", td_style)],
        [Paragraph("5", td_bold), Paragraph("¿Qué recompensas obtuvo cada usuario y en qué fecha exacta?", td_style), Paragraph("<b>Reunión de 3 tablas</b> (resolución N:M)", td_style), Paragraph("usuario, usuario_recompensa, recompensa", td_style)],
        [Paragraph("6", td_bold), Paragraph("¿Qué hábitos están por vencer y a quién pertenecen?", td_style), Paragraph("<b>Reunión de 3 tablas</b> con rango de fechas", td_style), Paragraph("meta, habito_tarea, usuario_persona", td_style)],
        [Paragraph("7", td_bold), Paragraph("¿Cuál es el porcentaje de cumplimiento y la racha actual por hábito?", td_style), Paragraph("<b>Consulta sobre vista calculada</b> + JOIN a tablas", td_style), Paragraph("estadistica_habito, habito, usuario", td_style)],
        [Paragraph("8", td_bold), Paragraph("¿Cuántos hábitos de cada frecuencia están registrados y cuáles tienen varios?", td_style), Paragraph("<b>GROUP BY con filtro HAVING</b>", td_style), Paragraph("habito_tarea", td_style)],
        [Paragraph("9", td_bold), Paragraph("¿Cómo se distribuyen los registros de ánimo por usuario y estado?", td_style), Paragraph("Agregación multidimensional", td_style), Paragraph("usuario_persona, animo", td_style)],
        [Paragraph("10", td_bold), Paragraph("¿Qué usuarios completaron hábitos de alta importancia esta semana?", td_style), Paragraph("<b>Subconsulta CTE (WITH)</b> + reunión triple", td_style), Paragraph("cumplimiento (CTE), habito, usuario", td_style)],
    ]
    t_q = Table(queries_data, colWidths=[18, 235, 165, 114])
    t_q.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cbd5e1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f8fafc")]),
        ('TOPPADDING', (0,0), (-1,-1), 3),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3),
    ]))
    story.append(t_q)

    # ==========================
    # PÁGINA 11: ÍNDICES Y CONCLUSIONES
    # ==========================
    story.append(PageBreak())
    story.append(Paragraph("7. Optimización e Índices con Evidencia Medida", h1))
    story.append(Paragraph(
        "Siguiendo rigurosamente el <b>método experimental del curso</b>, se realizó una medición comparativa de planes de ejecución "
        "con <code>EXPLAIN (ANALYZE, BUFFERS)</code> sobre una base de prueba poblada con 30 000 hábitos y 500 usuarios:", body
    ))
    story.append(Spacer(1, 3))
    story.append(Paragraph("<b>Caso de Estudio: Búsqueda de Hábitos por Usuario (<code>habito_tarea.usuario_id</code>)</b>", h2))

    story.append(Paragraph("<b>1. Consulta evaluada:</b>", body))
    story.append(Paragraph("<code>EXPLAIN (ANALYZE, BUFFERS) SELECT id_habito, nombre, frecuencia FROM habito_tarea WHERE usuario_id = 250;</code>", code_snippet))

    story.append(Paragraph("<b>2. Plan antes de crear el índice (Escaneo Secuencial forzado):</b>", body))
    story.append(Paragraph(
        "Seq Scan on habito_tarea (cost=0.00..625.00 rows=60 width=23) (actual time=0.025..0.985 rows=60.00 loops=1)<br/>"
        "&nbsp;&nbsp;Filter: (usuario_id = 250)<br/>"
        "&nbsp;&nbsp;Rows Removed by Filter: 29940<br/>"
        "&nbsp;&nbsp;<b>Buffers: shared hit=250</b> | Planning Time: 0.177 ms | <b>Execution Time: 1.002 ms</b>", code_snippet
    ))

    story.append(Paragraph("<b>3. Índice creado:</b>", body))
    story.append(Paragraph("<code>CREATE INDEX idx_habito_tarea_usuario ON habito_tarea (usuario_id);</code>", code_snippet))

    story.append(Paragraph("<b>4. Plan después de crear el índice (Escaneo por Mapa de Bits):</b>", body))
    story.append(Paragraph(
        "Bitmap Heap Scan on habito_tarea (cost=4.75..146.21 rows=60 width=23) (actual time=0.080..0.115 rows=60.00 loops=1)<br/>"
        "&nbsp;&nbsp;Recheck Cond: (usuario_id = 250)<br/>"
        "&nbsp;&nbsp;Heap Blocks: exact=60 | <b>Buffers: shared hit=60 read=2</b><br/>"
        "&nbsp;&nbsp;-> Bitmap Index Scan on idx_habito_tarea_usuario (cost=0.00..4.74 rows=60 width=0) (actual time=0.069..0.069)<br/>"
        "Planning Time: 0.087 ms | <b>Execution Time: 0.127 ms</b>", code_snippet
    ))

    story.append(Spacer(1, 3))
    story.append(Paragraph("<b>5. Análisis Comparativo y Conclusiones:</b>", body))

    idx_metricas = [
        [Paragraph("Métrica Evaluada", th_style), Paragraph("Antes (Sin Índice)", th_style), Paragraph("Después (Con Índice B-Tree)", th_style), Paragraph("Impacto / Mejora Observada", th_style)],
        [Paragraph("<b>Estrategia de acceso</b>", td_style), Paragraph("Seq Scan (Barrido completo)", td_style), Paragraph("Bitmap Index Scan + Heap Scan", td_style), Paragraph("Acceso directo a tuplas relevantes", td_style)],
        [Paragraph("<b>Costo estimado</b>", td_style), Paragraph("625.00", td_style), Paragraph("146.21", td_style), Paragraph("<b>Reducción del 76.6 %</b> en costo", td_style)],
        [Paragraph("<b>Bloques leídos (Buffers)</b>", td_style), Paragraph("250 páginas en memoria", td_style), Paragraph("62 páginas (60 tabla + 2 índice)", td_style), Paragraph("<b>Reducción del 75.2 %</b> de I/O", td_style)],
        [Paragraph("<b>Filas leídas / descartadas</b>", td_style), Paragraph("30 000 leídas / 29 940 descartadas", td_style), Paragraph("60 recuperadas directamente", td_style), Paragraph("Cero descarte inútil de registros", td_style)],
        [Paragraph("<b>Tiempo de ejecución</b>", td_style), Paragraph("1.002 ms", td_style), Paragraph("0.127 ms", td_style), Paragraph("<b>Aceleración de ~7.9x</b> (788 % más rápido)", td_style)],
    ]
    t_idx = Table(idx_metricas, colWidths=[115, 130, 137, 150])
    t_idx.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), c_secondary),
        ('GRID', (0,0), (-1,-1), 0.5, colors.HexColor("#cbd5e1")),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [colors.white, colors.HexColor("#f8fafc")]),
        ('TOPPADDING', (0,0), (-1,-1), 2.5),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5),
    ]))
    story.append(t_idx)

    story.append(Spacer(1, 8))
    story.append(Paragraph("8. Conclusiones y Preparación de la Entrega 3", h1))
    story.append(Paragraph(
        "La Entrega 2 consolida a Questly como una base de datos relacional robusta, íntegra y de alto rendimiento. "
        "El paso del modelo conceptual a PostgreSQL 16+ se ejecutó validando la integridad declarativa, la normalización en 3FN/BCNF, "
        "la notación Chen estricta y la optimización física de consultas analíticas. "
        "Esta base sólida permite afrontar con éxito la <b>Entrega 3</b>, donde se incorporarán procedimientos almacenados, "
        "disparadores (triggers), políticas de seguridad por roles (RBAC) y vistas materializadas.", body
    ))
    story.append(Spacer(1, 6))
    story.append(Paragraph(
        "<i>Todos los artefactos, scripts SQL ejecutables, diagramas en alta definición y documentación detallada se "
        "encuentran disponibles y versionados en el repositorio oficial bajo la etiqueta Git <code>entrega-2</code>.</i>",
        caption
    ))

    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"PDF exitosamente generado en: {PDF_PATH} ({PDF_PATH.stat().st_size} bytes)")

if __name__ == '__main__':
    build_pdf()
