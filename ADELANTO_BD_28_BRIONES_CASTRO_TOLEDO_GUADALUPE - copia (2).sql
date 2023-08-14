CREATE DATABASE FielderCommunity;
USE FielderCommunity;
-- NOTA ESTA BD NO EXISTE, SE ELIMINO PARA USAR EL NOMBRE EN OTRA BASE DE DATOS XD
-- drop database FielderCommunity;
-- show tables;
# ------------------------------------------------------------------------------------------
CREATE TABLE MUNICIPIO(
	id_municipio INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_municipio PRIMARY KEY(id_municipio),
    nombre_municipio VARCHAR(45) NOT NULL,
	CONSTRAINT Unq_nombre_municipio UNIQUE (nombre_municipio)
);
INSERT INTO MUNICIPIO(nombre_municipio) VALUE("LA PAZ"),("COMONDÚ"),("LOS CABOS");
SELECT * FROM MUNICIPIO;
# ------------------------------------------------------------------------------------------
CREATE TABLE TROFEOS_OFICIALES(
	id_trofeo_oficiales INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_trofeo_oficiales PRIMARY KEY(id_trofeo_oficiales),
    nombre_trofeo_of VARCHAR(100) NOT NULL,
    CONSTRAINT Unq_nombre_trofeo_of UNIQUE(nombre_trofeo_of),
	descripcion_trofeo VARCHAR(500) NOT NULL,
    tipo_trofeo VARCHAR(100) DEFAULT "DINERO Y TROFEOS", 
    CONSTRAINT Chk_tipo_trofeo CHECK (tipo_trofeo IN ("DINERO","TROFEOS","DINERO Y TROFEOS","RECONOCIMIENTOS")),
    tipo_importancia VARCHAR(45) DEFAULT "ALTO",
    CONSTRAINT Chk_tipo_importancia CHECK (tipo_importancia IN ("ALTO", "MEDIO", "BAJO"))
);
/*EXPLICACION DE PROCEDIMIENTO ALMACENADO*/
/*ESTE PROCEDIMIENTO ALMACENADO VALIDARA TODOS LAS VARIABLES, QUE TENGAN NOT NULL, 
Y LOS DEAFAULT, EN ESTE CASO PRINCIPALMENTE PARA EVITAR COMPLICACIONES EN EL
FUTURO, Y DE TENER VALIDADAS A LA HORA DE INGRESAR DATOS, NO HAIGA NINGUN PROBLEMA AL RESPECTO
EVITANDO PROBLEMAS MAYORES AL INGRESAR DATOS ERRONEOS*/
DELIMITER $$
CREATE PROCEDURE ALTA_TROFEOS_OF(in nombre_trofeo_p VARCHAR(100),in descripcion_trofeo_p VARCHAR(500),
    in tipo_trofeo_p VARCHAR(100), in tipo_importancia_p VARCHAR(45)
)
BEGIN
    -- Validar que los parámetros de entrada no sean nulos o vacíos
    IF nombre_trofeo_p IS NULL OR nombre_trofeo_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del trofeo es obligatorio.';
    ELSE IF descripcion_trofeo_p IS NULL OR descripcion_trofeo_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La descripción del trofeo es obligatoria.';
    ELSE IF tipo_trofeo_p IS NULL OR tipo_trofeo_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de trofeo es obligatorio.';
    ELSE IF tipo_importancia_p IS NULL OR tipo_importancia_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de importancia es obligatorio.';
    -- Validar que el valor de tipo_trofeo sea uno de los valores permitidos
    ELSE IF tipo_trofeo_p NOT IN ('DINERO', 'TROFEOS', 'DINERO Y TROFEOS', 'RECONOCIMIENTOS') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de trofeo debe ser uno de los valores permitidos.';
    -- Validar que el valor de tipo_importancia sea uno de los valores permitidos
    ELSE IF tipo_importancia_p NOT IN ('ALTO', 'MEDIO', 'BAJO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El tipo de importancia debe ser uno de los valores permitidos.';
    END IF;END IF;END IF;END IF;END IF;END IF;
    -- Insertar el nuevo registro en la tabla TROFEOS_OFICIALES
    INSERT INTO TROFEOS_OFICIALES(nombre_trofeo_of, descripcion_trofeo, tipo_trofeo, tipo_importancia)
    VALUES(nombre_trofeo_p, descripcion_trofeo_p, tipo_trofeo_p, tipo_importancia_p);
END $$
DELIMITER ;
CALL ALTA_TROFEOS_OF("SPARTACUS","Es un trofeo nunca antes visto, y de un gran valor","DINERO","ALTO");
CALL ALTA_TROFEOS_OF("TORNATE","Es un trofeo nunca antes visto","TROFEOS","MEDIO");
CALL ALTA_TROFEOS_OF("CADELABRO","Sin comentarios...","DINERO Y TROFEOS","BAJO");
-- CALL ALTA_TROFEOS_OF("TORPEDO","EL MEJORRR","DINERO Y TROFEOS","BAJ");
SELECT * FROM TROFEOS_OFICIALES;
# ------------------------------------------------------------------------------------------
CREATE TABLE COLONIAS_OFICIALES(
	id_colonia_oficial INT AUTO_INCREMENT,
    CONSTRAINT PK_id_colonia_oficial PRIMARY KEY(id_colonia_oficial),
    nombre_colonia VARCHAR(45) NOT NULL,
    codigo_postal VARCHAR(5) NOT NULL,
    calle_principal VARCHAR(45) NOT NULL,
    calle_secundaria VARCHAR(45),
    referencias VARCHAR(200),
    id_municipio INT,
    CONSTRAINT Fk_id_municipio FOREIGN KEY(id_municipio) REFERENCES MUNICIPIO(id_municipio)  ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO COLONIAS_OFICIALES(nombre_colonia,codigo_postal,calle_principal,calle_secundaria,referencias,id_municipio)
VALUES("Miramar","23085","264 C. Isla","Av. Miramar","Al lado de un secundaria",1),
	("SOLIDARIDAD","23083","avenida universidad","geologia","al lado de un gym, la cancha de piso",1);
SELECT * FROM COLONIAS_OFICIALES;
# ------------------------------------------------------------------------------------------
CREATE TABLE CAMPO(
	id_campo INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_campo PRIMARY KEY(id_campo),
    nombre_campo VARCHAR(45) NOT NULL,
    calificacion FLOAT DEFAULT NULL,
    CONSTRAINT Chk_calificacion CHECK(calificacion BETWEEN 1 AND 5),
    estado_servicio VARCHAR(20) DEFAULT "LIBRE",
    CONSTRAINT Chk_estado_servicio CHECK(estado_servicio IN("LIBRE", "OCUPADO")),
    tipo_campo VARCHAR(100) NOT NULL,
    CONSTRAINT Chk_tipo_campo CHECK(tipo_campo IN("FUTBOL","FUTBOL RAPIDO","TENIS","BASQUETBOL","VOLEIBOL")),
	hora_inicio TIME NOT NULL,
    hora_salida TIME DEFAULT NULL,
    id_colonia_of INT,
    CONSTRAINT FK_id_colonia_of FOREIGN KEY(id_colonia_of) REFERENCES COLONIAS_OFICIALES(id_colonia_oficial) ON UPDATE CASCADE ON DELETE CASCADE
); 

/*
EXPLICACION:
ESTE PROCEDIMIENTO ALMACENADO SIRVIRA PARA VALIDAR
 LAS VARIABLES NECESARIAS PARA INSERTAR, QUE SERIAN 
 TODAS LAS VARIABLES QUE SE MOSTRARAN A CONTINUACION,
 PRINCIPALMENTE ESTO SIRVIRA PARA EVITAR PROBLEMAS 
 FUTUROS A LA HORA DE INSERTAR DATOS ERRONEOS, SI TODO
 ESTA CORRECTO SE LANZARA UN MENSAJE DE REGISTRO EXITOSO.
*/
DELIMITER $$
CREATE PROCEDURE ALTA_CAMPO(
    IN nombre_campo_p VARCHAR(45),IN calificacion_p FLOAT,IN estado_servicio_p VARCHAR(50),
    IN tipo_campo_p VARCHAR(100),IN hora_inicio_p TIME,IN hora_salida_p TIME,IN id_colonia_of_p INT)
BEGIN 
	-- Validar el nombre del campo
    IF nombre_campo_p IS NULL OR nombre_campo_p = '' THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'El nombre del campo es obligatorio.';
    ELSEIF LENGTH(nombre_campo_p) > 45 THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'El nombre del campo no puede ser mayor a 45 caracteres.';
    END IF;
    -- Validar la calificación del campo
    IF calificacion_p IS NOT NULL AND (calificacion_p < 1 OR calificacion_p > 5) THEN
        SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La calificación del campo debe estar entre 1 y 5.';
    END IF;
    -- Validar el estado del servicio
    IF estado_servicio_p NOT IN ('LIBRE', 'OCUPADO') THEN
        SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'El estado del servicio debe ser LIBRE o OCUPADO.'; 
    END IF;
    -- Validar el tipo de campo
    IF tipo_campo_p NOT IN ('FUTBOL', 'FUTBOL RAPIDO', 'TENIS', 'BASQUETBOL', 'VOLEIBOL') THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'El tipo de campo debe ser FUTBOL, FUTBOL RAPIDO, TENIS, BASQUETBOL o VOLEIBOL.';
    END IF;
    -- Validar la hora de inicio
    IF hora_inicio_p IS NULL THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La hora de inicio es obligatoria.';
    END IF;
    -- Validar la hora de salida (si se proporciona)
    IF hora_salida_p IS NOT NULL AND hora_salida_p <= hora_inicio_p THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La hora de salida debe ser mayor que la hora de inicio.';
    END IF;
    -- Validar la colonia oficial
    IF NOT EXISTS (SELECT 1 FROM COLONIAS_OFICIALES WHERE id_colonia_oficial = id_colonia_of_p) THEN
		SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La colonia oficial proporcionada no existe.';
    END IF;
    -- Insertar el registro en la tabla si no hay errores
    SET estado_servicio_p = "LIBRE";
	INSERT INTO CAMPO (nombre_campo, calificacion, estado_servicio, tipo_campo, hora_inicio, hora_salida, id_colonia_of)
	VALUES (nombre_campo_p, calificacion_p, estado_servicio_p, tipo_campo_p, hora_inicio_p, hora_salida_p, id_colonia_of_p);
	SELECT 'Registro insertado correctamente.' AS mensaje;
END $$
DELIMITER ;
#DROP PROCEDURE ALTA_CAMPO;
CALL ALTA_CAMPO("MIRAMAR",1,"LIBRE","FUTBOL","09:00:00",NULL,1);
CALL ALTA_CAMPO("MIRAMAR",4,"LIBRE","FUTBOL RAPIDO","08:00:00",NULL,1);
CALL ALTA_CAMPO("MIRAMAR",3.4,"LIBRE","VOLEIBOL","08:00:00",NULL,1);
CALL ALTA_CAMPO("SOLI MEZ",2.4,"LIBRE","FUTBOL RAPIDO","08:00:00",NULL,2);
CALL ALTA_CAMPO("SOLI MEZ 2",1.4,NULL,"BASQUETBOL","08:00:00",NULL,2);
-- CALL ALTA_CAMPO("SOLI MEZ",2.4,"LADADA","FUTBOL RAPIDO","08:00:00","",2);
SELECT * FROM CAMPO;
# ------------------------------------------------------------------------------------------
CREATE TABLE TORNEO(
	id_torneo INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_torneo PRIMARY KEY(id_torneo),
	nombre_torneo VARCHAR(45) NOT NULL,
    CONSTRAINT Unq_nombre_torneo UNIQUE(nombre_torneo),
	tipo_torneo VARCHAR(45) NOT NULL,
    CONSTRAINT Chk_tipo_torneo CHECK(tipo_torneo IN("FUTBOL","FUTBOL RAPIDO","TENIS","BASQUETBOL","VOLEIBOL")),
    fecha_inicio DATE NOT NULL,
    fecha_final DATE DEFAULT NULL,
    cantidad_equipos INT NOT NULL,
    CONSTRAINT Chk_cantidad_equipos CHECK(cantidad_equipos > 7),
    id_campo INT,
	CONSTRAINT Fk_id_camp FOREIGN KEY(id_campo) REFERENCES CAMPO(id_campo) ON UPDATE CASCADE ON DELETE CASCADE,
	id_trofeo_of INT,
    CONSTRAINT Fk_id_trofeo_of FOREIGN KEY(id_trofeo_of) REFERENCES TROFEOS_OFICIALES(id_trofeo_oficiales) ON UPDATE CASCADE ON DELETE CASCADE
);
# haceer triggee mejor
INSERT INTO TORNEO(nombre_torneo,tipo_torneo,fecha_inicio,cantidad_equipos,id_campo,id_trofeo_of)
VALUES("RELAMPAGO","FUTBOL","2023-06-01 08:00:00",8,1,1),
		("RELAMPAGO II","FUTBOL RAPIDO","2023-05-19 010:00:00",8,2,2),
        ("RELAMPAGO VOLI","VOLEIBOL","2023-05-01 14:00:00",8,3,3);
SELECT * FROM TORNEO;
# ------------------------------------------------------------------------------------------
CREATE TABLE EQUIPO(
	id_equipo INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_equipo PRIMARY KEY(id_equipo),
    nombre_equipo VARCHAR(45) NOT NULL,
	CONSTRAINT Unq_nombre_equipo UNIQUE(nombre_equipo),
	dt_equipo VARCHAR(45) NOT NULL,
    CONSTRAINT Unq_dt_equipo UNIQUE(dt_equipo),
    cantidad_jugadores INT NOT NULL,
    CONSTRAINT Chk_cantidad_jugadores CHECK(cantidad_jugadores between 7 and 25),
    estado_registro VARCHAR(15) DEFAULT "INSCRITO",
    CONSTRAINT Chk_estado_registro CHECK(estado_registro IN("INSCRITO","NO INSCRITO")),
    fecha_registro DATE NOT NULL,
    fecha_salida DATE DEFAULT NULL,
    id_torneo INT,
    CONSTRAINT Fk_id_torneo FOREIGN KEY(id_torneo) REFERENCES TORNEO(id_torneo) ON UPDATE CASCADE ON DELETE CASCADE
);

/*EXPLICACION DE PROCEDIMIENTO ALMACENADO*/
/*EN ESTE PROCEDURE, SE VALIDAN LAS ENTRADAS DE NOMBRE DEL EQUIPO,
 DIRECTOR TÉCNICO Y CANTIDAD DE JUGADORES, Y SE VERIFICA LA EXISTENCIA 
 DEL TORNEO ESPECIFICADO EN EL PARÁMETRO ID_TORNEO_P. SI ALGUNA DE ESTAS 
 VALIDACIONES FALLA, SE ENVÍA UN MENSAJE DE ERROR. SI TODAS LAS 
 VALIDACIONES PASAN, SE INSERTA EL NUEVO EQUIPO EN LA TABLA EQUIPO.*/
DELIMITER %%
CREATE PROCEDURE ALTA_EQUIPO (IN nombre_equipo_p VARCHAR(45),IN dt_equipo_p VARCHAR(45),
    IN cantidad_jugadores_p INT,IN id_torneo_p INT)
BEGIN
    DECLARE estado_registro_aux VARCHAR(2);
    DECLARE torneo_existe_aux INT;
    SELECT id_torneo INTO torneo_existe_aux FROM TORNEO WHERE id_torneo = id_torneo_p;
    -- Validar nombre de equipo
    IF nombre_equipo_p IS NULL OR nombre_equipo_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El nombre del equipo no puede ser nulo o vacío';
    END IF;
    -- Validar director técnico del equipo
    IF dt_equipo_p IS NULL OR dt_equipo_p = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El nombre del director técnico no puede ser nulo o vacío';
    END IF;
    -- Validar cantidad de jugadores del equipo
    IF cantidad_jugadores_p IS NULL OR (cantidad_jugadores_p < 7 OR cantidad_jugadores_p > 24) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La cantidad de jugadores debe estar entre 7 y 24';
    END IF;
    -- Verificar existencia del torneo
    IF torneo_existe_aux IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El torneo especificado no existe';
    END IF;
    -- Insertar nuevo equipo
    INSERT INTO EQUIPO (nombre_equipo, dt_equipo, cantidad_jugadores, fecha_registro, id_torneo)
    VALUES (nombre_equipo_p, dt_equipo_p, cantidad_jugadores_p, CURDATE(), id_torneo_p);
END %%
DELIMITER ;
CALL ALTA_EQUIPO("PORCINOS","Ibai",7,1);
CALL ALTA_EQUIPO("GALLOS FC","JJ",10,1);
CALL ALTA_EQUIPO("MAQUINA VOLI","JOSE",12,1);
SELECT * FROM EQUIPO;
# ------------------------------------------------------------------------------------------
CREATE TABLE USUARIO(
	id_usuario INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_usuario PRIMARY KEY(id_usuario),
    nickname VARCHAR(50) NOT NULL,
    CONSTRAINT Unq_nickname UNIQUE(nickname),
    nombre_usuario VARCHAR(45) NOT NULL,
	primer_ap VARCHAR(45) NOT NULL,
	segundo_ap VARCHAR(45),
    fecha_nacimiento DATE NOT NULL,
	email VARCHAR(30) NOT NULL, 
    CONSTRAINT Unq_email UNIQUE(email),
    password CHAR(255) NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE,
    nombre_equipo VARCHAR(45), -- NUEVA IMPLEMENTACION (PRUEBA)
	CONSTRAINT Fk_nombre_equipo FOREIGN KEY(nombre_equipo) REFERENCES EQUIPO(nombre_equipo) ON DELETE CASCADE ON UPDATE CASCADE -- NUEVA IMPLEMENTACION (PRUEBA)
  );
  # INSERT INTO JUGADOR(nickname,nombre_jugador,primer_ap,segundo_ap,fecha_nacimiento,email,password,fecha_entrada)
SELECT * FROM USUARIO;
-- DELETE FROM USUARIO WHERE id_usuario = 5;

-- DROP TABLE USUARIO;
# ------------------------------------------------------------------------------------------
CREATE TABLE JUGADOR(
	id_jugador INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_jugador PRIMARY KEY(id_jugador),
	-- nickname VARCHAR(50) NOT NULL,
    -- CONSTRAINT Unq_nickname UNIQUE(nickname),
    nombre_jugador VARCHAR(45) NOT NULL,
	primer_ap VARCHAR(45) NOT NULL,
	-- segundo_ap VARCHAR(45),
    -- fecha_nacimiento DATE NOT NULL,
    -- direccion VARCHAR(45),
	-- email VARCHAR(30) NOT NULL, -- NUEVA IMPLEMENTACION (PRUEBA)
	-- CONSTRAINT Unq_email UNIQUE(email),
    -- password CHAR(100) NOT NULL,	-- NUEVA IMPLEMENTACION (PRUEBA)
	fecha_entrada DATE NOT NULL,
    fecha_salida DATE,
    id_equipo INT,
    CONSTRAINT Fk_id_equipo FOREIGN KEY(id_equipo) REFERENCES EQUIPO(id_equipo) ON UPDATE CASCADE ON DELETE CASCADE
);
INSERT INTO JUGADOR(nombre_jugador,primer_ap,fecha_entrada,id_equipo)
 VALUES("Jazziel","Briones",now(),1),("mARINT","Castro",now(),2),("Rchi","Gibert",now(),3);

SELECT * FROM JUGADOR;
-- SELECT nombre_equipo FROM EQUIPO WHERE id_equipo= 1;
/* Ejemplos de formatos: Fecha "2021-01-30"  Hora "10:00:00"*/
/*INSERT INTO JUGADOR(nickname,nombre_jugador,primer_ap,segundo_ap,fecha_nacimiento,direccion,email,password,fecha_entrada,id_equipo)
 VALUES("JazzielGod","Jazziel","Briones","Herrera","2002-04-18","Avenida universidad/geologia y administracion","Jazzielbh@gmail.coom",sha1("123"),now(),1),
		("MartiLoera","Martin","Castro","Castro","2002-06-13","Santa fe","Martin@gmail.com",sha1("23"),now(),2),
        ("RicardoDODO","Ricardo","Gibert","Toledo","2002-01-22","Pedregal","Ricardo@gmail.com",sha1("34"),now(),3),
		("Fasadr","David","Talamantes","Castro","1998-02-08","Avenida universidad/geologia y administracion","David@gmail.com",sha1("45"),now(),1),
		("DonJor","Jorge","Ignacio","Perez","1969-01-20","Santa fe","Jorge@gmail.com",sha1("92"),now(),2),
        ("Developer","Alexis","Gasga","Ruiz","1998-06-30","Pedregal","Alexis@gmail.com",sha1("45"),now(),3);*/
-- INSERT INTO JUGADOR(id_equipo)VALUES(1);

# ------------------------------------------------------------------------------------------
CREATE TABLE DUEÑO_TORNEO(
	id_dueño_torneo INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_dueño_torneo PRIMARY KEY(id_dueño_torneo),
    nombre_dueño_torneo VARCHAR(45) NOT NULL,
    primer_ap VARCHAR(45) NOT NULL,
    segundo_ap VARCHAR(45),
    fecha_nacimiento DATE NOT NULL,
    id_torneo INT,
    CONSTRAINT Fk_id_torn FOREIGN KEY(id_torneo) REFERENCES TORNEO(id_torneo) ON UPDATE CASCADE ON DELETE CASCADE
);
INSERT INTO DUEÑO_TORNEO(nombre_dueño_torneo,primer_ap,segundo_ap,fecha_nacimiento,id_torneo)
VALUES("Francisco","Alvarez","Castro","1958-05-20",1),
		("Alvaro","Castro","Trinidad","1978-01-30",2),
        ("Eduardo","De la llave","Castro","1989-09-07",3);
SELECT * FROM DUEÑO_TORNEO;
# ---------------------------------------------------------------------------------------------------------
/*EL USO QUE TENDRA ESTA VISTA ES SENCILLA YA QUE SOLAMENTE MOSTRARA DATOS DEL CAMPO, COMO
QUE CALIFICACION TIENE, EL ESTADO DEL SERVICIO EN EL QUE SE ENCUENTRE, SU NOMBRE Y EN DONDE SE ENCUENTRA*/
CREATE VIEW DATOS_CAMPO AS
SELECT CA.tipo_campo,CA.calificacion,CA.hora_inicio,CA.hora_salida,CA.estado_servicio,CA.nombre_campo,
COL.nombre_colonia,COL.codigo_postal,COL.calle_principal,
COL.calle_secundaria,COL.referencias
FROM CAMPO AS CA
JOIN COLONIAS_OFICIALES AS COL
ON COL.id_colonia_oficial = CA.id_colonia_of;
-- DROP VIEW DATOS_CAMPO;
SELECT * FROM DATOS_CAMPO;
# ------------------------------------------------------------------------------------------
/* LA INFORMACION DE TORNEOS SE REFIERE TODO LO QUE CONLLEVA EL TORNEO ACTUAL, ES DECIR
SE MOSTRARAN DATOS COMO: EL TIPO DEL TORNEO, QUE TROFEO DARAN, EL NOMBRE DEL TORNEO, NOMBRE DEL CAMPO
CUANDO INICIA EL TORNEO Y QUE EQUIPOS ESTAN EN ESE TORNEO */
CREATE VIEW INFORMACION_TORNEOS AS
SELECT TOR.tipo_torneo,TRO.tipo_trofeo,TOR.nombre_torneo,CA.nombre_campo,TOR.fecha_inicio,
EQU.nombre_equipo,UPPER(EQU.dt_equipo)
FROM CAMPO AS CA
JOIN TROFEOS_OFICIALES AS TRO
ON TRO.id_trofeo_oficiales = CA.id_campo
JOIN TORNEO AS TOR
ON TOR.id_torneo = CA.id_campo
JOIN EQUIPO AS EQU
ON EQU.id_equipo = TOR.id_torneo
JOIN COLONIAS_OFICIALES AS COL
ON COL.id_colonia_oficial =  CA.id_colonia_of;
-- DROP VIEW INFORMACION_TORNEOS;

SELECT * FROM INFORMACION_TORNEOS;
# ------------------------------------------------------------------------------------------
/*LA TABLA DATOS COLONIAS ES PARA SABER LA INFORMACION DE LAS COLONIAS
PARA ASI ESTAR MAS INFORMADO Y SABER EN QUE LUGAR SE REALIZARAN LOS PARTIDOS
PROPORCIONA LA SIGUIENTE INFORMACION QUE SERIA EL NOMBRE DE LA COLONIA, SU CODIGO
POSTAL, LA CALLE PRINCIPAL, LAS REFERENCIAS, EL NOMBRE DE LOS CAMPOS, QUE TIPO DE CAMPOS HAY
Y EN QUE MUNICIPIO ESTAN (OJO) SI EN UNA COLONIA EXISTEN 3 CAMPOS DIFERENTES, CADA CAMPO TENDRA 
SU DIRECCION COMO EL EJEMPLO DE ABAJO, EN ESTE CASO, LOS 3 CAMPOS SE ENCUENTRAR JUNTOS, 
ENTONCES SU DIRECCION SERIA LA MISMA, A EXCEPCION DEL TIPO DE CAMPO DEL QUE ES.*/
CREATE VIEW DATOS_COLONIAS AS
SELECT lower(COL.nombre_colonia),COL.codigo_postal,
COL.calle_principal,COL.referencias,lower(CA.nombre_campo),lower(CA.tipo_campo),MUN.nombre_municipio
FROM COLONIAS_OFICIALES AS COL
JOIN CAMPO AS CA
ON COL.id_colonia_oficial = CA.id_colonia_of
JOIN MUNICIPIO AS MUN
ON MUN.id_municipio = COL.id_municipio;
-- DROP VIEW DATOS_COLONIAS;
SELECT * FROM DATOS_COLONIAS;
# ------------------------------------------------------------------------------------------
/*LOS ORGANIZADORES DE TORNEOS ES PARA TENER UN MEJOR CONTROL
SOBRE LOS TORNEOS QUE SE LLEVAN, LA INFORMACION QUE PROPORCIONARA SERA LA
SIGUIENTE; EL NOMBRE DEL DUEÑO DEL TORNEO, EL TIPO DE TORNEO QUE ES, EL 
TIPO DE TROFEO, EL NOMBRE DE LOS EQUIPOS QUE PARTICIPAN CON SU CANTIDAD DE JUGADORES
CON LOS QUE CUENTAN Y EL NOMBRE DEL TORNEO */
CREATE VIEW ORGANIZADORES_TORNEOS AS
SELECT DUE.nombre_dueño_torneo,TOR.tipo_torneo,TRO.nombre_trofeo_of,
TRO.tipo_trofeo,EQU.nombre_equipo,EQU.cantidad_jugadores,TOR.nombre_torneo
FROM DUEÑO_TORNEO AS DUE
JOIN TORNEO AS TOR
ON DUE.id_dueño_torneo = TOR.id_torneo
JOIN TROFEOS_OFICIALES AS TRO
ON TRO.id_trofeo_oficiales = TOR.id_torneo
JOIN EQUIPO AS EQU
ON EQU.id_equipo = TOR.id_torneo;
SELECT * FROM ORGANIZADORES_TORNEOS;
# ------------------------------------------------------------------------------------------
/*LOS EQUIPOS QUE ESTAN EN UN TORNEO APARECERAN JUNTO CON EL DIRECTOR TECNICO
DEL EQUIPO, JUNTO CON SUS JUGADORES PARA TENER UN VISTA CLARA AL MOMENTO DE MOSTRAR INFORMACION*/
 CREATE VIEW EQUIPOS_TORNEO AS
 SELECT EQU.nombre_equipo,JU.nombre_jugador,EQU.dt_equipo,TOR.nombre_torneo
 FROM EQUIPO AS EQU
 JOIN JUGADOR AS JU
 ON EQU.id_equipo = JU.id_equipo
 JOIN TORNEO AS TOR
 ON TOR.id_torneo = EQU.id_equipo;
-- DROP VIEW EQUIPOS_TORNEO;
/*SELECT * FROM EQUIPOS_TORNEO;
SELECT * FROM TORNEO;
SELECT * FROM TROFEOS_OFICIALES;
SELECT * FROM EQUIPO;
SELECT * FROM CAMPO;
SELECT * FROM MUNICIPIO;
SELECT * FROM COLONIAS_OFICIALES;
SELECT * FROM DUEÑO_TORNEO;
SELECT * FROM JUGADOR;*/
-- SHOW TABLES;
# ------------------------------------------------------------------------------------------
/*ESTA FUNCION SERVIRA PARA SABER LA CANTIDAD DE CAMPOS
QUE EXISTEN EN UNA COLONIA DE MANERA OFICIAL, REGISTRADOS
EN NUESTRA PLATAFORMA PARA ASI LLEVAR UN REGISTRO
Y ESTAR MAS ORGANIZADOS, INGRESANDO EL
NOMBRE DEL CAMPO*/
DELIMITER $$
CREATE FUNCTION CANTIDAD_CAMPOS(nombre_campo_p VARCHAR(45)) 
RETURNS VARCHAR(45)
DETERMINISTIC
BEGIN
  DECLARE cantidad_aux INT;
  SELECT COUNT(*) INTO cantidad_aux FROM CAMPO
  WHERE nombre_campo = nombre_campo_p;
  RETURN cantidad_aux;
END $$
DELIMITER ;
SELECT CANTIDAD_CAMPOS("MIRAMAR") AS "EL TOTAL DE CAMPOS OFICIALES ES DE: ";
# ------------------------------------------------------------------------------------------
/*ESTA FUNCION ES PARA SABER CON EXACTITUD LA
CANTIDAD DE EQUIPOS QUE ESTAN REGISTRADOS
POR TORNEO PARA LLEVAR UN MEJOR FUNCIONAMIENTO
A LA HORA DE ORGANIZAR LOS DATOS A FUTUROS.
INGRESANOD EL ID DEL TORNEO*/
DELIMITER $$
CREATE FUNCTION CANTIDAD_EQUIPOS_TORNEO(ID_torneo_p VARCHAR(45))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE cantidad_aux INT;
    DECLARE nombre_aux VARCHAR(45);
    SELECT COUNT(equipo.id_torneo) INTO cantidad_aux FROM EQUIPO  where ID_TORNEO = ID_TORNEO_P;
    RETURN cantidad_aux;
END $$
DELIMITER ;
-- SELECT NOMBRE_TORNEO, CANTIDAD_EQUIPOS_TORNEO(ID_TORNEO) FROM TORNEO;
SELECT CANTIDAD_EQUIPOS_TORNEO(1) AS "CANTIDAD DE EQUIPOS REGISTRADOS: ";
# ------------------------------------------------------------------------------------------
/*ESTA FUNCION SERVIRA PARA SOLICITAR LA CALIFICACION(ESTRELLAS)
QUE LLEVA CADA CAMPO REGISTRO DE MANERA OFICIAL EN 
NUESTRA PAGINA, DONDE EVALUAREMOS LA OPINION O LA 
ACEPTACION DE LOS USUARIOS HACIA LOS CAMPOS DEPORTIVOS
INGRESANDO EL ID DEL CAMPO, PARA SABER SU RESPECTIVA EVALUACION (CALIFICACION)*/
DELIMITER $$
CREATE FUNCTION CAMPO_CALIFICACION(id_campo_p INT)
RETURNS FLOAT
DETERMINISTIC
BEGIN
	DECLARE calif_aux FLOAT;
    SELECT calificacion INTO calif_aux FROM CAMPO
    WHERE id_campo = id_campo_p;
	return calif_aux;
END $$
DELIMITER ;
-- DROP FUNCTION CAMPO_CALIFICACION;
SELECT CAMPO_CALIFICACION(2) AS "LA CALIFICACION DE ESTE CAMPO ES DE: ";
# ------------------------------------------------------------------------------------------
/*ESTE TRIGGER SE UTILIZARA PARA ACTUALIZAR DATOS DE LA
TABLA EQUIPO, ESPECIFICAMENTE DOS COLUMNAS QUE SON:
ESTADO REGISTRO Y FECHA SALIDA, AL MOMENTO DE ACTUALIZAR LA COLUMNA
DE LA TABLA TORNEO QUE ES FECHA FINAL*/
DELIMITER $$
CREATE TRIGGER TRIGGER_ACT_EQUIPO
AFTER UPDATE ON TORNEO
FOR EACH ROW
BEGIN
	UPDATE EQUIPO
	SET estado_registro = 'NO INSCRITO', fecha_salida = curdate()
	WHERE id_torneo = NEW.id_torneo;
END $$
DELIMITER ;
-- SET SQL_SAFE_UPDATES = 1;
UPDATE TORNEO SET fecha_final = '2023-07-24' WHERE id_torneo = 1;
SELECT * FROM TORNEO;
SELECT * FROM EQUIPO;
/*ESTE TRIGGER TENDRA LA FUNCION DE ACTUALIZAR LA COLUMNA ESTADO SERVICIO
DE LA TABLA CAMPO A OCUPADO, AL MOMENTO DE INSERTAR UN VALOR EN LA TABLA TORNEO
ESPECIFICANDO QUE CAMPOS SE JUGARA LOS TORNEOS, ASI PONIENDOLOS EN OCUPADO*/
DELIMITER $$
CREATE TRIGGER TRIGGER_ACT_CAMPO
AFTER INSERT ON TORNEO
FOR EACH ROW
BEGIN
    UPDATE CAMPO
    SET estado_servicio = 'OCUPADO'
    WHERE id_campo = NEW.id_campo;
END $$
DELIMITER ;
SELECT * FROM TORNEO;
SELECT * FROM CAMPO;
INSERT INTO TORNEO(nombre_torneo,tipo_torneo,fecha_inicio,cantidad_equipos,id_campo,id_trofeo_of)
VALUES("CARP", "FUTBOL", "2023-07-09", 10, 1, 1);



create table RESERVAR_CAMPO(
	id_campo int primary key auto_increment,
    nombre varchar(50),
    telefono int(12),
    email varchar(100),
    asunto varchar(50),
    descripcion varchar(255)
);