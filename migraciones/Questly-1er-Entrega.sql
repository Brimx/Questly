drop table if exists estadistica cascade
drop table if exists animo cascade
drop table if exists recordatorio cascade
drop table if exists meta cascade
drop table if exists habito_tarea cascade
drop table if exists habilidad cascade
drop table if exists recompensa cascade
drop table if exists usuario_persona cascade

----------------------------------------------------------------------------------
create table usuario_persona (
	id_usuario         serial       primary key not NULL,
	correo             varchar(150) unique      not NULL,
	nombre             varchar(100) not NULL,
	rol                varchar(50)  not NULL default 'aprendiz'
	                                constraint rol_valido check(rol in ('aprendiz', 'maestro', 'experto')),
	fecha_nacimiento   date,
	descripcion_tu     text,
	puntos_experiencia integer      not NULL default 0 constraint puntos_experiencia_no_negativo check(puntos_experiencia >= 0),
	nivel              integer      not NULL default 1 constraint nivel_minimo check(nivel >= 1)
)

----------------------------------------------------------------------------------
create table habito_tarea (
	id_habito         serial       primary key not NULL,
	nombre            varchar(150) not NULL,
	nivel_importancia varchar(20)  not NULL default 'media'
	                               constraint nivel_importancia_valido check(nivel_importancia in ('alta', 'media', 'baja')),
	tiempo_invertido  integer      constraint tiempo_invertido_positivo check(tiempo_invertido is NULL or tiempo_invertido > 0),
	fecha_inicio      date         not NULL default CURRENT_DATE,
	fecha_final       date         constraint fecha_final_valida check(fecha_final is NULL or fecha_final >= fecha_inicio),
	frecuencia        varchar(30)  not NULL default 'diaria'
	                               constraint frecuencia_valida check(frecuencia in ('diaria', 'semanal', 'mensual')),
	usuario_id        integer      not NULL references usuario_persona (id_usuario)
	                               on delete cascade
)

----------------------------------------------------------------------------------
create table recompensa (
	id_recompensa     serial       primary key not NULL,
	nombre            varchar(100) unique      not NULL,
	descripcion       text,
	puntos_necesarios integer      not NULL constraint puntos_necesarios_positivo check(puntos_necesarios > 0),
	habito_id         integer      references habito_tarea (id_habito)
	                               on delete cascade
)

----------------------------------------------------------------------------------
create table meta (
	id_meta        serial       primary key not NULL,
	descripcion    varchar(255) not NULL,
	valor_objetivo integer      not NULL constraint valor_objetivo_positivo check(valor_objetivo > 0),
	fecha_limite   date,
	habito_id      integer      not NULL references habito_tarea (id_habito)
	                            on delete cascade
)

----------------------------------------------------------------------------------
create table recordatorio (
	id_recordatorio serial       primary key not NULL,
	fecha_hora      timestamp    not NULL,
	mensaje         varchar(255) not NULL,
	repeticion      varchar(30)  default 'única'
	                             constraint repeticion_valida check(repeticion in ('única', 'diaria', 'semanal', 'mensual')),
	habito_id       integer      not NULL references habito_tarea (id_habito)
	                             on delete cascade
)

----------------------------------------------------------------------------------
create table habilidad (
	id_habilidad     serial       primary key not NULL,
	nombre_habilidad varchar(100) not NULL,
	descripcion      text,
	nivel_habilidad  integer      not NULL default 1 constraint nivel_habilidad_rango check(nivel_habilidad between 1 and 10),
	usuario_id       integer      not NULL references usuario_persona (id_usuario)
	                              on delete cascade,
	unique(nombre_habilidad, usuario_id)
)

----------------------------------------------------------------------------------
create table animo (
	id_animo       serial      primary key not NULL,
	estado_actual  varchar(30) not NULL
	                           constraint estado_actual_valido check(estado_actual in ('excelente', 'bien', 'normal', 'triste', 'estresado')),
	comentario     text,
	fecha_registro date        not NULL default CURRENT_DATE,
	usuario_id     integer     not NULL references usuario_persona (id_usuario)
	                           on delete cascade
)

----------------------------------------------------------------------------------
create table estadistica (
	id_estadistica       serial  primary key not NULL,
	total_completado     integer not NULL default 0 constraint total_completado_no_negativo check(total_completado >= 0),
	porcentaje_cumplido  integer not NULL default 0 constraint porcentaje_cumplido_rango check(porcentaje_cumplido between 0 and 100),
	racha_actual         integer not NULL default 0 constraint racha_actual_no_negativa check(racha_actual >= 0),
	fecha_inicio_periodo date    not NULL,
	fecha_fin_periodo    date    not NULL constraint fecha_fin_periodo_valida check(fecha_fin_periodo >= fecha_inicio_periodo),
	usuario_id           integer not NULL references usuario_persona (id_usuario)
	                             on delete cascade
)

----------------------------------------------------------------------------------
insert into usuario_persona (correo, nombre, rol, fecha_nacimiento, descripcion_tu, puntos_experiencia, nivel) values
	('mariagomez@goshi.com', 'Maria Gomez', 'aprendiz', '1995-03-15', 'Quiero mejorar mis habitos de estudio', 1250, 3),
	('carlosruiz@goshi.com', 'Carlos Ruiz', 'aprendiz', '2000-07-22', 'Buscando constancia en el ejercicio', 450, 1),
	('lauraLopez@goshi.com', 'Laura Lopez', 'maestro', '1988-11-05', 'Experta en productividad', 8900, 12),
	('juanpablo@goshi.com', 'Juan Pablo', 'aprendiz', '2002-01-30', 'Necesito organizar mi tiempo', 320, 1),
	('andreamartines@goshi.com', 'Andrea Martines', 'experto', '1992-09-12', 'Mentalidad de crecimiento', 4500, 7)

insert into recompensa (nombre, descripcion, puntos_necesarios) values
	('Insignia Bronce', 'Completar 10 habitos', 500),
	('Insignia Plata', 'Completar 50 habitos', 2000),
	('Insignia Oro', 'Completar 100 habitos', 5000),
	('Medalla Constancia', '30 dias de racha', 1500),
	('Titulo Maestro', 'Alcanzar nivel 10', 8000)

insert into habito_tarea (nombre, nivel_importancia, tiempo_invertido, fecha_inicio, fecha_final, frecuencia, usuario_id) values
	('Meditar 10 minutos', 'alta', 10, '2026-01-01', NULL, 'diaria', 1),
	('Leer 20 paginas', 'alta', 30, '2026-01-01', NULL, 'diaria', 1),
	('Hacer ejercicio', 'alta', 45, '2026-01-15', NULL, 'diaria', 2),
	('Estudiar teoria del color', 'alta', 60, '2026-02-01', '2026-05-30', 'diaria', 1),
	('Tomar 2L de agua', 'media', NULL, '2026-03-01', NULL, 'diaria', 3),
	('Escribir en diario', 'baja', 15, '2026-01-10', NULL, 'diaria', 4),
	('Practicar ingles', 'media', 20, '2026-02-15', NULL, 'diaria', 2),
	('Ordenar escritorio', 'baja', 10, '2026-03-20', NULL, 'semanal', 5),
	('Planificar semana', 'alta', 30, '2026-01-05', NULL, 'semanal', 3),
	('Aprender receta nueva', 'baja', 40, '2026-04-01', NULL, 'mensual', 4)

insert into meta (descripcion, valor_objetivo, fecha_limite, habito_id) values
	('Completar 30 dias de meditación', 30, '2026-02-01', 1),
	('Leer 10 libros completos', 10, '2026-12-31', 2),
	('Bajar 5 kg de peso', 5, '2026-06-30', 3),
	('Aprobar examen de SQL', 1, '2026-05-30', 4),
	('Alcanzar 90 días de hidratación', 90, '2026-12-31', 5),
	('Escribir 50 entradas de diario', 50, '2026-12-31', 6),
	('Aprobar examen de humanidades', 1, '2026-08-30', 7),
	('Completar 25 paginas de Homestuck', 12, '2026-12-31', 9)

insert into recordatorio (fecha_hora, mensaje, repeticion, habito_id) values
	('2026-05-01 07:00:00', '¡Tiempo de meditar! Busca un lugar tranquilo', 'diaria', 1),
	('2026-05-01 20:00:00', 'No olvides leer 20 paginas antes de dormir', 'diaria', 2),
	('2026-05-01 06:30:00', 'A ejercitarse!!! Ponte las zapatillas', 'diaria', 3),
	('2026-05-01 18:00:00', 'Hora de estudiar SQL', 'diaria', 4),
	('2026-05-02 10:00:00', 'Toma tu primer litro de agua', 'diaria', 5),
	('2026-05-03 21:00:00', 'Escribe en tu diario antes de dormir', 'diaria', 6)

insert into habilidad (nombre_habilidad, descripcion, nivel_habilidad, usuario_id) values
	('Disciplina', 'Capacidad de mantener constancia', 5, 1),
	('Gestion del tiempo', 'Organizar actividades eficientemente', 3, 1),
	('Concentracion', 'Mantener enfoque en tareas', 4, 1),
	('Resistencia física', 'Aguante para ejercicio', 2, 2),
	('Fluidez lectora', 'Velocidad y comprension lectora', 6, 3),
	('Paciencia', 'Tolerancia a la frustracion', 4, 3),
	('Creatividad', 'Capacidad de generar ideas', 7, 5),
	('Organizacion', 'Orden en tareas y espacio', 5, 4),
	('Memoria', 'Retención de informacion', 4, 2),
	('Adaptabilidad', 'Capacidad de ajustarse a cambios', 6, 5),
	('Comunicacion', 'Expresar ideas claramente', 7, 3),
	('Autocontrol', 'Manejo de impulsos', 5, 1)

insert into animo (estado_actual, comentario, fecha_registro, usuario_id) values
	('excelente', 'Dia productivo, cumplí todas mis metas', '2026-04-25', 1),
	('bien', 'Avancé en lectura pero me faltó ejercicio', '2026-04-25', 2),
	('normal', 'Dia regular sin sobresaltos', '2026-04-25', 3),
	('triste', 'No llegué a hacer nada', '2026-04-25', 4),
	('excelente', 'Me sentí muy enfocado', '2026-04-25', 5),
	('bien', 'Medité 10 minutos y m', '2026-04-26', 1),
	('estresado', 'Mucho trabajo, poco tiempo', '2026-04-26', 2),
	('excelente', 'Terminé un libro importante', '2026-04-26', 3),
	('normal', 'Cumplí con lo mínimo', '2026-04-26', 4),
	('bien', 'Buena sesión de ejercicio', '2026-04-26', 5),
	('excelente', 'Racha de 7 días cumplida', '2026-04-27', 1),
	('triste', 'Me lesioné y no pude entrenar', '2026-04-27', 2),
	('bien', 'Avance constante en el proyecto de P3', '2026-04-27', 1),
	('normal', 'Dia libre', '2026-04-27', 3),
	('excelente', 'Logré la meta semanal', '2026-04-27', 4)

insert into estadistica (total_completado, porcentaje_cumplido, racha_actual, fecha_inicio_periodo, fecha_fin_periodo, usuario_id) values
	(24, 80, 7, '2026-04-18', '2026-04-24', 1),
	(18, 60, 3, '2026-04-18', '2026-04-24', 2),
	(28, 93, 12, '2026-04-18', '2026-04-24', 3),
	(15, 50, 2, '2026-04-18', '2026-04-24', 4),
	(26, 86, 8, '2026-04-18', '2026-04-24', 5),
	(28, 93, 10, '2026-04-11', '2026-04-17', 1),
	(20, 66, 4, '2026-04-11', '2026-04-17', 2),
	(30, 100, 14, '2026-04-11', '2026-04-17', 3)

----------------------------------------------------------------------------------
-- Usuarios con nivel mayor que 3.
select nombre, correo, nivel, puntos_experiencia from usuario_persona where nivel >= 3

-- Habitos de importancia alta.
select nombre, nivel_importancia, tiempo_invertido, frecuencia from habito_tarea where nivel_importancia = 'alta'

-- Habitos que no tengan frecuencia diaria.
select nombre, frecuencia from habito_tarea where frecuencia != 'diaria'

-- Usuarios con un rango de nivel entre 5 y 10.
select nombre, nivel from usuario_persona where nivel between 5 and 10

-- Habito donde solo tengan el id del usuario 1, 2 y 3.
select nombre, usuario_id, nivel_importancia from habito_tarea where usuario_id in (1, 2, 3)

-- Habilidad que contenga la palabra "Capacidad" en su descripcion.
select nombre_habilidad, descripcion from habilidad where descripcion like '%Capacidad%' -- Ojo con las mayusculas y minusculas.
                                                                                          -- No saldra lo mismo al escribir capacidad.

-- Nombre de la habilidad que empiece con C.
select nombre_habilidad from habilidad where nombre_habilidad like 'C%' -- Ojo con las mayusculas y minusculas.

-- Usuarios que tienen una descripcion null y no null.
select nombre, correo from usuario_persona where descripcion_tu is NULL

select nombre, descripcion_tu from usuario_persona where descripcion_tu is not NULL

-- Ordenar el nivel de las habilidades en forma decendente.
select nombre_habilidad, nivel_habilidad, usuario_id from habilidad order by nivel_habilidad desc

-- Mostrar los tres habitos con mayor tiempo invertido.
select nombre, tiempo_invertido from habito_tarea where tiempo_invertido is not NULL order by tiempo_invertido desc limit 3

-- Estados de animos distintos.
select distinct estado_actual from animo

-- Habito donde tenga una fecha final antes de.
select nombre, fecha_inicio, fecha_final from habito_tarea where fecha_final < '2026-06-01'

-- Usuarios que se llamen Lopez o Martines. (OJO MAYUSCULAS!!!!!!!!)
select nombre, correo from usuario_persona where nombre like '%lopez' or nombre like '%Martines'

-- Mostrar en las estadisticas el porcetaje cumplido de un 80% en adelante, organizado de forma descendente.
select usuario_id, porcentaje_cumplido, racha_actual, fecha_inicio_periodo, fecha_fin_periodo
from estadistica where porcentaje_cumplido >= 80 order by porcentaje_cumplido desc

-- Habitos con un nivel de importancia que no sea ni alta ni media.
select nombre, nivel_importancia from habito_tarea where nivel_importancia not in ('alta', 'media')

-- Recordatorios con repeticion diaria, pero organizados de forma ascendente en su fecha y hora de creacion.
select mensaje, fecha_hora, repeticion from recordatorio where repeticion = 'diaria' order by fecha_hora asc

-- Habilidades con el id del usuario 1, nivel de habilidad mayor que 3 y que ese nivel se muestre de forma decendente.
select nombre_habilidad, nivel_habilidad from habilidad where usuario_id = 1 and nivel_habilidad > 3 order by nivel_habilidad desc

----------------------------------------------------------------------------------
-- Eliminar id del recordatorio 4.
delete from recordatorio where id_recordatorio = 4
-- select mensaje, fecha_hora, repeticion from recordatorio

-- Eliminar habitos con la fecha final por antes de 2026-06-01.
delete from habito_tarea where fecha_final < '2026-06-01'
-- select id_habito, nombre, fecha_final from habito_tarea where fecha_final < '2026-06-01'

-- Eliminar animos de estado normal.
delete from animo where estado_actual = 'normal'
-- select id_animo, estado_actual, fecha_registro from animo where estado_actual = 'normal'
