#JAZZIEL ABDIEL BRIONES HERRERA

#CREACION DE TABLA ---PASO 1
create database MUSICA;
use MUSICA;
 -- drop database MUSICA;
#CREACION DE TABLA DISQUERA ---PASO 2
-- describe DISQUERA;
create table DISQUERA(
	id_disquera int auto_increment,
    constraint pk_id_disquera primary key (id_disquera),
	nombre varchar(50) not null,
    sede varchar(20) default "DESCONOCIDO"
);
show tables;
-- show create table disquera;
-- delete from disquera where id_disquera =0;
insert into DISQUERA(nombre,sede) values("Motown", "Nueva York");
insert into DISQUERA(nombre,sede) values("SONY", "Minato, Tokio, Japón");
insert into DISQUERA(nombre,sede) values("EMI", "Londres inglaterra");
insert into DISQUERA(nombre,sede) values("UNIVERSAL", "Paris");
select * from DISQUERA;

#CREACION DE TABLA GENERO ---PASO 3
-- describe GENERO;
create table GENERO(
	id_genero int auto_increment,
    constraint pk_id_genero primary key (id_genero),
    nombre varchar(50),
    constraint genero01 unique (nombre)
);
insert into GENERO(nombre) value("pop");
insert into GENERO(nombre) value("REGUETON");
insert into GENERO(nombre) value("JAZZ");
insert into GENERO(nombre) value("CLASICA");
select * from GENERO;

-- SELECT * FROM GENERO ORDER BY id_genero;

#Eliminar columna GENERO ---PASO 4
alter table GENERO DROP CONSTRAINT genero01;

#COorregir --PASO 5
alter table GENERO
ADD CONSTRAINT Unq_nombre unique(nombre);

#CREACION DE TABLA IDIOMA --PASO 6
-- describe IDIOMA;
create table IDIOMA(
	id_idioma int auto_increment,
    constraint pk_id_idioma primary key(id_idioma),
    nombre varchar(50),
    constraint Unq_nombre unique(nombre)
);

insert into IDIOMA(nombre) value("INGLES");
insert into IDIOMA(nombre) value("ESPAÑOL");

#CREAR TABLA ARTISTA ---PASO 7
-- describe ARTISTA;
create table ARTISTA(
	id_artista int auto_increment,
    constraint pk_id_artista primary key(id_artista),
    nombre varchar(50) not null,
    nacionalidad varchar(50) default "DESCONOCIDA",
    fecha_nac date
);

 -- drop procedure agregarArtista;
 /*Se creará un procedimientos almacenado para agregar datos a la tabla
ARTISTA, donde se mandara solo nombre, nacionalidad si es que se
conoce, en caso contrario se mandará null y fecha de nacimiento. Al
menos unos 3 registros.
*/
delimiter $$
create procedure agregarArtista(in nom varchar(50),in nacion varchar(50),in fecha date)
begin
	if nacion is null then
		insert into ARTISTA(nombre,fecha_nac) values(nom,fecha);
	else
		insert into ARTISTA(nombre,nacionalidad,fecha_nac) values(nom,nacion,fecha);
	end if;
end $$
-- drop procedure agregarArtista;
delimiter ;
use MUSICA;
select * from ARTISTA;
-- delete from ARTISTA where id_artista = 1;
call agregarArtista("Michael Jackson", "EUU","1958-08-26");
call agregarArtista("BAD BUNNY", null,"1994-03-10");

#CREAR TABLA ALBUM ---PASO 8
-- describe ALBUM;
create table ALBUM(
	id_album int auto_increment,
    constraint pk_id_album primary key(id_album),
	nombre varchar(50) not null,
    fecha_publicacion date,
    id_disquera int,
    constraint fk_id_disquera foreign key(id_disquera) references DISQUERA(id_disquera),
    precio int,
    constraint Chk_precio check(precio > 0),
    id_artista int,
    constraint fk_id_artista foreign key(id_artista) references ARTISTA(id_artista)
);
/*Se creará un procedimientos almacenado para agregar datos a la tabla
ALBUM, donde se mandara solo nombre, fecha publicacion, id
disquera a la que pertenece, precio y id artista. Al menos unos 4
registros.*/
delimiter %%
create procedure añadirAlbum(in nom varchar(50),in fecha date,in id_disquera int,in precio int, in id_artista int, in en_exis int)
begin
	if precio < 0 then
		signal sqlstate'45000'
				SET MESSAGE_TEXT = 'El precio debe ser mayor que 0';
    else
		insert into ALBUM(nombre,fecha_publicacion,id_disquera,precio,id_artista,en_existencia) VALUES (nom,fecha,id_disquera,precio,id_artista,en_exis);
    end if;
end %%
delimiter ; 
-- drop procedure añadirAlbum;
use MUSICA;
call añadirAlbum("Thiller","1982-11-29",1,448,1,10);
call añadirAlbum("Beat it","2006-03-13",1,448,1,30);
call añadirAlbum("Bad","1987-08-31",1,144,1,50);
call añadirAlbum("Billie Jean","1982-02-02",1,69,1,20);
call añadirAlbum("Billie Jean","1982-02-02",1,69,1,40);
call añadirAlbum("TIBURON","2020-02-02",1,69,2,10);
call añadirAlbum("AMANECER","2021-02-02",1,209,2,30);
-- call añadirAlbum("Billie Jean","1982-02-02",1,-100,2);
SELECT * from ARTISTA;
SELECT * from ALBUM;
-- select * from DISQUERA;

#CREAR TABLA CANCION --PASO 9
 describe CANCION;
create table CANCION(
	id_cancion int auto_increment,
    constraint pk_id_cancion primary key (id_cancion),
    titulo varchar(50) not null,
    id_idioma int,
    constraint fk_id_idioma foreign key (id_idioma) references IDIOMA(id_idioma),
    id_genero int,
    constraint fk_id_genero foreign key (id_genero) references GENERO(id_genero),
	id_album int,
    constraint fk_id_album foreign key (id_album) references ALBUM(id_album)

);
-- delete from cancion ;
/* Se creará un procedimiento almacenado para agregar datos a la tabla CANCION
donde se mandara solo el titulo, id_idioma, el id_genero y el id_album Al menos
unos 10 registros.
*/
delimiter //
create procedure agregarCancion(in titulo varchar(50), in id_idioma int,in id_genero int,in id_album int)
begin
	#declare nombreExis varchar(50);
	#SELECT COUNT(*) INTO nombreExis FROM CANCION WHERE titulo = titulo;
    /*if length(nombreExis) <> length(titulo) then
		signal sqlstate'45000'
		SET MESSAGE_TEXT = 'El nombre tiene que ser diferente!!!';
	else
    end if;*/
	insert into CANCION(titulo,id_idioma,id_genero,id_album) values (titulo,id_idioma,id_genero,id_album);
end //
delimiter ;
use MUSICA;
-- drop procedure agregarCancion;
-- select * from CANCION order by id_cancion;
-- delete from CANCION where id_cancion = 7;
call agregarCancion("Billi jean",1,1,1);
call agregarCancion("Amanecer",2,2,7);
call agregarCancion("Heal the World",1,1,3);
call agregarCancion("Dirty diana",1,1,4);
call agregarCancion("Earth song",1,1,5);
call agregarCancion("Dangerous",1,1,3);
call agregarCancion("P.Y.T",1,1,2);
call agregarCancion("Human nature",1,1,3);
call agregarCancion("Jam",1,1,3);
call agregarCancion("Who is it",1,1,3);
call agregarCancion("Tiburon",2,2,6);
call agregarCancion("OJOS LINDOS",2,2,7);
select * from cancion;
select * from album;
select * from genero;
select * from idioma;


/*Se creará una función llamada CUANTOS_AÑOS en donde recibiendo una fecha
de parámetro devuelve la diferencia de años según la fecha actual.*/
delimiter //
CREATE FUNCTION CUANTOS_AÑOS(FECHA DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE AÑOS INT;
    SET AÑOS = YEAR(CURDATE()) - YEAR(FECHA);
    IF MONTH(CURDATE()) < MONTH(FECHA) OR 
       (MONTH(CURDATE()) = MONTH(FECHA) AND DAY(CURDATE()) < DAY(FECHA)) THEN
        SET AÑOS = AÑOS- 1;
    END IF;
    RETURN AÑOS;
END //
delimiter ;

drop procedure CUANTOS_AÑOS;

/* Se modificará la tabla ALBUM añadiendo una nueva columna llamada
EN_EXISTENCIA que nos servirá para saber sobre el stock de los CD y tendra por
DEFAULT 0 . ---PASO 10*/

alter table ALBUM add en_existencia int default 0;
#alter table ALBUM DROP en_existencia;

/*Se modificará la tabla ALBUM para añadir una restricción CHECK que limitará los
valores que puedan agregarse en la columna EN_EXISTENCIA, en donde cada
valor debe ser mayor o igual a 0, pero menos que 50. ---PASO 11*/

alter table ALBUM add CONSTRAINT en_existencia check(en_existencia between 0 and 50);
select * from ALBUM;

/*La siguiente tabla es CONTENIDO_ALBUM, contiene solo dos columnas en
donde tendremos dos claves foráneas y una clave primaria compuesta. Primero
se crearán la columna ID_ALBUM y la columna ID_CANCION, después
crearemos una restricción de clave primaria haciendo referencia a ID_ALBUM y
ID_CANCION. A continuación, crearemos una restricción de clave foránea con
ID_ALBUM haciendo referencia a la tabla ALBUM, y una restricción clave
foránea con ID_CANCION haciendo referencia a la tabla de CANCION,  ---PASO 12*/
-- describe CONTENIDO_ALBUM;
create table CONTENIDO_ALBUM(
	id_album int, 
    constraint fk_id_album2 foreign key (id_album) references ALBUM(id_album),
    id_cancion int,
    constraint fk_id_cancion foreign key(id_cancion) references CANCION(id_cancion),
    constraint pk_id_album_cancion primary key (id_album, id_cancion)
    
);

insert into CONTENIDO_ALBUM(id_album,id_cancion) values(1,1);
insert into CONTENIDO_ALBUM(id_album,id_cancion) values(2,2);
insert into CONTENIDO_ALBUM(id_album,id_cancion) values(3,3);
insert into CONTENIDO_ALBUM(id_album,id_cancion) values(4,5);
insert into CONTENIDO_ALBUM(id_album,id_cancion) values(5,6);
insert into CONTENIDO_ALBUM(id_album,id_cancion) values(7,8);

select * from album;
select * from cancion;
select * from CONTENIDO_ALBUM;

use musica;
/*. Muestra la información de todas las canciones mostrando el título, idioma, género,
nombre del álbum y el nombre del artista.
*/
CREATE VIEW INFO_CANCION as
SELECT CANCION.titulo AS CANCION, IDIOMA.nombre AS IDIOMA, GENERO.nombre AS GENERO, ALBUM.nombre AS ALBUM, ARTISTA.nombre AS ARTISTA 
FROM CANCION
JOIN album ON cancion.id_album = album.id_album
JOIN artista ON album.id_artista = artista.id_artista
JOIN idioma ON cancion.id_idioma = idioma.id_idioma
JOIN genero ON cancion.id_genero = genero.id_genero ;
/*Haz una vista con lo anterior la cual llamaremos INFO_CANCION*/
select * from INFO_CANCION;


/*Muestra el nombre del álbum, la fecha de publicación y la cantidad de canciones
que tiene.*/
select ALBUM.nombre as "NOMBRE", ALBUM.fecha_publicacion as "FECHA PUBLICADA", ALBUM.en_existencia as "EXISTENTE"
from ALBUM;

/*Muestra el nombre del artista y el total de álbumes que tiene*/
SELECT ARTISTA.NOMBRE AS 'NOMBRE DEL ARTISTA', COUNT(*) AS 'TOTAL DE ÁLBUMES'
FROM ARTISTA
JOIN ALBUM ON ARTISTA.ID_ARTISTA = ALBUM.ID_ARTISTA
GROUP BY ARTISTA.NOMBRE;

/* Muestra la información del álbum más caro.*/
SELECT id_album AS 'ID ALBUM', nombre AS 'NOMBRE', fecha_publicacion AS 'FECHA PUBLICACIÓN',
id_disquera AS 'ID DISQUERA', PRECIO AS 'PRECIO', id_artista AS 'ID ARTISTA', en_existencia AS 'EN EXISTENCIA'
FROM ALBUM
WHERE precio = (
  SELECT MAX(PRECIO)
  FROM ALBUM
);

/*Muestra los idiomas que hay y cuántas canciones hay de ese idioma.*/
select i.nombre as "IDIOMA",COUNT(c.id_cancion) AS 'NUMERO DE CANCIONES'
FROM IDIOMA i
LEFT JOIN CANCION c ON c.id_idioma = i.id_idioma
GROUP BY i.nombre; 
use MUSICA;
/*Muestra el género que hay y cuántas canciones hay de ese género.*/
SELECT g.nombre AS 'GENERO', COUNT(*) AS 'CANCIONES' 
FROM CANCION c 
JOIN GENERO g ON c.id_genero = g.id_genero
GROUP BY g.id_genero;

/*Muestra los artistas, su nacionalidad y cual es el promedio del precio del álbum de
cada artista.*/
SELECT a.nombre AS ARTISTA, a.nacionalidad, AVG(b.precio) AS PROMEDIO_PRECIO
FROM ARTISTA a 
JOIN ALBUM b ON a.id_artista = b.id_artista
GROUP BY a.nombre, a.nacionalidad;

/*Muestra los datos del artista, nombre, nacionalidad, fecha de nacimiento y calcula
la edad que tiene el artista hasta el día de hoy usando tu función creada en el
punto 7.*/
SELECT nombre, nacionalidad, fecha_nac AS 'FECHA NACIMIENTO', CUANTOS_AÑOS(fecha_nac)
AS 'EDAD ACTUAL' FROM ARTISTA;

/*Muestra la información de las disqueras y ordenalo según el nombre de su sede*/
SELECT id_disquera AS 'ID DISQUERA', nombre AS nombre, sede FROM DISQUERA ORDER BY sede;

select * from album;
select * from artista;
select * from cancion;
select * from contenido_album;
select * from disquera;
select * from genero;
select * from idioma;

show tables;
/*SELECT * 
    FROM CANCION a
    INNER JOIN album c
    ON a.id_album= c.id_cancion; 
*/
