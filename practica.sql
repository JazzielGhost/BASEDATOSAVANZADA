create database CONSTANZO;
-- Jazziel Abdiel Briones Herrera
use CONSTANZO;
-- drop database CONSTANZO;
create table estado(
	idEstado int auto_increment,
    constraint PK_estado_id primary key(idEstado),
    nombreEstado varchar(50) unique	
)ENGINE=INNODB;

create table franquicias(
	idFranquicia int auto_increment,
	constraint PK_franquicia_id primary key(idFranquicia),
    nombre varchar(50) not null unique, 
    idESTADO int not null,
	CONSTRAINT FK_idESTADO FOREIGN KEY(idESTADO) REFERENCES estado(idEstado),
	direccion varchar(500) not null unique,
    telefono varchar(10)
)ENGINE=INNODB;

create table categorias(
	idCategoria int auto_increment,
    constraint PK_categoria_id primary key(idCategoria),
    nombre varchar(100) check(nombre = "Caramelos" or nombre = "Chocolates envueltos" or nombre = "Varios" or 
    nombre = "Chiclosos, jaleas y gomitas" or nombre = "Piezas, tablillas y bolsas" or nombre = "Chocolates sin envolver")
)ENGINE=INNODB;

create table productos(
	idProducto int auto_increment,
    constraint PK_producto_id primary key(idProducto),
    nombre varchar(100) not null, 
    descripcion varchar(15) default "Sin descripcion",
	idCATEGORIA int not null,
    constraint FK_idCATEGORIA foreign key(idCATEGORIA) references categorias(idCategoria),
    precio int not null,
    CONSTRAINT CK_precio CHECK (precio > 0),
	stock int not null,
    CONSTRAINT CK_stock CHECK (stock > 0)
)ENGINE=INNODB;

create table historial_suministro(
	idSuministro int auto_increment,
    constraint PK_suministro_id primary key(idSuministro),
    idFRANQUICIA int not null,
    constraint FK_idFRANQUICIA foreign key(idFRANQUICIA) references franquicias(idFranquicia),
	idPRODUCTO int not null,
    constraint FK_idPRODUCTO foreign key(idPRODUCTO) references productos(idProducto),
    cantidad int not null,
    constraint CK_cantidad check (cantidad >= 1),
    fecha datetime 
)ENGINE=INNODB;
-- delete from historial_suministro where idSuministro =2;
-- Sin terminar
delimiter &&
create procedure tienda_dulces(nombreEstado,nombre,idESTADO,direccion,telefono,idCATEGORIA,precio,stock,idFRANQUICIA,idPRODUCTO,cantidad,fecha)
begin

INSERT INTO estado (nombreEstado) VALUE("Aguascalientes");
INSERT INTO franquicias (nombre,idESTADO,direccion,telefono) VALUE("Galerías",1,"Av. Independencia No. 2351, Col. Trojes de Oriente Referencia; Centro Comercial Galerías Loc. 48 - B C.P. 20115, Aguascalientes, Aguascalientes.", 6122215617);
insert into categorias (nombre) value("Caramelos");
insert into productos (nombre,idCATEGORIA,precio,stock) value("Barril",1,200,3);
insert into historial_suministro(idFRANQUICIA,idPRODUCTO,cantidad,fecha) value(2,1,300,now());

end &&
delimiter ;
-- sin terminar
call tienda_dulces();
select * from historial_suministro;
select * from productos;
select * from categorias;
select * from estado;
select * from franquicias;
