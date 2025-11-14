INSERT INTO PagoPlanificado
(nombre, monto, idCuenta, idUsuario, idCategoria, idTipoTransaccion, idFrecuencia, intervalo, fechaInicio, idTipoPago)
VALUES ('Suscripción Netflix', 45.90, 1, 1, 2, 2, 1, 1, '2024-01-01', 1);
INSERT INTO PagoPlanificado
(nombre, monto, idCuenta, idUsuario, idCategoria, idTipoTransaccion, idFrecuencia, intervalo, fechaInicio, idTipoPago)
VALUES ('Salario', 3500.00, 1, 1, 1, 1, 1, 1, '2024-01-01', 2);
-- Pago 1 sin fin
INSERT INTO Repeticion (idPagoPlanificado, finTipo, fechaFin, conteoEventos)
VALUES (1, 'none', NULL, NULL);

-- Pago 2 con fin por fecha
INSERT INTO Repeticion (idPagoPlanificado, finTipo, fechaFin, conteoEventos)
VALUES (2, 'fecha', '2025-12-31', NULL);