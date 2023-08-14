Create database Fieldercommuniti;
use Fieldercommuniti;
show tables;
CREATE TABLE MUNICIPIO(
	id_municipio INT AUTO_INCREMENT,
    CONSTRAINT Pk_id_municipio PRIMARY KEY(id_municipio),
    nombre_municipio VARCHAR(45) NOT NULL,
	CONSTRAINT Unq_nombre_municipio UNIQUE (nombre_municipio)
);
INSERT INTO MUNICIPIO(nombre_municipio) VALUE("LA PAZ"),("COMONDÚ"),("LOS CABOS");

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
SELECT * FROM TROFEOS_OFICIALES;
INSERT INTO TROFEOS_OFICIALES (nombre_trofeo_of,descripcion_trofeo,tipo_trofeo)
VALUES("AA","OJO",NULL);

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

CREATE TABLE COLONIAS_OFICIALES(
	id_colonia_oficial INT AUTO_INCREMENT,
    CONSTRAINT PK_id_colonia_oficial PRIMARY KEY(id_colonia_oficial),
    nombre_colonia VARCHAR(45) NOT NULL,
    codigo_postal VARCHAR(5) NOT NULL,
    calle_principal VARCHAR(45) NOT NULL,
    calle_secundaria VARCHAR(45),
    referencias VARCHAR(200),
    id_municipio INT,
    CONSTRAINT Fk_id_municipio FOREIGN KEY(id_municipio) REFERENCES MUNICIPIO(id_municipio) ON DELETE CASCADE ON UPDATE CASCADE
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
    CONSTRAINT FK_id_colonia_of FOREIGN KEY(id_colonia_of) REFERENCES COLONIAS_OFICIALES(id_colonia_oficial) ON UPDATE CASCADE ON DELETE CASCADE,
	ubicacion_gps varchar(255)
); 

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

INSERT INTO `CAMPO` (`nombre_campo`, `calificacion`, `estado_servicio`, `tipo_campo`, `hora_inicio`, `hora_salida`, `id_colonia_of`, `ubicacion_gps`) VALUES
('Ruiz Cortinez', 5, 'OCUPADO', 'FUTBOL', '08:00:00', NULL, 1, 'https://goo.gl/maps/y2zmyzuYtJ31ZTDZ8'),
('Nuevo Sol', 5, 'LIBRE', 'FUTBOL', '08:00:00', NULL, 1, 'https://goo.gl/maps/koWyfxekRBkXyVq36'),
('Campo Normal Urbana', 2, 'LIBRE', 'FUTBOL', '08:00:00', NULL, 1, 'https://goo.gl/maps/PRFSXkr6xAU3cd397'),
('Campo UABCS', 1, 'LIBRE', 'FUTBOL', '08:00:00', NULL, 2, 'https://goo.gl/maps/daDG7bUrSLEohYSB8');
# ------------------------------------------------------------------------------------------
SELECT * FROM CAMPO;
SELECT * FROM COLONIAS_OFICIALES;

SELECT id_colonia_oficial FROM COLONIAS_OFICIALES WHERE nombre_colonia = "Miramar";



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

INSERT INTO  TORNEO(nombre_torneo, tipo_torneo, fecha_inicio, fecha_final, cantidad_equipos, id_campo, id_trofeo_of) 
VALUES("PAPALUCA", "FUTBOL", "2022-01-01", null, 8,1,1);
select * from torneo;
select * from trofeos_oficiales;
INSERT INTO TORNEO(nombre_torneo,tipo_torneo,fecha_inicio,cantidad_equipos,id_campo,id_trofeo_of)
VALUES("RELAMPAGO","FUTBOL","2023-06-01 08:00:00",8,1,1),
		("RELAMPAGO II","FUTBOL RAPIDO","2023-05-19 010:00:00",8,2,2),
        ("RELAMPAGO VOLI","VOLEIBOL","2023-05-01 14:00:00",8,3,3);


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


CREATE VIEW DATOS_CAMPO AS
SELECT CA.tipo_campo,CA.calificacion,CA.hora_inicio,CA.hora_salida,CA.estado_servicio,CA.nombre_campo,
COL.nombre_colonia,COL.codigo_postal,COL.calle_principal,
COL.calle_secundaria,COL.referencias
FROM CAMPO AS CA
JOIN COLONIAS_OFICIALES AS COL
ON COL.id_colonia_oficial = CA.id_colonia_of;



CREATE VIEW INFORMACION_TORNEOS AS
SELECT TOR.tipo_torneo,TRO.tipo_trofeo,TOR.nombre_torneo,CA.nombre_campo,TOR.fecha_inicio
FROM CAMPO AS CA
JOIN TORNEO AS TOR
ON TOR.id_campo = CA.id_campo
JOIN TROFEOS_OFICIALES AS TRO
ON TRO.id_trofeo_oficiales = TOR.id_trofeo_of;

SELECT * FROM INFORMACION_TORNEOS;

CREATE TABLE FAVORITOS(
	id_favorito int auto_increment,
    CONSTRAINT PK_id_favorito PRIMARY KEY(id_favorito)

);



SELECT TOR.tipo_torneo,TRO.tipo_trofeo,TOR.nombre_torneo,CA.nombre_campo,TOR.fecha_inicio
FROM CAMPO AS CA
JOIN TORNEO AS TOR
ON TOR.id_torneo = TRO.id_trofeo_of
JOIN TROFEOS_OFICIALES AS TRO;


SELECT * FROM TORNEO;


CREATE VIEW DATOS_COLONIAS AS
SELECT lower(COL.nombre_colonia),COL.codigo_postal,
COL.calle_principal,COL.referencias,lower(CA.nombre_campo),lower(CA.tipo_campo),MUN.nombre_municipio
FROM COLONIAS_OFICIALES AS COL
JOIN CAMPO AS CA
ON COL.id_colonia_oficial = CA.id_colonia_of
JOIN MUNICIPIO AS MUN
ON MUN.id_municipio = COL.id_municipio;


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

 CREATE VIEW EQUIPOS_TORNEO AS
 SELECT EQU.nombre_equipo,JU.nombre_jugador,EQU.dt_equipo,TOR.nombre_torneo
 FROM EQUIPO AS EQU
 JOIN JUGADOR AS JU
 ON EQU.id_equipo = JU.id_equipo
 JOIN TORNEO AS TOR
 ON TOR.id_torneo = EQU.id_equipo;


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

