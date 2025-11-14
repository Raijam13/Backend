-- 7. USUARIO DE PRUEBA (ASUMIMOS id = 1)
INSERT INTO Usuario (nombres, apellidos, correo, contraseña) 
VALUES ('Juan', 'Perez', 'test@app.com', '123456');

-- 8. CUENTA DE PRUEBA (ASUMIMOS idUsuario=1, idMoneda=1, idTipoCuenta=1)
INSERT INTO Cuenta (nombre, saldo, idUsuario, idMoneda, idTipoCuenta) 
VALUES ('Cuenta Principal', 1000.00, 1, 1, 1);