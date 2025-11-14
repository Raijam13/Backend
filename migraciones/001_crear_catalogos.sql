-- 1. TIPO TRANSACCION (Ingreso o Gasto)
INSERT INTO TipoTransaccion (nombre) VALUES ('ingreso');
INSERT INTO TipoTransaccion (nombre) VALUES ('gasto');
-- Si las tablas usan AUTOINCREMENT, los IDs serán 1 y 2.

-- 2. FRECUENCIA (Período)
INSERT INTO Frecuencia (nombre) VALUES ('Mensual');
INSERT INTO Frecuencia (nombre) VALUES ('Semanal');
INSERT INTO Frecuencia (nombre) VALUES ('Anual');
INSERT INTO Frecuencia (nombre) VALUES ('Diario');

-- 3. CATEGORÍA
INSERT INTO Categoria (nombre) VALUES ('Salario');
INSERT INTO Categoria (nombre) VALUES ('Suscripciones');
INSERT INTO Categoria (nombre) VALUES ('Comida');
INSERT INTO Categoria (nombre) VALUES ('Transporte');
INSERT INTO Categoria (nombre) VALUES ('Vivienda');

-- 4. MONEDA
INSERT INTO Moneda (nombre) VALUES ('Soles');
INSERT INTO Moneda (nombre) VALUES ('Dólares');

-- 5. TIPO CUENTA
INSERT INTO TipoCuenta (nombre) VALUES ('Ahorros');
INSERT INTO TipoCuenta (nombre) VALUES ('Corriente');

-- 6. TIPO PAGO
INSERT INTO TipoPago (nombre) VALUES ('Tarjeta de Crédito');
INSERT INTO TipoPago (nombre) VALUES ('Efectivo');