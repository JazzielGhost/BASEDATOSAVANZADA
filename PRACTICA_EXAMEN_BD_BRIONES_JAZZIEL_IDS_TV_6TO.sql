-- CREADO POR JAZZIEL BRIONES IDS T.V 6TO
CREATE DATABASE SECRETARIA_SEGURIDAD_PUBLICA;
USE SECRETARIA_SEGURIDAD_PUBLICA;
  -- drop database SECRETARIA_SEGURIDAD_PUBLICA;
  -- SHOW TABLES;
  -- describe tipo_infraccion;
CREATE TABLE tipo_infraccion(
	id_infraccion INT AUTO_INCREMENT,
    CONSTRAINT pk_id_infraccion PRIMARY KEY(id_infraccion),
    descripcion VARCHAR(100),
    puntos INT,
    CONSTRAINT chk_puntos CHECK(puntos >= 0),
    costo FLOAT,
    CONSTRAINT chk_costo CHECK(costo >= 0)
);

select * from tipo_infraccion;
-- ALTER TABLE tipo_infraccion AUTO_INCREMENT = 001;

delimiter $$
 CREATE PROCEDURE ALTA_TIPO_INFRACCION(IN descripcion_pr VARCHAR(100),IN puntos_pr INT, IN costo_pr FLOAT)
BEGIN
	INSERT INTO tipo_infraccion(descripcion,puntos,costo) VALUES(descripcion_pr,puntos_pr,costo_pr); 
END $$
delimiter ;

CALL ALTA_TIPO_INFRACCION("No usar cinturón de seguridad",1,497);
CALL ALTA_TIPO_INFRACCION("Estacionarse en rojo",2,2264);
CALL ALTA_TIPO_INFRACCION("Exceso de velocidad",3,1500);
CALL ALTA_TIPO_INFRACCION("No respetar la luz roja del semáforo",3,755);
CALL ALTA_TIPO_INFRACCION("Vuelta prohibida",3,2264);
CALL ALTA_TIPO_INFRACCION("Estacionarse en lugares para discapacitados",3,2150);
CALL ALTA_TIPO_INFRACCION("Uso del celular",3,2642);
CALL ALTA_TIPO_INFRACCION("Circular en sentido contrario",3,3200);
CALL ALTA_TIPO_INFRACCION("Manejar en estado de ebriedad",6,6640);
CALL ALTA_TIPO_INFRACCION("Invasión de pasos peatonales",3,2100);

-- describe MULTAS;
CREATE TABLE multas(
	id_multa INT AUTO_INCREMENT,
    CONSTRAINT pk_id_multa PRIMARY KEY(id_multa),
    fecha DATE NOT NULL,
    placas_vehiculo VARCHAR(50),
    id_infraccion INT,
    CONSTRAINT fk_id_infraccion FOREIGN KEY(id_infraccion) REFERENCES tipo_infraccion(id_infraccion)
);
select * from multas;

DELIMITER %%
CREATE PROCEDURE LEVANTAR_MULTA(
  IN placas_vehiculo_pr VARCHAR(50),
  IN id_infraccion_pr INT
)
BEGIN
  DECLARE placa_existente INT DEFAULT 0;
  
  SELECT COUNT(*) INTO placa_existente FROM multas 
  WHERE placas_vehiculo = placas_vehiculo_pr 
  AND id_infraccion <> id_infraccion_pr;
  
  IF placa_existente > 0 THEN
    SIGNAL SQLSTATE '20002'
    SET MESSAGE_TEXT = 'LA PLACA YA HA SIDO REGISTRADA EN OTRA MULTA';
  ELSE
    INSERT INTO multas(fecha, placas_vehiculo, id_infraccion) 
    VALUES(curdate(), placas_vehiculo_pr, id_infraccion_pr);
  END IF;
END %%
DELIMITER ;

-- drop PROCEDURE LEVANTAR_MULTA;
CALL LEVANTAR_MULTA('ABC123', 1);
CALL LEVANTAR_MULTA('DEF456', 2);
CALL LEVANTAR_MULTA('ABC1234', 3);
CALL LEVANTAR_MULTA('GHI789', 5);
CALL LEVANTAR_MULTA('JKL012', 10);
SELECT * FROM MULTAS;

-- describe historial_infracciones;
CREATE TABLE historial_infracciones(
	id_historial INT AUTO_INCREMENT,
    CONSTRAINT pk_id_historial PRIMARY KEY(id_historial),
    placas_vehiculo VARCHAR(50) UNIQUE,
    puntos_totales int,
    CONSTRAINT chk_puntos_totales CHECK(puntos_totales >= 0),
	deuda float,
	CONSTRAINT chk_deuda CHECK(deuda >= 0)
);
select * from historial_infracciones;

delimiter $$
CREATE TRIGGER TR_ALTA_MULTAS
after insert ON multas
FOR EACH ROW
BEGIN
    DECLARE puntos_aux int;
    DECLARE deuda_aux float;
	DECLARE placas_vehiculo_aux varchar(50);
    
	select puntos,costo into puntos_aux,deuda_aux from tipo_infraccion
    where id_infraccion = new.id_infraccion;
    SELECT placas_vehiculo into placas_vehiculo_aux from historial_infracciones
    WHERE PLACAS_VEHICULO = NEW.PLACAS_VEHICULO;
    
    if placas_vehiculo_aux is not null then
		UPDATE historial_infracciones
		SET puntos_totales = puntos_totales + puntos_aux,
        deuda = deuda + deuda_aux
		WHERE placas_vehiculo = NEW.placas_vehiculo;
    else
		 INSERT INTO historial_infracciones(placas_vehiculo, puntos_totales, deuda)
			VALUES (NEW.placas_vehiculo, puntos_aux, deuda_aux);
    end if;
    
    
END $$
delimiter ;
-- drop trigger TR_ALTA_MULTAS;

delimiter %%
CREATE PROCEDURE PAGAR_MULTA (IN placa_vehiculo_p VARCHAR(50),IN pago_p FLOAT)
BEGIN
	  DECLARE deuda_actual_aux FLOAT;
      SELECT deuda INTO deuda_actual_aux FROM historial_infracciones WHERE placas_vehiculo = placa_vehiculo_p;
      
      if pago_p > deuda_actual_aux then
		SIGNAL SQLSTATE '20002'
		SET MESSAGE_TEXT = 'El pago no puede ser mayor a la deuda actual';
      elseif pago_p < 0 then
		SIGNAL SQLSTATE '20002'
		SET MESSAGE_TEXT = 'El pago no puede ser menor que 0';
	 else	
		set deuda_actual_aux = deuda_actual_aux - pago_p;
        update historial_infracciones set deuda = deuda_actual_aux where placas_vehiculo = placa_vehiculo_p;
      end if;
END %%
delimiter ;
select * from historial_infracciones;
-- Pago exacto
CALL PAGAR_MULTA('ABC123', 994);
SELECT * FROM HISTORIAL_INFRACCIONES WHERE PLACAS_VEHICULO = 'ABC123';
-- Pago menor a la deuda
CALL PAGAR_MULTA('DEF456', 1000);
SELECT * FROM HISTORIAL_INFRACCIONES WHERE PLACAS_VEHICULO = 'DEF456';
-- Pago mayor a la deuda
CALL PAGAR_MULTA('GHI789', 3000);
SELECT * FROM HISTORIAL_INFRACCIONES WHERE PLACAS_VEHICULO = 'GHI789';

delimiter %%
CREATE FUNCTION ESTADO_DE_PUNTOS(f_placa_vehiculos varchar(50))
RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
	DECLARE temp_puntos INT;
    DECLARE temp_estado VARCHAR(50);
    SET temp_puntos = (SELECT puntos_totales FROM historial_infracciones WHERE placas_vehiculo = f_placa_vehiculos);
    SET temp_estado = (CASE
        WHEN temp_puntos < 4 THEN 'ESTABLE'
        WHEN temp_puntos > 3 AND temp_puntos < 7 THEN 'ADVERTIDO'
        WHEN temp_puntos > 6 AND temp_puntos < 12 THEN 'PELIGRO'
        WHEN temp_puntos > 11 THEN 'LICENCIA CANCELADA'
    END);
    RETURN temp_estado;
END %%
delimiter ;
drop function ESTADO_DE_PUNTOS;
select * from historial_infracciones;
SELECT ESTADO_DE_PUNTOS("ABC123"); -- Devuelve 'ESTABLE'
SELECT ESTADO_DE_PUNTOS("DEF456"); -- Devuelve 'ADVERTIDO'
SELECT ESTADO_DE_PUNTOS("GHI789"); -- Devuelve 'PELIGRO'
SELECT ESTADO_DE_PUNTOS("JKL012"); -- Devuelve 'LICENCIA CANCELADA'

-- describe DETALLE_MULTAS;
CREATE VIEW DETALLE_MULTAS AS
SELECT M.fecha, M.placas_vehiculo, I.descripcion AS INFRACCION
FROM MULTAS as M
JOIN tipo_infraccion AS I ON M.id_infraccion = I.id_infraccion;

select * from detalle_multas;

describe  detalle_deudas_puntos;
CREATE VIEW DETALLE_DEUDAS_PUNTOS AS
SELECT HI.placas_vehiculo, HI.deuda, HI.puntos_totales, ESTADO_DE_PUNTOS(HI.placas_vehiculo) AS ESTADO
FROM historial_infracciones as HI;
-- drop view DETALLE_DEUDAS_PUNTOS;

select * from detalle_deudas_puntos;
