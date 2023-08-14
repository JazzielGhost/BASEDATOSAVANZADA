-- CREADO POR JAZZIEL ABDIEL BRIONES HERRERA IDS T.V 6TO
###################################################################################################################################################
create database REFUGIO;
use REFUGIO;
-- drop database REFUGIO;
###################################################################################################################################################
describe TIPO_ANIMAL;
create table TIPO_ANIMAL(
	ID_ANIMAL int auto_increment,
    constraint PK_id_animal primary key(ID_ANIMAL),
    TIPO varchar(50),
    constraint Unq_tipo unique(TIPO)
);
insert into TIPO_ANIMAL(TIPO) values("Perro");
insert into TIPO_ANIMAL(TIPO) values("Gato");
select * from TIPO_ANIMAL;
####################################################################################################################################################
describe RAZA_ANIMAL;
select * from RAZA_ANIMAL;
create table RAZA_ANIMAL(
	ID_RAZA int auto_increment,
    constraint PK_id_raza primary key(ID_RAZA),
    NOMBRE_RAZA varchar(50),
    constraint Unq_nombre_raza unique(NOMBRE_RAZA)
);
INSERT INTO RAZA_ANIMAL(NOMBRE_RAZA)values("PASTOR ALEMAN"),("HUSKY SIBERIANO"),("SAN BERNARDO"),("DALMATA"),("CHICHUAHUA"),("AKITA INU"),("LABRADOR"),("BULLDOG"),("CORGI"),("DOBERMAN"),
										("MALAMUTE"),("GRAN DANES"),("MANX"),("EGIPCIO"),("SIAMES"),("SNOWSHOE"),
                                        ("MUCHKIN"),("AUSTRALIANO"),("AZUL RUSO"),("PERSA"),("SALCHICHA"),
                                        ("FRENCH POODLE"),("MESTIZO");
####################################################################################################################################################
-- drop table TAMANO_ANIMAL;
DESCRIBE TAMANO_ANIMAL;
select * from TAMANO_ANIMAL;
create table TAMANO_ANIMAL(
	ID_TAMANO int auto_increment,
    constraint Pk_id_tamano primary key(ID_TAMANO),
    TAMANO varchar(60),
    constraint CHK_TAMAnO check (TAMANO in("Pequeño", "Mediano","Grande"))
);
-- drop  table TAMAÑO_ANIMAL;
INSERT INTO TAMANO_ANIMAL (TAMANO) VALUES ("Pequeño");
INSERT INTO TAMANO_ANIMAL (TAMANO) VALUES ("Mediano");
INSERT INTO TAMANO_ANIMAL (TAMANO) VALUES ("Grande");
####################################################################################################################################################
DESCRIBE REGISTRO_ANIMAL;
SELECT * FROM REGISTRO_ANIMAL;
create table REGISTRO_ANIMAL(
	ID_REGISTRO int auto_increment,
    constraint PK_id_registro primary key(ID_REGISTRO),
	NOMBRE_MASCOTA VARCHAR(50) NOT NULL,
	CONSTRAINT UNQ_Nombre_Mascota UNIQUE(NOMBRE_MASCOTA),
    TIPO_MASCOTA INT,
    constraint FK_tipo_mascot foreign key(TIPO_MASCOTA) references TIPO_ANIMAL(ID_ANIMAL) ON DELETE CASCADE ON UPDATE CASCADE,
    RAZA int default 23,
    constraint FK_raza foreign key(RAZA) references RAZA_ANIMAL(ID_RAZA) ON DELETE CASCADE ON UPDATE CASCADE,
	TAMANO int,
    constraint FK_tamaño foreign key(TAMANO) references TAMANO_ANIMAL(ID_TAMANO)ON DELETE CASCADE ON UPDATE CASCADE,
    EDAD INT,
    constraint Chk_edad check(EDAD >= 0),
    COLOR varchar(50),
    FECHA_ADMISION date,
    ESTADO INT default 1,
    constraint Chk_estado check(ESTADO= 1 OR ESTADO = 2)
);
####################################################################################################################################################
DESCRIBE REGISTRO_PERSONA;
select * from REGISTRO_PERSONA;
create table REGISTRO_PERSONA(
	ID_PERSONA INT auto_increment,
    constraint PK_id_persona primary key(ID_PERSONA),
    NOMBRE VARCHAR(80) NOT NULL,
	PRIMER_APELLIDO VARCHAR(50) NOT NULL,
	SEGUNDO_APELLIDO VARCHAR(50),
	TELEFONO char(15),
	DIRECCION VARCHAR(80),
	CORREO VARCHAR(80),
    constraint Unq_correo unique(CORREO)
);
-- drop table REGISTRO_PERSONA;
insert into REGISTRO_PERSONA(NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,TELEFONO,DIRECCION,CORREO)
 VALUES("OSKAR","VELAZQUEZ","ROMERO",6121489265,"BIZANGA,COLONIA INDECO","OSKAR_ROMERO@GMAIL.COM");
 insert into REGISTRO_PERSONA(NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,TELEFONO,DIRECCION,CORREO)
values("JOSEFINA","ANGULO","DIAZ",6122194521,"ANTONIO MA RUIZ, COL AYUNTAMIENTO","ANGULO_JOSE@HOTMAIL.COM");
 insert into REGISTRO_PERSONA(NOMBRE,PRIMER_APELLIDO,SEGUNDO_APELLIDO,TELEFONO,DIRECCION,CORREO)
 values("DANIEL ALEJANDRO","GUTIERREZ","LOPEZ",6122763843,"TORONJA,COLONIA INDECO","DANIELITO@GMAIL.COM");
####################################################################################################################################################
DESCRIBE REGISTRO_ADOPCION;
select * from REGISTRO_ADOPCION;
create table REGISTRO_ADOPCION(
	ID_ADOPCION int AUTO_INCREMENT,
    constraint PK_id_adopcion primary key (ID_ADOPCION),
	ID_MASCOTA int,
	constraint FK_id_mascota FOREIGN KEY (ID_MASCOTA) references REGISTRO_ANIMAL(ID_REGISTRO)  on update cascade,
	ID_PERSONA int,
    constraint FK_id_persona FOREIGN KEY (ID_PERSONA) REFERENCES REGISTRO_PERSONA(ID_PERSONA)  on update cascade,
	FECHA_ADOPCION DATE
);
/*insert into REGISTRO_ADOPCION(ID_MASCOTA,ID_PERSONA,FECHA_ADOPCION) 
VALUES (5,2,"2016-10-15");
*/
####################################################################################################################################################
delimiter //
create procedure añadirRegistro_Animal(in nombre varchar(80),in tipo int,in raza int,
in tamano int,in edad int,in color varchar(60),in fecha_admision date)
begin
    IF raza  = "" OR raza is NULL then set raza = 23;
    end if;
	insert into Registro_Animal(NOMBRE_MASCOTA,TIPO_MASCOTA,RAZA,TAMANO,EDAD,COLOR,FECHA_ADMISION) values(nombre,tipo,raza,tamano,edad,color,fecha_admision);
end //
delimiter ;
select * from REGISTRO_ANIMAL;
call añadirRegistro_Animal("HUESOS",1,9,2,3,"CAFE","2015-10-10");
CALL añadirRegistro_Animal("KAISER",1,1,3,2,"CAFE/NEGRO","2014-10-15");
CALL añadirRegistro_Animal("DINOSAURIO",1,5,1,1,"CAFE","2015-10-20");
CALL añadirRegistro_Animal("BOLA DE NIEVE",2,21,2,1,"BLANCO","2015-10-30");
CALL añadirRegistro_Animal("LUCKY",1,22,1,4,"BLANCO","2015-11-04");
CALL añadirRegistro_Animal("MICHU",2,9,2,1,"NEGRO","2015-11-22");
CALL añadirRegistro_Animal("PRINCIPE",1,19,1,1,"DORADO","2015-12-30");
CALL añadirRegistro_Animal("SENOR SALCHICHA",1,21,1,8,"CAFE","2016-01-04");
CALL añadirRegistro_Animal("MR.BIGOTES",1,21,1,8,"CAFE","2016-02-15");
CALL añadirRegistro_Animal("CHILAQUIL",1,9,1,4,"CAFE/NEGRO","2016-03-27");
CALL añadirRegistro_Animal("ROMANOV",2,19,2,2,"GRIS","2016-04-28");
CALL añadirRegistro_Animal("OREO",2,17,2,1,"BLANCO/NEGRO","2016-04-28");
CALL añadirRegistro_Animal("BALAK",1,1,2,2,"NEGRO","2016-04-28");
-- drop procedure añadirRegistro_Animal;
####################################################################################################################################################
-- DROP PROCEDURE IF EXISTS añadirRegistro_Adopcion;
delimiter // 
create procedure añadirRegistro_Adopcion(in nombre_mascota varchar(70),in correo_persona varchar(70),in fecha_adopcion date)
begin
declare persona_id int;
declare mascota_id int;
	SELECT ID_PERSONA INTO persona_id FROM REGISTRO_PERSONA WHERE CORREO = correo_persona limit 1;
	SELECT ID_REGISTRO INTO mascota_id FROM REGISTRO_ANIMAL WHERE NOMBRE_MASCOTA = nombre_mascota limit 1;
    IF persona_id IS NOT null and mascota_id IS NOT NULL THEN 
			INSERT INTO REGISTRO_ADOPCION (ID_MASCOTA, ID_PERSONA, FECHA_ADOPCION) VALUES (mascota_id, persona_id, fecha_adopcion);
		ELSE
			SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La mascota o persona no existe'; 
		end if;
END //
delimiter ;
CALL añadirRegistro_Adopcion("MR.BIGOTES","OSKAR_ROMERO@GMAIL.COM","2016-02-24");
CALL añadirRegistro_Adopcion("HUESOS","ANGULO_JOSE@HOTMAIL.COM","2016-04-05");
CALL añadirRegistro_Adopcion("PRINCIPE","DANIELITO@GMAIL.COM","2016-04-10");
CALL añadirRegistro_Adopcion("BALAK","ANGULO_JOSE@HOTMAIL.COM","2016-04-15");
SELECT * FROM REGISTRO_ANIMAL;
SELECT * FROM REGISTRO_ADOPCION;
####################################################################################################################################################
delimiter //
create trigger Actualizar_estado_mascota
after insert on REGISTRO_ADOPCION
for each row
begin
	UPDATE REGISTRO_ANIMAL SET ESTADO = 2 WHERE ID_REGISTRO = NEW.ID_MASCOTA;	
end //
delimiter ;
 -- drop trigger Actualizar_estado_mascota;
####################################################################################################################################################
DELIMITER //
CREATE FUNCTION Obtener_Estado_Mascota(nombre VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE estado_final int;
	SELECT ESTADO INTO estado_final FROM REGISTRO_ANIMAL WHERE NOMBRE_MASCOTA = nombre;
    if estado_final = 1 then
		return 'SIN ADOPTAR';
    else
		return 'ADOPTADO';
    end if;
    RETURN estado_final;
END//
DELIMITER ;
SELECT Obtener_Estado_Mascota("MR.BIGOTES");
SELECT Obtener_Estado_Mascota("HUESOS");
SELECT Obtener_Estado_Mascota("PRINCIPE");
SELECT Obtener_Estado_Mascota("BALAK");
 -- drop function Obtener_Estado_Mascota;
####################################################################################################################################################
#1. MUESTRA TODA LA INFORMACIÓN DE REGISTRO_ANIMAL
SELECT * FROM REGISTRO_ANIMAL;
####################################################################################################################################################
#2. MUESTRA TODOS LOS NOMBRES Y DIRECCIONES DE REGISTRO_PERSONA
SELECT NOMBRE,DIRECCION FROM REGISTRO_PERSONA;
####################################################################################################################################################
#3. MUESTRA EL NOMBRE DEL ANIMAL,NOMBRE DE RAZA Y DESCRIPCIÓN DEL 
# TAMAÑO (NO EL ID DE RAZA Y TAMAÑO) DE LOS ANIMALES SIN ADOPTAR
SELECT NOMBRE_MASCOTA AS "Nombre",RAZA_ANIMAL.NOMBRE_RAZA AS "Raza",TAMANO_ANIMAL.TAMANO FROM REGISTRO_ANIMAL 
INNER JOIN 
RAZA_ANIMAL ON REGISTRO_ANIMAL.RAZA= RAZA_ANIMAL.ID_RAZA
INNER JOIN 
TAMANO_ANIMAL ON TAMANO_ANIMAL.ID_TAMANO = REGISTRO_ANIMAL.TAMANO WHERE ESTADO = 1;
SELECT * FROM RAZA_ANIMAL;
SELECT * FROM REGISTRO_ANIMAL;
####################################################################################################################################################
#4. MUESTRA EL TOTAL DE ANIMALES SIN 
use REFUGIO;
SELECT COUNT(*) AS "TOTAL ANIMALES SIN ADOPTAR" FROM REGISTRO_ANIMAL WHERE ESTADO = 1;
####################################################################################################################################################
#5. MUESTRA EL TOTAL DE ANIMALES ADOPTADOS
SELECT COUNT(*) AS "TOTAL ANIMALES ADOPTADOS" FROM REGISTRO_ANIMAL WHERE ESTADO = 2;
####################################################################################################################################################
#6. MUESTRA LOS ANIMALES CON FECHA DE ADMISIÓN DEL 2015
SELECT * FROM REGISTRO_ANIMAL WHERE YEAR(FECHA_ADMISION) = 2015;
####################################################################################################################################################
/*7. MUESTRA SIN REPETIR EL NOMBRE DE LA RAZA DE LOS ANIMALES REGISTRADOS 
ORDENADOS ALFABÉTICAMENTE*/
SELECT RAZA_ANIMAL.NOMBRE_RAZA AS "Raza" FROM REGISTRO_ANIMAL
INNER JOIN 
RAZA_ANIMAL ON REGISTRO_ANIMAL.RAZA = RAZA_ANIMAL.ID_RAZA GROUP BY RAZA ORDER BY RAZA;
####################################################################################################################################################
/*8. MUESTRA EL NOMBRE DEL ANIMAL, TIPO, RAZA, TAMAÑO, EDAD Y EL ESTADO 
(MOSTRAR “ADOPTADO” O “SIN ADOPTAR”) DE LOS ANIMALES REGISTRADOS, 
ORDENADOS DE MENOR A MAYOR EDAD.*/
SELECT NOMBRE_MASCOTA AS "Nombre", TIPO_ANIMAL.TIPO AS "Tipo", RAZA_ANIMAL.NOMBRE_RAZA AS "Raza", EDAD, Obtener_Estado_Mascota(nombre_mascota) AS "Estado" FROM REGISTRO_ANIMAL
INNER JOIN TIPO_ANIMAL ON TIPO_ANIMAL.ID_ANIMAL = REGISTRO_ANIMAL.ID_REGISTRO
INNER JOIN RAZA_ANIMAL ON RAZA_ANIMAL.ID_RAZA = REGISTRO_ANIMAL.RAZA ORDER BY EDAD DESC;
USE REFUGIO;
####################################################################################################################################################
/*9. HACER UNA VISTA EN DONDE MUESTRA LA INFORMACIÓN DE LOS ANIMALES ADOPTADOS: 
NOMBRE COMPLETO DE LA PERSONA QUE ADOPTO (EN UNA SOLA COLUMNA), NOMBRE DE 
LA MASCOTA, EDAD, RAZA FECHA DE ADMISIÓN Y FECHA DE ADOPCIÓN.*/
SELECT CONCAT(REGISTRO_PERSONA.NOMBRE," ",REGISTRO_PERSONA.PRIMER_APELLIDO," ",coalesce(REGISTRO_PERSONA.SEGUNDO_APELLIDO,"")) AS "Nombre Completo",
NOMBRE_MASCOTA AS "Nombre de Mascota", EDAD, RAZA_ANIMAL.NOMBRE_RAZA AS "Raza",FECHA_ADMISION AS "Fecha de Admision",
REGISTRO_ADOPCION.FECHA_ADOPCION AS "Fecha de Adopcion" FROM REGISTRO_ANIMAL
INNER JOIN
RAZA_ANIMAL ON RAZA_ANIMAL.ID_RAZA = REGISTRO_ANIMAL.RAZA
INNER JOIN 
REGISTRO_ADOPCION ON REGISTRO_ADOPCION.ID_MASCOTA = REGISTRO_ANIMAL.ID_REGISTRO
INNER JOIN
REGISTRO_PERSONA ON REGISTRO_PERSONA.ID_PERSONA = REGISTRO_ADOPCION.ID_PERSONA; 
####################################################################################################################################################
SELECT RAZA_ANIMAL.NOMBRE_RAZA AS "Raza", COUNT(*) AS "Total Registrados"FROM REGISTRO_ANIMAL
INNER JOIN 
RAZA_ANIMAL ON RAZA_ANIMAL.ID_RAZA = REGISTRO_ANIMAL.ID_REGISTRO GROUP BY NOMBRE_RAZA;

####################################################################################################################################################
SELECT TIPO_ANIMAL.TIPO, COUNT(*) AS "Total" FROM REGISTRO_ANIMAL
INNER JOIN
TIPO_ANIMAL ON TIPO_ANIMAL.ID_ANIMAL = REGISTRO_ANIMAL.ID_REGISTRO GROUP By TIPO; 
####################################################################################################################################################
SELECT TAMANO_ANIMAL.TAMANO AS "Tamano", COUNT(*) AS "Total" FROM REGISTRO_ANIMAL
INNER JOIN 
TAMANO_ANIMAL ON TAMANO_ANIMAL.ID_TAMANO = REGISTRO_ANIMAL.TAMANO GROUP BY TAMANO;
####################################################################################################################################################
SELECT NOMBRE_MASCOTA, RAZA, EDAD
FROM REGISTRO_ANIMAL
WHERE NOMBRE_MASCOTA LIKE '%IC%' OR NOMBRE_MASCOTA LIKE '%O';

####################################################################################################################################################
SELECT NOMBRE_MASCOTA, RAZA_ANIMAL.NOMBRE_RAZA AS "RAZA" FROM REGISTRO_ANIMAL
INNER JOIN 
RAZA_ANIMAL ON RAZA_ANIMAL.ID_RAZA = REGISTRO_ANIMAL.RAZA
INNER JOIN TIPO_ANIMAL ON TIPO_ANIMAL.ID_ANIMAL = REGISTRO_ANIMAL.TIPO_MASCOTA WHERE TIPO = "Perro";
####################################################################################################################################################
SELECT * FROM TIPO_ANIMAL;
SELECT * FROM registro_animal;
SELECT * FROM raza_animal;
####################################################################################################################################################
SELECT CONCAT(NOMBRE," ",PRIMER_APELLIDO," ",coalesce(SEGUNDO_APELLIDO,"")) AS "Nombre Completo", TELEFONO, DIRECCION, CORREO, COUNT(*) AS "Adoptaciones" FROM REGISTRO_PERSONA
INNER JOIN REGISTRO_ADOPCION ON REGISTRO_ADOPCION.ID_PERSONA = REGISTRO_PERSONA.ID_PERSONA GROUP BY REGISTRO_PERSONA.ID_PERSONA;
####################################################################################################################################################
SELECT *
FROM REGISTRO_ANIMAL
WHERE FECHA_ADMISION >= '2015-10-01' AND FECHA_ADMISION <= '2016-02-29';
####################################################################################################################################################
SELECT YEAR(FECHA_ADMISION) AS "Año", COUNT(*) AS "Total de registros"
FROM REGISTRO_ANIMAL
GROUP BY YEAR(FECHA_ADMISION);
####################################################################################################################################################
SELECT NOMBRE_MASCOTA, RAZA, COLOR, EDAD
FROM REGISTRO_ANIMAL
WHERE ID_REGISTRO IN (2, 4, 5, 8, 9, 11, 13);
SELECT * FROM registro_animal;
####################################################################################################################################################
show tables;
####################################################################################################################################################