-- Datos mínimos para probar el catálogo y el flujo de reservas.

INSERT INTO hoteles (nombre, descripcion, direccion, ciudad, provincia, categoria, foto_url, fotos, servicios)
SELECT 'BuenDescanso Bariloche', 'Hotel de montaña con vista al lago y desayuno incluido.',
       'Av. Civica 240', 'San Carlos de Bariloche', 'Rio Negro', 4,
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
       'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800, https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800, https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
       'WiFi; Pileta; Desayuno; Estacionamiento'
WHERE NOT EXISTS (SELECT 1 FROM hoteles WHERE nombre = 'BuenDescanso Bariloche');

INSERT INTO hoteles (nombre, descripcion, direccion, ciudad, provincia, categoria, foto_url, fotos, servicios)
SELECT 'BuenDescanso Tandil', 'Alojamiento boutique en el centro, a pasos de la Sierra.',
       'Independencia 845', 'Tandil', 'Buenos Aires', 3,
       'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
       'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800, https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800, https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800',
       'WiFi; Spa; Restaurante; Traslado al aeropuerto'
WHERE NOT EXISTS (SELECT 1 FROM hoteles WHERE nombre = 'BuenDescanso Tandil');

INSERT INTO hoteles (nombre, descripcion, direccion, ciudad, provincia, categoria, foto_url, fotos, servicios)
SELECT 'BuenDescanso Mendoza', 'Complejo con pileta y spa cerca de las bodegas.',
       'Av. Belgrano 1120', 'Mendoza', 'Mendoza', 5,
       'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
       'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800, https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800, https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=800',
       'WiFi; Pileta; Spa; Gimnasio; Bodega'
WHERE NOT EXISTS (SELECT 1 FROM hoteles WHERE nombre = 'BuenDescanso Mendoza');

INSERT INTO habitaciones (id_hotel, numero, capacidad, cantidad_camas, tipo_cama,
                          desayuno_incluido, precio_noche, descripcion, servicios)
SELECT h.id_hotel, '101', 2, 1, 'Queen', TRUE, 120.00, 'Habitación luminosa con vista al jardín.',
       'WiFi; TV; Aire acondicionado; Caja de seguridad'
FROM hoteles h
WHERE h.nombre = 'BuenDescanso Bariloche'
  AND NOT EXISTS (SELECT 1 FROM habitaciones ha WHERE ha.id_hotel = h.id_hotel AND ha.numero = '101');

INSERT INTO habitaciones (id_hotel, numero, capacidad, cantidad_camas, tipo_cama,
                          desayuno_incluido, precio_noche, descripcion, servicios)
SELECT h.id_hotel, '102', 4, 2, 'Doble', TRUE, 175.50, 'Ideal para familias o dos parejas.',
       'WiFi; TV; Aire acondicionado; Cocina'
FROM hoteles h
WHERE h.nombre = 'BuenDescanso Bariloche'
  AND NOT EXISTS (SELECT 1 FROM habitaciones ha WHERE ha.id_hotel = h.id_hotel AND ha.numero = '102');

INSERT INTO habitaciones (id_hotel, numero, capacidad, cantidad_camas, tipo_cama,
                          desayuno_incluido, precio_noche, descripcion, servicios)
SELECT h.id_hotel, '201', 2, 1, 'King', FALSE, 95.00, 'Habitación interior tranquila.',
       'WiFi; TV; Calefacción'
FROM hoteles h
WHERE h.nombre = 'BuenDescanso Tandil'
  AND NOT EXISTS (SELECT 1 FROM habitaciones ha WHERE ha.id_hotel = h.id_hotel AND ha.numero = '201');

INSERT INTO habitaciones (id_hotel, numero, capacidad, cantidad_camas, tipo_cama,
                          desayuno_incluido, precio_noche, descripcion, servicios)
SELECT h.id_hotel, '301', 3, 2, 'Single', TRUE, 210.00, 'Suite con terraza y spa privado.',
       'WiFi; TV; Aire acondicionado; Jacuzzi; Terraza'
FROM hoteles h
WHERE h.nombre = 'BuenDescanso Mendoza'
  AND NOT EXISTS (SELECT 1 FROM habitaciones ha WHERE ha.id_hotel = h.id_hotel AND ha.numero = '301');

INSERT INTO usuarios (nombre, apellido, email, telefono, contrasena_hash)
SELECT 'Ana', 'Gomez', 'ana@example.com', '2915551234', 'hash-de-ejemplo-no-usar-en-produccion'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email = 'ana@example.com');

INSERT INTO usuarios (nombre, apellido, email, telefono, contrasena_hash)
SELECT 'Luis', 'Perez', 'luis@example.com', '2495556789', 'hash-de-ejemplo-no-usar-en-produccion'
WHERE NOT EXISTS (SELECT 1 FROM usuarios WHERE email = 'luis@example.com');

INSERT INTO reservas (id_usuario, id_habitacion, fecha_ingreso, fecha_salida,
                      cantidad_huespedes, precio_total, estado)
SELECT u.id_usuario, ha.id_habitacion, DATE '2026-12-10', DATE '2026-12-14', 2, 482.00, 'confirmada'
FROM usuarios u
CROSS JOIN habitaciones ha
JOIN hoteles h ON h.id_hotel = ha.id_hotel
WHERE u.email = 'ana@example.com'
  AND h.nombre = 'BuenDescanso Bariloche'
  AND ha.numero = '101'
  AND NOT EXISTS (
      SELECT 1 FROM reservas r
      WHERE r.id_usuario = u.id_usuario
        AND r.id_habitacion = ha.id_habitacion
        AND r.fecha_ingreso = DATE '2026-12-10'
  );

INSERT INTO reservas (id_usuario, id_habitacion, fecha_ingreso, fecha_salida,
                      cantidad_huespedes, precio_total, estado)
SELECT u.id_usuario, ha.id_habitacion, DATE '2026-12-20', DATE '2026-12-22', 2, 190.00, 'pendiente'
FROM usuarios u
CROSS JOIN habitaciones ha
JOIN hoteles h ON h.id_hotel = ha.id_hotel
WHERE u.email = 'luis@example.com'
  AND h.nombre = 'BuenDescanso Tandil'
  AND ha.numero = '201'
  AND NOT EXISTS (
      SELECT 1 FROM reservas r
      WHERE r.id_usuario = u.id_usuario
        AND r.id_habitacion = ha.id_habitacion
        AND r.fecha_ingreso = DATE '2026-12-20'
  );
