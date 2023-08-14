CREATE DATABASE CONSULTORIO;
USE CONSULTORIO;
-- drop database CONSULTORIO;

CREATE TABLE DENTISTA (
ID_DENTISTA INT AUTO_INCREMENT,
NOMBRE_COMPLETO VARCHAR(45),
CEDULA VARCHAR(45),
CONSTRAINT PK_DENTISTA PRIMARY KEY (ID_DENTISTA),
CONSTRAINT UNQ_CEDULA UNIQUE (CEDULA)
);

CREATE TABLE ESPECIALIDAD (
ID_ESPECIALIDAD INT AUTO_INCREMENT,
NOMBRE VARCHAR(45),
CONSTRAINT PK_ESPECIALIDAD PRIMARY KEY (ID_ESPECIALIDAD),
CONSTRAINT UNQ_ESPECIALIDAD UNIQUE (NOMBRE)
);

CREATE TABLE DENTISTA_ESPECIALIDAD (
ID_D_E INT AUTO_INCREMENT,
ID_DENTISTA INT,
ID_ESPECIALIDAD INT,
CONSTRAINT PK_D_E PRIMARY KEY (ID_D_E),
CONSTRAINT FK_DENTISTA_ESPEC FOREIGN KEY (ID_DENTISTA) REFERENCES DENTISTA (ID_DENTISTA),
CONSTRAINT FK_ESPECIALIDAD_DEN FOREIGN KEY (ID_ESPECIALIDAD) REFERENCES ESPECIALIDAD (ID_ESPECIALIDAD)

);

select *from DENTISTA;

CREATE TABLE SERVICIO (
ID_SERVICIO INT AUTO_INCREMENT,
DESCRIPCION   VARCHAR (55),
PRECIO FLOAT,
CONSTRAINT PK_SERVICIO PRIMARY KEY (ID_SERVICIO),
CONSTRAINT CHK_PRECIO_POSITIVO CHECK (PRECIO > 0)
);

select *from SERVICIO;

CREATE TABLE PACIENTE (
ID_PACIENTE INT AUTO_INCREMENT,
NOMBRE VARCHAR (45),
PRIMER_AP VARCHAR (45),
SEGUNDO_AP VARCHAR (45),
TELEFONO VARCHAR(10), 
EMAIL VARCHAR (30),
VISITAS  INT DEFAULT 0,
CONSTRAINT PK_PACIENTE PRIMARY KEY (ID_PACIENTE)
);

select *from SERVICIO;

CREATE TABLE CITA (
ID_CITA INT AUTO_INCREMENT,
FECHA   DATE,
HORA   TIME,
PACIENTE  INT,
DENTISTA INT,
SERVICIO INT,
ESTATUS INT DEFAULT 1, /*1: VIGENTE - 2: CANCELADA - 3: FINALIZADA*/
CONSTRAINT PK_CITA PRIMARY KEY (ID_CITA),
CONSTRAINT FK_PACIENTE FOREIGN KEY (PACIENTE) REFERENCES PACIENTE(ID_PACIENTE),
CONSTRAINT FK_DENTISTA FOREIGN KEY (DENTISTA) REFERENCES DENTISTA(ID_DENTISTA),
CONSTRAINT FK_SERVICIO FOREIGN KEY (SERVICIO) REFERENCES SERVICIO(ID_SERVICIO),
CONSTRAINT CHK_ESTATUS CHECK (ESTATUS IN (1, 2, 3))
);

select * from CITA;


/*Inserta los datos con ayuda del documento PDF llamado "Consultorio_datos"  */
/*Crea un PROCEDIMIENTO ALMACENADO para agregar los DENTISTAS*/
select * from dentista;
delimiter %%
create procedure ALTA_DENTISTA(in nombre_completo_p varchar(45), in cedula_p varchar(45))
begin
	insert into DENTISTA(nombre_completo,cedula) VALUE(nombre_completo_p,cedula_p);
end %%
delimiter ;
call ALTA_DENTISTA("Aida Sánchez Ortiz","6095471");
call ALTA_DENTISTA("Enrique Gonzalez Tuchmann","0551606");
call ALTA_DENTISTA("Christopher Alexis Torres Arce","9404774");
/*Añade los datos a la tabla especialidades- ya sea con INSERT o con PROCEDURE*/
insert into especialidad(nombre) value("Ortodoncia");
insert into especialidad(nombre) value("Odontología Preventiva");
insert into especialidad(nombre) value("Odontopediatría");
insert into especialidad(nombre) value("Endodoncia");
insert into especialidad(nombre) value("Odontología Estética");
insert into especialidad(nombre) value("Cirugía Oral");

select * from especialidad;
/*Añade los datos a la tabla DENTISTA_ESPECIALIDAD - ya sea con INSERT o con PROCEDURE */
insert into DENTISTA_ESPECIALIDAD(id_dentista,id_especialidad) value(1,1),(1,2),(1,3),(1,4),
																	(2,1),(2,5),
                                                                    (3,1),(3,4),(3,6);
select * from dentista_especialidad;

/*Añade los datos a la tabla SERVICIOS - ya sea con INSERT o con PROCEDURE*/
insert into servicio(descripcion,precio) value("Limpieza dental",900);
insert into servicio(descripcion,precio) value("Extracciones",3300);
insert into servicio(descripcion,precio) value("Implantes Dentales",11500);
insert into servicio(descripcion,precio) value("Resina dental",1000);
insert into servicio(descripcion,precio) value("Endodoncia",4500);
insert into servicio(descripcion,precio) value("Brackets Tradicionales",8820);

select * from servicio;
/*Crea un PROCEDIMIENTO ALMACENADO para agregar los PACIENTES*/
/* ---- Con el procedimiento almacenado agrega 3 pacientes.*/
SELECT * FROM PACIENTE;
delimiter %%
create procedure ALTA_PACIENTE(in nombre_p varchar(45), in primer_ap_p varchar(45),in segundo_ap_p varchar(45),
in telefono_p varchar(10),in email_p varchar(30))
begin
	insert into PACIENTE(nombre,primer_ap,segundo_ap,telefono,email) VALUE(nombre_p,primer_ap_p,telefono_p,segundo_ap_p,email_p);
end %%
delimiter ;
call ALTA_PACIENTE("Jazziel","Briones","Herrera","6122215617","Jazzielbh@gmail.com");
call ALTA_PACIENTE("Jose","Trinidad","Venteño","6122365168","Jose@gmail.com");
call ALTA_PACIENTE("Martin","Castro","Castro","612225587","Martin@gmail.com");
 -- drop procedure ALTA_PACIENTE;
/*Crea un PROCEDIMIENTO ALMACENADO para agregar las CITAS */
/* ---- Con el procedimiento agrega 4 citas*/
# falta de probar
delimiter %%
create procedure ALTA_CITA(in fecha_p date, in hora_p time, in paciente_p int,in dentista_p int,in servicio_P int)
begin
	insert into CITA(fecha,hora,paciente,dentista,servicio) values(fecha_p,hora_p,paciente_p,dentista_p,servicio_p);
end %%
delimiter ;
call ALTA_CITA("2023-05-01","10:00:00",1,1,1);
call ALTA_CITA("2023-07-01","15:00:00",1,2,2);
call ALTA_CITA("2023-06-08","11:00:00",2,1,1);
call ALTA_CITA("2023-07-05","13:00:00",3,1,1);
 -- drop procedure alta_cita;
SELECT * FROM CITA;
SELECT * FROM paciente;
SELECT * FROM dentista;
SELECT * FROM servicio;
/* Ejemplos de formatos: Fecha "2021-01-30"  Hora "10:00:00"*/

/*Crea una función NUMERO_CITAS para obtener el total de citas que ha tenido el dentista
mandando su id como parámetro. */
#falta de terminar
delimiter %%
create function FU_ESTATUS_CITA(id_cita int) 
returns int
READS SQL DATA
begin
	declare numero_citas_aux int;
    select count(*) paciente into numero_citas_aux from cita where paciente = id_cita;
    return numero_citas_aux;
    
end %%
delimiter ;
select FU_ESTATUS_CITA(1) as "PACIENTE TIENE:";
/*Crea un PROCEDIMIENTO ALMACENADO llamado "CANCELA_CITA" donde recibiendo de parametro el id de la cita,
el estatus cambie a  2 = Cancelado*/
#falta de terminar
delimiter %%
create procedure BAJA_CANCELAR_CITA(in id_cita_pr int)
begin
	update cita set estatus = 2 where id_cita = id_cita_pr;
end %%
delimiter ;
drop procedure BAJA_CANCELAR_CITA;
/*Crea un PROCEDIMIENTO ALMACENADO llamado "FINALIZA_CITA" donde recibiendo de parametro el id de la cita,
el estatus cambie a  3 = Finalizada, donde se valide que la fecha de la cita sea igual a la fecha actual*/
#falta de finalizar
delimiter %%
create procedure BAJA_FINALIZAR_CITA(in id_cita_pr int)
begin
	update cita set estatus = 3 where id_cita = id_cita_pr;
end ;%%
delimiter ;
 -- drop procedure BAJA_FINALIZAR_CITA;

/*Crea una funcion "ESTATUS_CITA" que devuelva el significado del estatus de la cita
si es 1 = Vigente , 2 =  Cancelada , 3 = Finalizada*/
#falta de probar
delimiter %%
create function FU_ESTATUS_CITA(id_cita_fu int) 
returns varchar(150)
READS SQL DATA
begin
	declare estatus_aux int;
    select estatus into estatus_aux from cita where id_cita = id_cita_fu;
    if estatus_aux = 1 then
		return "Vigente";
        end if;
	if estatus_aux = 2 then
		return "Cancelada";
        end if;
    if estatus_aux = 3 then
		return "Finalizada";
        end if;
end %%
delimiter ;
select fu_estatus_cita(1);
drop function FU_ESTATUS_CITA;
/*Crea una función que devuelva el mensaje “Precio Elevado” si el precio es mayor de 5000
y que devuelva el mensaje “Precio regular” si el precio es menor  */
#falta de probar
delimiter %%
create function FU_ESTATUS_PRECIO(id_servicio_fu int) 
returns varchar(150)
READS SQL DATA
begin
	declare precio_aux int;
    select precio into precio_aux from servicio where id_servicio = id_servicio_fu;
    if precio_aux > 5000 then
		return "precio elevado";
	else
		return "precio regular";
    end if;
	
end %%
delimiter ;
select FU_ESTATUS_PRECIO(1) as "El precio es:";
-- drop function FU_ESTATUS_PRECIO;
/*Crea un trigger que cuando se finalice una cita le actualice +1 a el campo visitas del
paciente.
Como el paciente ya tenia citas antes de hacer este trigger, el trigger debe de calcular
cuantas citas tenia hasta entonces finalizadas y sumarle +1 y actualizar el valor visitas. */
delimiter $$
CREATE TRIGGER TR_ACTUALIZAR_VISITAS
after update ON cita
FOR EACH ROW
BEGIN
	
    
END $$
delimiter ;
/*Obtener una vista en donde obtengamos los datos de los pacientes: nombre completo,
correo electrónico, el total de citas que ha tenido y la suma del total que ha gastado en
todas sus citas.*/

/*Crea una vista en donde obtengamos la información de las citas poniendo el nombre
completo del paciente en una sola columna, su correo, la fecha de la cita, hora de la cita, estatus de la cita,  la
descripción del servicio, el precio del servicio y  el estatus_precio */

/*Crea una vista donde muestres la informacion de los dentistas y cuantas especialidades tienen. */