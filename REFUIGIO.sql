CREATE DATABASE REFUGIO;
USE REFUGIO;

#DROP DATABASE REFUGIO;

CREATE TABLE Tipo_animal(ID_tipo_animal INT AUTO_INCREMENT,
						CONSTRAINT PK_ID_tipo_animal PRIMARY KEY(ID_tipo_animal),
                        tipo VARCHAR(70),
                        CONSTRAINT UQ_tipo UNIQUE(tipo)
 
);
INSERT INTO Tipo_animal(tipo)VALUES("PERRO");
INSERT INTO Tipo_animal(tipo)VALUES("GATO");

CREATE TABLE Raza_animal(ID_Raza_animal INT AUTO_INCREMENT,
                        CONSTRAINT PK_ID_Raza_animal PRIMARY KEY(ID_Raza_animal),
                        nombre_raza VARCHAR(70),
                        CONSTRAINT UQ_nombre_raza UNIQUE(nombre_raza)
);

CREATE TABLE Tamano_animal(ID_tamano INT AUTO_INCREMENT,
						CONSTRAINT PK_ID_tamano PRIMARY KEY(ID_tamano),
                        tamano VARCHAR(70),
                        CONSTRAINT CK_tamano CHECK(tamano IN ("Pequeño", "Mediano" , "Grande"))
);
INSERT INTO Tamano_animal(tamano)values("Pequeño");
INSERT INTO Tamano_animal(tamano)values("Mediano");
INSERT INTO Tamano_animal(tamano)values("Grande");

CREATE TABLE Registro_animal(ID_registro_animal INT AUTO_INCREMENT,
							CONSTRAINT PK_registro_animal PRIMARY KEY(ID_registro_animal),
                            nombre_mascota VARCHAR(70) NOT NULL,
                            CONSTRAINT UQ_nombre_mascota UNIQUE(nombre_mascota),
                            ID_tipo_animal INT,
                            CONSTRAINT FK_ID_tipo_animal FOREIGN KEY(ID_tipo_animal) REFERENCES Tipo_animal(ID_tipo_animal) ON UPDATE CASCADE ON DELETE CASCADE,
                            ID_Raza_animal INT DEFAULT 23,
                            CONSTRAINT FK_ID_Raza_animal FOREIGN KEY(ID_Raza_animal) REFERENCES Raza_animal(ID_Raza_animal)ON UPDATE CASCADE ON DELETE CASCADE,
                            ID_tamano INT,
                           CONSTRAINT FK_ID_tamano FOREIGN KEY(ID_tamano) REFERENCES Tamano_animal(ID_tamano)ON UPDATE CASCADE ON DELETE CASCADE,
                            edad INT,
                            CONSTRAINT CK_edad CHECK(edad >=0),
                            color VARCHAR(70),
                            fecha_admission DATE,
                            estado INT DEFAULT 1,
                            CONSTRAINT CK_estado CHECK(estado = 1 OR estado = 2)
                            );

#ALTER TABLE Registro_animal drop FOREIGN KEY FK_ID_registro_animal;


CREATE TABLE Registro_persona(ID_persona INT AUTO_INCREMENT,
							CONSTRAINT PK_ID_persona PRIMARY KEY(ID_persona),
                            nombre VARCHAR(70) NOT NULL,
                            primer_appellido VARCHAR(70) NOT NULL,
                            segundo_apellido VARCHAR(70),
                            telefono CHAR(10),
                            direcion VARCHAR(100),
                            correo VARCHAR(70),
                            CONSTRAINT UQ_correco UNIQUE(correo));
                            

############################### REGISTER PERSON STORED PROCEDURE############
DELIMITER $$
CREATE PROCEDURE SP_Registro_persona(IN nombre VARCHAR(70),IN primer_appellido VARCHAR(70),IN segundo_appellido VARCHAR(70), IN telefono CHAR(10),IN direcion VARCHAR(70), IN correo VARCHAR(70) )
BEGIN 
INSERT INTO Registro_persona(nombre,primer_appellido,segundo_apellido,telefono,direcion,correo) 
VALUES(nombre,primer_appellido,segundo_apellido,telefono,direcion,correo);
END$$
DELIMITER ;


CREATE TABLE Registro_adopcion(ID_adopcion INT AUTO_INCREMENT,
								CONSTRAINT PK_ID_adopcion PRIMARY KEY(ID_adopcion),
								ID_registro_animal INT,
                                CONSTRAINT FK_ID_registro_animal FOREIGN KEY(ID_registro_animal) REFERENCES Registro_animal(ID_registro_animal),
                                ID_persona INT,
                                CONSTRAINT FK_ID_persona FOREIGN KEY(ID_persona) REFERENCES Registro_persona(ID_persona),
                                fecha_adopcion DATE

);

############################### REGISTER ANIMAL STORED PROCEDURE############
DELIMITER $$
CREATE PROCEDURE SP_registro_animal(IN nombre_mascota VARCHAR(70), IN ID_tipo_animal  INT, IN ID_Raza_animal  INT, 
									IN ID_tamano INT, IN edad INT, IN color VARCHAR(70), IN fecha_admission DATE)
BEGIN
IF ID_Raza_animal  = "" OR ID_Raza_animal is NULL then set ID_Raza_animal = 23;
END IF;
INSERT INTO Registro_animal(nombre_mascota,ID_tipo_animal,ID_Raza_animal ,ID_tamano,edad,color,fecha_admission)
VALUES(nombre_mascota,ID_tipo_animal,ID_Raza_animal ,ID_tamano,edad,color,fecha_admission);
END$$

DELIMITER ;


############################### REGISTER ADOPTION STORED PROCEDURE############
DELIMITER $$
CREATE PROCEDURE SP_registro_adopcion(IN name_mascota VARCHAR(70), IN email VARCHAR(70), IN fecha_admission DATE)
BEGIN
DECLARE TEMP_persona INT;
DECLARE TEMP_mascota INT;

SELECT ID_persona INTO TEMP_persona FROM registro_persona WHERE correo = email;
SELECT ID_registro_animal INTO TEMP_mascota FROM registro_animal WHERE nombre_mascota = name_mascota;

IF TEMP_persona IS NOT NULL THEN 
	IF TEMP_mascota IS NOT NULL THEN 
    INSERT INTO Registro_adopcion(ID_registro_animal,ID_persona, fecha_adopcion)VALUES(TEMP_mascota,TEMP_persona,fecha_admission);
	ELSE
    SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La mascota no existe'; 
    end if;
ELSE
 SIGNAL SQLSTATE '45000'SET MESSAGE_TEXT = 'La persona no existe';
end if;

END$$
DELIMITER ;

############################### TRIGGER ############
DELIMITER $$
CREATE TRIGGER TRI_adopcion
AFTER INSERT
	ON Registro_adopcion
FOR EACH ROW
BEGIN
 UPDATE Registro_animal SET estado = 2 WHERE ID_registro_animal = NEW.ID_registro_animal;
END$$

DELIMITER ;

############################### FUNCTIUON ############
DELIMITER $$
CREATE FUNCTION FUNC_estado(name_mascota VARCHAR(70))
          RETURNS varchar(70) DETERMINISTIC
          BEGIN
         declare result INT;
          
          SELECT estado INTO result FROM Registro_animal WHERE nombre_mascota = name_mascota;
		IF result = 1 THEN return "SIN ADOPTAR";
          ELSE RETURN "ADOPTADO";
		END IF;
          RETURN result;
          END$$

DELIMITER ; 


INSERT INTO Raza_animal(nombre_raza)values("PASTOR ALEMAN"),("HUSKY SIBERIANO"),("SAN BERNARDO"),("DALMATA"),("CHICHUAHUA"),("AKITA INU"),("LABRADOR"),("BULLDOG"),("CORGI"),("DOBERMAN"),
										("MALAMUTE"),("GRAN DANES"),("MANX"),("EGIPCIO"),("SIAMES"),("SNOWSHOE"),
                                        ("MUCHKIN"),("AUSTRALIANO"),("AZUL RUSO"),("PERSA"),("SALCHICHA"),
                                        ("FRENCH POODLE"),("MESTIZO");


CALL SP_registro_animal("HUESOS",1,9,2,3,"CAFE","2015-10-10");
CALL SP_registro_animal("KAISER",1,1,3,2,"CAFE/NEGRO","2014-10-15");
CALL SP_registro_animal("DINOSAURIO",1,5,1,1,"CAFE","2015-10-20");
CALL SP_registro_animal("BOLA DE NIEVE",2,21,2,1,"BLANCO","2015-10-30");
CALL SP_registro_animal("LUCKY",1,22,1,4,"BLANCO","2015-11-04");
CALL SP_registro_animal("MICHU",2,9,2,1,"NEGRO","2015-11-22");
CALL SP_registro_animal("PRINCIPE",1,19,1,1,"DORADO","2015-12-30");
CALL SP_registro_animal("SENOR SALCHICHA",1,21,1,8,"CAFE","2016-01-04");
CALL SP_registro_animal("MR.BIGOTES",1,21,1,8,"CAFE","2016-02-15");
CALL SP_registro_animal("CHILAQUIL",1,9,1,4,"CAFE/NEGRO","2016-03-27");
CALL SP_registro_animal("ROMANOV",2,19,2,2,"GRIS","2016-04-28");
CALL SP_registro_animal("OREO",2,17,2,1,"BLANCO/NEGRO","2016-04-28");
CALL SP_registro_animal("BALAK",1,1,2,2,"NEGRO","2016-04-28");

CALL SP_Registro_persona("OSKAR","VELAZQUEZ","ROMERO",6121489265,"BIZANGA,COLONIA INDECO","OSKAR_ROMERO@GMAIL.COM");
CALL SP_Registro_persona("JOSEFINA","ANGULO","DIAZ",6122194521,"ANTONIO MA RUIZ, COL AYUNTAMIENTO","ANGULO_JOSE@HOTMAIL.COM");
CALL SP_Registro_persona("DANIEL ALEJANDRO","GUTIERREZ","LOPEZ",6122763843,"TORONJA,COLONIA INDECO","DANIELITO@GMAIL.COM");

CALL SP_registro_adopcion("BOLA DE NIEVE","OSKAR_ROMERO@GMAIL.COM","2016-02-24");
CALL SP_registro_adopcion("HUESOS","ANGULO_JOSE@HOTMAIL.COM","2016-04-05");
CALL SP_registro_adopcion("KAISER","DANIELITO@GMAIL.COM","2016-04-10");
CALL SP_registro_adopcion("ROMANOV","ANGULO_JOSE@HOTMAIL.COM","2016-04-15");

###########################################################################################################################
#✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️ Realiza las siguientes sentencias SQL:✏️✏️✏️✏️✏️✏️✏️✏️✏️✏️

#1. MUESTRA TODA LA INFORMACIÓN DE REGISTRO_ANIMAL ✅
SELECT * from Registro_animal;

#2. MUESTRA TODOS LOS NOMBRES Y DIRECCIONES DE REGISTRO_PERSONA ✅
SELECT nombre, direcion FROM Registro_persona;

#3. MUESTRA EL NOMBRE DEL ANIMAL,NOMBRE DE RAZA Y DESCRIPCIÓN DEL TAMAÑO (NO EL ID DE RAZA Y TAMAÑO) DE LOS ANIMALES SIN ADOPTAR ✅
SELECT nombre_mascota AS "Nombre",Raza_animal.nombre_raza AS "Raza",tamano_animal.tamano FROM Registro_animal 
INNER JOIN 
Raza_animal ON Registro_animal.ID_Raza_animal = Raza_animal.ID_Raza_animal
INNER JOIN 
tamano_animal ON tamano_animal.ID_tamano = Registro_animal.ID_tamano WHERE estado = 1;

#4. MUESTRA EL TOTAL DE ANIMALES SIN ADOPTAR ✅
SELECT COUNT(*) AS "TOTAL DE ANIMALES SIN ADOPTAR " FROM Registro_animal WHERE estado = 1;

#5. MUESTRA EL TOTAL DE ANIMALES ADOPTADOS ✅
SELECT COUNT(*) AS "TOTAL DE ANIMALES ADOPTADOS" FROM Registro_animal WHERE estado = 2;

#6. MUESTRA LOS ANIMALES CON FECHA DE ADMISIÓN DEL 2015 ✅
SELECT * FROM Registro_animal WHERE fecha_admission LIKE "%2015%";

#7. MUESTRA SIN REPETIR EL NOMBRE DE LA RAZA DE LOS ANIMALES REGISTRADOS ORDENADOS ALFABÉTICAMENTE ✅
SELECT Raza_animal.nombre_raza AS "Raza" FROM Registro_animal 
INNER JOIN 
Raza_animal ON Registro_animal.ID_Raza_animal = Raza_animal.ID_Raza_animal GROUP BY Raza ORDER BY Raza;

#8. MUESTRA EL NOMBRE DEL ANIMAL, TIPO, RAZA, TAMAÑO, EDAD Y EL ESTADO (MOSTRAR “ADOPTADO” O “SIN ADOPTAR”) DE LOS ANIMALES REGISTRADOS, ORDENADOS DE MENOR A MAYOR EDAD ✅
SELECT nombre_mascota AS "Nombre", Tipo_animal.tipo AS "Tipo", Raza_animal.nombre_raza AS "Raza", edad, FUNC_estado(nombre_mascota) AS "Estado" FROM Registro_animal
INNER JOIN Tipo_animal ON Tipo_animal.ID_tipo_animal = Registro_animal.ID_tipo_animal
INNER JOIN Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal ORDER BY edad DESC;

#9.HACER UNA VISTA EN DONDE MUESTRA LA INFORMACIÓN DE LOS ANIMALES ADOPTADOS:✅
#NOMBRE COMPLETO DE LA PERSONA QUE ADOPTO (EN UNA SOLA COLUMNA), NOMBRE DE LA MASCOTA, EDAD, RAZA FECHA DE ADMISIÓN Y FECHA DE ADOPCIÓN.✅
SELECT CONCAT(Registro_persona.nombre," ",Registro_persona.primer_appellido," ",coalesce(Registro_persona.segundo_apellido,"")) AS "Nombre Completo",
nombre_mascota AS "Nombre de Mascota", edad, Raza_animal.nombre_raza AS "Raza",fecha_admission AS "Fecha de Admission",
Registro_adopcion.fecha_adopcion AS "Fecha de Adopcion" FROM Registro_animal
INNER JOIN
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal
INNER JOIN 
Registro_adopcion ON Registro_adopcion.ID_registro_animal = Registro_animal.ID_registro_animal
INNER JOIN
Registro_persona ON Registro_persona.ID_persona = Registro_adopcion.ID_persona; 


#10. MUESTRA DE NOMBRE DE LA RAZA Y DE CADA UNA CUÁNTOS ANIMALES HAY REGISTRADOS. ✅
SELECT Raza_animal.nombre_raza AS "Raza", COUNT(*) AS "Total Registrados"FROM Registro_animal 
INNER JOIN 
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal GROUP BY nombre_raza;

#11. MUESTRA EL NOMBRE DEL TIPO DE ANIMAL Y CUANTOS HAY DE ESE TIPO ✅
SELECT Tipo_animal.tipo, COUNT(*) AS "Total" FROM Registro_animal 
INNER JOIN 
Tipo_animal ON Tipo_animal.ID_tipo_animal = Registro_animal.ID_tipo_animal GROUP By tipo; 

#12. MUESTRA EL TAMAÑO DE ANIMAL Y CUANTOS HAY DE ESE TAMAÑO✅
SELECT Tamano_animal.tamano AS "Tamano", COUNT(*) AS "Total" FROM Registro_animal 
INNER JOIN 
Tamano_animal ON Tamano_animal.ID_tamano = Registro_animal.ID_tamano GROUP BY Tamano;

#13. MUESTRA LOS ANIMALES REGISTRADOS QUE CONTENGAN EN SU NOMBRE “IC” O QUE TERMINEN CON “O”✅
SELECT nombre_mascota AS "nombre",Tipo_animal.tipo ,Raza_animal.nombre_raza AS "Raza", Tamano_animal.tamano, color, fecha_admission AS "Fecha Admission", FUNC_estado(nombre_mascota) AS "Estado" FROM Registro_animal 
INNER JOIN
Tipo_animal ON Tipo_animal.ID_tipo_animal = Registro_animal.ID_tipo_animal
INNER JOIN 
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal
INNER JOIN 
Tamano_animal ON Tamano_animal.ID_tamano= Registro_animal.ID_tamano WHERE Registro_animal.nombre_mascota LIKE "%IC%" OR Registro_animal.nombre_mascota LIKE "%O";

#14. MUESTRA EL NOMBRE DE LOS ANIMALES Y NOMBRE DE RAZA DE LOS QUE SEAN SOLO DEL TIPO “PERRO”✅
SELECT nombre_mascota, Raza_animal.nombre_raza AS "RAZA" FROM Registro_animal 
INNER JOIN 
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal
INNER JOIN Tipo_animal ON Tipo_animal.ID_tipo_animal = Registro_animal.ID_tipo_animal WHERE tipo = "PERRO";

#15. MUESTRA LA INFORMACIÓN DE LAS PERSONAS QUE ADOPTARON: NOMBRE COMPLETO DE LA PERSONA QUE ADOPTO (EN UNA SOLA COLUMNA), TELEFONO, CORREO, DIRECCION Y CUANTAS VECES A ADOPTADO. ✅
SELECT CONCAT(nombre," ",primer_appellido," ",coalesce(segundo_apellido,"")) AS "Nombre Completo", telefono, direcion, correo, COUNT(*) AS "Adoptaciones" FROM Registro_persona 
INNER JOIN Registro_adopcion ON Registro_adopcion.ID_persona = Registro_persona.ID_persona GROUP BY Registro_persona.ID_persona;


#16. MUESTRA LA INFORMACIÓN DE LOS ANIMALES REGISTRADOS ENTRE OCTUBRE 2015 Y FEBRERO 2016✅
SELECT nombre_mascota AS "nombre",Tipo_animal.tipo ,Raza_animal.nombre_raza AS "Raza", Tamano_animal.tamano, color, fecha_admission AS "Fecha Admission", FUNC_estado(nombre_mascota) AS "Estado" FROM Registro_animal 
INNER JOIN 
Tipo_animal ON Tipo_animal.ID_tipo_animal = Registro_animal.ID_tipo_animal
INNER JOIN 
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal
INNER JOIN 
Tamano_animal ON Tamano_animal.ID_tamano= Registro_animal.ID_tamano WHERE fecha_admission >= "2015-10-01" AND fecha_admission < "2016=03-01";

#17. MUESTRA CUÁNTOS ANIMALES SE REGISTRARON POR AÑO✅ 
SELECT COUNT(*) AS "Animales", YEAR(fecha_admission) AS "AÑO DE REGISTRO" FROM Registro_animal GROUP BY YEAR(fecha_admission);

#18. MUESTRA EL NOMBRE, RAZA, COLOR Y EDAD DE LOS ANIMALES REGISTRADOS QUE TENGAN ID 2, 4,5,8,9,11,13, SIN COMPLICAR LA SENTENCIA.✅ 
SELECT nombre_mascota AS "nombre",Raza_animal.nombre_raza AS "Raza", color  FROM Registro_animal 
INNER JOIN 
Raza_animal ON Raza_animal.ID_Raza_animal = Registro_animal.ID_Raza_animal WHERE ID_registro_animal IN (2,4,5,8,9,11,13);
