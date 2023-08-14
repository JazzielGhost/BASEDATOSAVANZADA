#REPASO
-- Creado por Jazziel Briones IDS T.V 6to
/*
Creacion de tablas
restricciones: podemos asignarle algun nombre a nivel tabla
nivel tabla: declarando otro campo
nivel columna: campo, tipo de dato luego la restriccion
ejemplos de nivel de tabla---
-primary key
-foreign key
-unique
-default
-check
ejemplo de nivel columna--
-not null
-default
*/

drop database talleres;
create database TALLERES;
use TALLERES;
create table taller(
	id_taller int auto_increment,
    nombre_taller varchar(100),
    descripcion varchar(100) default "sin descripcion",
    sede varchar(50),
    constraint pk_taller primary key(id_taller),
    constraint Unq_nombre_sede unique(nombre_taller,sede),
	constraint Chk_sede check(sede in("Los cabos", "La paz","El valle"))
	);

create table alumno(
	id_alumno int auto_increment,
    no_control varchar(10),
    nombre_alumno varchar(50) not null,
    primer_ap varchar(50) not null,
    segundo_ap varchar(50),
    taller int,
    constraint Pk_alumno primary key(id_alumno),
    constraint Fk_taller_alumno foreign key(taller)
    references taller(id_taller)    
);

alter table alumno auto_increment = 100;
#crear procedure
delimiter //
 create procedure alta_taller
 (in nombre varchar(100),in descripcion varchar(100),
 in sede varchar(50))
 begin
	if descripcion is null or descripcion = ""then 
		insert into taller(nombre_taller,sede)values(nombre,sede);
	else
		insert into taller(nombre_taller,descripcion,sede)values(nombre,descripcion,sede);
    end if;
 end //
delimiter ;

call alta_taller("pintura","taller de pintura","La paz");
call alta_taller("Danza","","La paz");
call alta_taller("Musica",null,"La paz");
call alta_taller("Danza","","Los cabos");

select * from taller;
select year(now());
select month(now());
select LPAD(month(now()),2,0);
select LPAD('CAT',21,'MEOW');
select last_insert_id() from information_schema.tables where table_name="alumno";
    select id_taller  from taller where nombre_taller = "pintura" and sede = "La paz";

select * from taller ;
/*20230317100*/
DELIMITER $$
 CREATE PROCEDURE ALTA_ALUMNO 
 (
	 NOMB_P VARCHAR(50),
	 PRIMER_AP_P VARCHAR(50),
	 SEGUNDO_AP_P VARCHAR(50),
	 TALLER_P VARCHAR(50),
	 SEDE_P VARCHAR(50)
 )
 BEGIN
	DECLARE ID_TALLER_AUX INT;
    DECLARE MONTH_AUX CHAR(2);
    DECLARE ID_ALUMNO_AUX CHAR(4);
    DECLARE NO_CONTROL_AUX VARCHAR(10);
    
    SELECT id_taller  INTO ID_TALLER_AUX FROM taller
    WHERE nombre_taller = TALLER_P AND sede = SEDE_P;
    
    IF ID_TALLER_AUX IS NULL THEN
		signal sqlstate '20001'
		set message_text = "NO EXISTE EL TALLER";
    else
		INSERT INTO alumno (nombre_alumno, primer_ap, segundo_ap, taller)
		VALUES (NOMB_P, PRIMER_AP_P, SEGUNDO_AP_P, ID_TALLER_AUX);
    END IF;
    
    SELECT LPAD(last_insert_id(),4,0) INTO ID_ALUMNO_AUX
    FROM INFORMATION_SCHEMA.TABLES WHERE 
	TABLE_NAME = 'ALUMNO'; /*0100*/
    
    SELECT LPAD((MONTH(NOW())),2,0) INTO MONTH_AUX;
    
    SET NO_CONTROL_AUX = CONCAT(YEAR(NOW()), MONTH_AUX,ID_ALUMNO_AUX);
    
    UPDATE alumno SET no_control = NO_CONTROL_AUX WHERE
    id_alumno = LAST_INSERT_ID();
    
    END;
    $$
    
delimiter ;

-- drop procedure alta_alumno;
select * from taller;
call alta_alumno('Jazziel','Briones','Herrera','pintura','La paz');
call alta_alumno('Alexis','Galvez','Gil','Musica','La paz');
select * from alumno;

DELIMITER $$
CREATE PROCEDURE CAMBIO_TALLER ( NO_CONTROL_P VARCHAR(10),
 TALLER_P VARCHAR(50), SEDE_P VARCHAR(50))
 BEGIN

		DECLARE ID_TALLER_AUX INT;
        DECLARE ID_ALUMNO_AUX INT;
        DECLARE CONT_ALUMNO INT;
        
		SET SQL_SAFE_UPDATES = 0;
        
        SELECT id_taller  INTO ID_TALLER_AUX FROM taller
		WHERE nombre_taller = TALLER_P AND SEDE = SEDE_P;
        
        SELECT id_alumno INTO ID_ALUMNO_AUX FROM alumno 
        WHERE no_control = NO_CONTROL_P;
        
        SELECT COUNT(*) INTO CONT_ALUMNO FROM alumno 
        WHERE no_control = NO_CONTROL_P;
        
        IF ID_TALLER_AUX IS NOT NULL AND CONT_ALUMNO > 0
        THEN
        UPDATE ALUMNO SET TALLER = ID_TALLER_AUX 
        WHERE NO_CONTROL = NO_CONTROL_P;
        END IF;
        
        IF ID_TALLER_AUX IS NULL THEN
        	signal sqlstate '20002'
		set message_text = "NO EXISTE EL TALLER CON ESOS DATOS";
        END IF;
        
        IF CONT_ALUMNO = 0 THEN
        signal sqlstate '20003'
		set message_text = "NO HAY ALUMNO CON ESE NO_CONTROL";
        END IF;
        
        SET SQL_SAFE_UPDATES = 1;
 END;
 $$
 DELIMITER ;
SELECT * FROM ALUMNO;
SELECT * FROM TALLER;
-- drop procedure CAMBIO_TALLER;
CALL CAMBIO_TALLER ('2023030100', 'Danza', 'La paz');
CALL CAMBIO_TALLER ('2023030101', 'Danza', 'La paz'); /*DE TALLER*/
-- CALL CAMBIO_TALLER ('2023030101', 'pintura', 'La paz'); /*DE NO_CONTROL*/

delimiter %%
create procedure baja_taller(in no_control_p varchar(10))
begin
	declare CONT_ALUMNO INT;
    declare ID_ALUMNO_AUX INT;
    		SET SQL_SAFE_UPDATES = 0;
    select count(*) into CONT_ALUMNO from alumno
    where no_control = no_control_p; 
    
    if CONT_ALUMNO > 0 THEN
		UPDATE alumno set taller = null 
        where no_control = no_control_p;
    else
		signal sqlstate '20003'
		set message_text = "NO HAY ALUMNO CON ESE NO_CONTROL";
     end if;

end %%
delimiter ; 
-- drop procedure baja_taller;
 select * from alumno;
call baja_taller("2023030101");


/*Truncate alumno;
delete from alumno;
delete from alumno where id_alumno > 0;
alter table alumno auto_increment = 100;
*/
delimiter %%
create function obtener_taller(no_control_p varchar(10))
returns varchar(150)
READS SQL DATA
begin
	declare id_taller_aux int;
    declare nombre_aux varchar(50);
    declare sede_aux varchar(50);
    declare mensaje_aux varchar(150);
    
    select taller into id_taller_aux from alumno
    where no_control = no_control_p;
    
    select nombre_taller, sede into nombre_aux, sede_aux from taller 
    where id_taller = id_taller_aux;
    
    set mensaje_aux = concat(nombre_aux, ", SEDE: ", sede_aux);
    
    return mensaje_aux;
end %%
delimiter ;
-- drop function obtener_Taller;
-- select * from alumno;
select nombre_alumno, obtener_taller(no_control) as "Descripcion taller" from alumno;

delimiter $$
create function total_alumnos(id_taller_p int)
returns int
reads sql data
begin
	declare total int;
    select count(*) into total from alumno
    where taller = id_taller_p group by taller;
    if total is null then
		set total =0;
	end if;
    return total;
end $$
delimiter ;

-- drop function total_alumnos;

select nombre_taller,sede,total_alumnos(id_taller) as "Total alumnos" from taller;
/*vista simple*/

select * from taller;

create view  taller_la_paz_bcs as
select nombre_taller,sede from taller where sede = "La paz"
with check option;

-- drop view taller_la_paz_bcs;

insert into taller_la_paz_bcs values ("Ajedrez", "Los cabos");
select * from taller_la_paz_bcs;


/*vista compleja*/
create view datos_alumno as
select alumno.no_control,alumno.nombre_alumno,taller.nombre_taller,taller.sede
from alumno join taller on alumno.taller = taller.id_taller;

select * from datos_alumno;
create table historial_alumno(
	id_historial int auto_increment,
    constraint pk_id_historial primary key(id_historial),
    id_alumno int,
    constraint fk_id_alumno foreign key(id_alumno) references alumno(id_alumno),
    id_taller int,
    constraint fk_id_taller foreign key(id_taller) references taller(id_taller), 
    fecha date,
    tipo_movimiento varchar(200)
);

delimiter %%
create trigger tr_nuevo_alumno
after insert on alumno
for each row
begin
	declare nombre_taller_aux varchar(100);
    declare sede_taller_aux varchar(100);
    
    select nombre_taller,sede into nombre_taller_aux,sede_taller_aux
    from taller where id_taller = new.taller;
    
	insert into historial_alumno(id_alumno, id_taller, fecha, tipo_movimiento)
    values(new.id_alumno,new.taller,now(),concat("se agrego nuevo alumno con nombre:",new.nombre_alumno," en taller:",
    nombre_taller_aux," sede:",sede_taller_aux));


end %%
delimiter ;
drop trigger tr_nuevo_alumno;
call alta_alumno('Martin','Castro','Castro','Musica','La paz');
select *  from historial_alumno;
/* el sigueinte trigger se activa con un after update pero hay que
   validar cuando se cambia de taller o cunado se da de baja de taller*/

delimiter %%
CREATE TRIGGER tr_act_baja
AFTER UPDATE ON alumno
FOR EACH ROW
BEGIN
    DECLARE tr_old_taller_aux VARCHAR(100);
    DECLARE tr_nombre_taller_aux VARCHAR(100);
    DECLARE tr_sede_aux VARCHAR(100);
    SELECT nombre_taller INTO tr_old_taller_aux FROM taller WHERE taller.id_taller = OLD.taller;
    SELECT sede, nombre_taller INTO tr_sede_aux, tr_nombre_taller_aux FROM taller WHERE id_taller = NEW.taller;
    IF OLD.taller <> NEW.taller THEN
        INSERT INTO historial_alumno(id_alumno, id_taller, fecha, tipo_movimiento)
		VALUES(NEW.id_alumno, NEW.taller, NOW(),
        -- ALUMNO CON NOMBRE: XXX SE CAMBIO DEL TALLER XXX AL TALLER XXX EN SEDE XX.
		CONCAT('alumno con nombre:',NEW.nombre_alumno,' se cambio del taller:', tr_old_taller_aux,' al taller:',tr_nombre_taller_aux,' en sede:',tr_sede_aux,'.'));
    END IF;
    IF NEW.taller IS NULL THEN
        INSERT INTO historial_alumno(id_alumno, id_taller, fecha, tipo_movimiento)
		VALUES(NEW.id_alumno, NEW.taller, NOW(),
		-- ALUMNO CON NOMBRE XXX SE DIO DE BAJA DEL TALLER XXX
		CONCAT('alumno con nombre:', NEW.nombre_alumno ,' se dio de baja del taller:', tr_old_taller_aux ,'.'));
    END IF;
    IF OLD.taller IS NULL THEN
        INSERT INTO historial_alumno(id_alumno, id_taller, fecha, tipo_movimiento)
		VALUES(NEW.id_alumno,NEW.taller,NOW(),
		/*ALUMNO CON NOMBRE XXXX REINGRESO AL TALLER XXX (ESTO SUCEDE CUANDO ALGUIEN QUE ESTABA DADO DE BAJA
        (TALLER = NULL) VUELVE A DARSE DE ALTA.. ES DECIR SE CAMBIA DE TALLER*/ 
        CONCAT('alumno con nombre:', NEW.nombre_alumno ,' reingreso al taller:', tr_nombre_taller_aux));
    END IF;
END%%
delimiter ;



drop trigger tr_act_baja;
select * from taller;
select * from alumno;
select * from historial_alumno;












