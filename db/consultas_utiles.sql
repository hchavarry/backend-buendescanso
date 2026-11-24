-- Consultas de ejemplo para probar el modelo de datos.
-- NO se ejecutan automáticamente: son para copiar/pegar en psql.

-- 1) Servicios de cada hotel
SELECT id_hotel, nombre, servicios
FROM hoteles
ORDER BY id_hotel;

-- 2) Servicios de cada habitación (con el hotel al que pertenece)
SELECT ho.nombre AS hotel, ha.numero, ha.servicios
FROM habitaciones ha
JOIN hoteles ho ON ho.id_hotel = ha.id_hotel
ORDER BY ho.nombre, ha.numero;

-- 3) Habitaciones disponibles entre dos fechas
-- Reemplazá las fechas por las que quiera probar el usuario.
-- La condición de solapamiento es:
--   una reserva existente choca con el rango nuevo si
--   su fecha_ingreso es MENOR a la fecha_salida nueva
--   Y su fecha_salida es MAYOR a la fecha_ingreso nueva.
-- Las canceladas se ignoran porque liberan la habitación.
SELECT ho.nombre AS hotel, ha.id_habitacion, ha.numero, ha.capacidad, ha.precio_noche
FROM habitaciones ha
JOIN hoteles ho ON ho.id_hotel = ha.id_hotel
WHERE ha.capacidad >= 2
  AND NOT EXISTS (
      SELECT 1
      FROM reservas r
      WHERE r.id_habitacion = ha.id_habitacion
        AND r.estado <> 'cancelada'
        AND r.fecha_ingreso < DATE '2026-12-14'
        AND r.fecha_salida > DATE '2026-12-10'
  )
ORDER BY ho.nombre, ha.numero;

-- 4) Comprobar una habitación puntual antes de crear la reserva
-- Si devuelve 0 filas, está libre en ese rango.
SELECT r.id_reserva, r.fecha_ingreso, r.fecha_salida, r.estado
FROM reservas r
WHERE r.id_habitacion = 1
  AND r.estado <> 'cancelada'
  AND r.fecha_ingreso < DATE '2026-12-14'
  AND r.fecha_salida > DATE '2026-12-10';

-- 5) Todas las reservas, con estado, para ver cómo se liberan las canceladas
SELECT r.id_reserva, ho.nombre AS hotel, ha.numero, u.email,
       r.fecha_ingreso, r.fecha_salida, r.estado
FROM reservas r
JOIN habitaciones ha ON ha.id_habitacion = r.id_habitacion
JOIN hoteles ho ON ho.id_hotel = ha.id_hotel
JOIN usuarios u ON u.id_usuario = r.id_usuario
ORDER BY r.fecha_ingreso;
