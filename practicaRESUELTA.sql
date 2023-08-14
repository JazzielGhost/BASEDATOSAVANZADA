-- 1
create database CONSTANZO;
-- 2
create table estado(
	idEstado int auto_increment,
    constraint pk_estado primary key (idEstado),
    nombreEstado varchar(30),
    constraint Unq_nombreEstado unique (nombreEstado)
);
-- 3
create table franquicias(
	idFranquicia int auto_increment,
    constraint pk_franquicia primary key(idFranquicia),
    nombre varchar(30) not null,
    constraint Unq_nombreFranquicia unique(nombre),
	direccion varchar(60) not null,
    telefono varchar(20),
    idEstado int,
    constraint fk_estado_franquicia foreign key (idEstado) references estado(idEstado)
);
-- 4
create table categorias(
	idCategoria int auto_increment,
    nombre varchar(45),
    constraint ck_nombreCategoria check(nombre in ("Caramelos",
	"Chocolates envueltos", "Varios", "Chiclosos, jaleas y
	gomitas" , "Piezas, tablillas y bolsas", "Chocolates sin
	envolver")),
    constraint pk_categoria primary key (idCategoria)
);

-- 5
create table productos(
	idProducto int auto_increment,
    nombre varchar(30) not null,
    descripcion varchar(45) default "sin descripcion",
    idCategoria int,
    precio double,
    stock int,
    constraint pk_producto primary key (idProducto),
    constraint pk_categoria foreign key (idCategoria)
	references fk_categoria_productos(idCategoria),
    constraint ck_stock check (stock > -1),
    constraint ck_precio check (precio > -1)
);
-- 6
create table historial_suministro(
	idSuministro int auto_increment,
    constraint pk_suministro primary key(idSuministro),
    idFRANQUICIA int,
    constraint FK_idFRANQUICIA foreign key(idFRANQUICIA) references franquicias(idFranquicia),
	idPRODUCTO int,
    constraint FK_idPRODUCTO foreign key(idPRODUCTO) references productos(idProducto),
    cantidad int,
    constraint CK_cantidad check (cantidad > 0),
    fecha date 
);
-- 7
delimiter //
create procedure insertarEstado
(
in nombreEstado varchar(30)
)
begin
insert into estado(nombreEstado) values(nombreEstado);
end;
delimiter ;
call insertarEstado("Aguascalientes");
call insertarEstado("Guanajuato");
call insertarEstado("CDMX");
call insertarEstado("Queretaro");
call insertarEstado("Jalisco");

delimiter //
create procedure insertarFranquicia
(
in nombre varchar(30);
in direccion varchar(45);
in telefono varchar(60);
in idEstado int
)
begin  
insert into franquicias() values(nombreEstado);
end;
delimiter ;     



