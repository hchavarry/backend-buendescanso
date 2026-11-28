-- Se ejecuta con psql o desde docker-entrypoint-initdb.d cuando agreguemos Docker

-- Necesario para que la restricción EXCLUDE pueda mezclar:
-- igualdad de id_habitacion (número) con solapamiento de rangos de fechas.
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE TABLE IF NOT EXISTS hoteles (
    id_hotel SERIAL PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion TEXT NOT NULL,
    direccion VARCHAR(180) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    provincia VARCHAR(80) NOT NULL,
    categoria SMALLINT NOT NULL CHECK (categoria BETWEEN 1 AND 5),
    foto_url TEXT,
    fotos TEXT,
    servicios TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS habitaciones (
    id_habitacion SERIAL PRIMARY KEY,
    id_hotel INTEGER NOT NULL REFERENCES hoteles (id_hotel) ON DELETE CASCADE,
    numero VARCHAR(20) NOT NULL,
    capacidad SMALLINT NOT NULL CHECK (capacidad > 0),
    cantidad_camas SMALLINT NOT NULL CHECK (cantidad_camas > 0),
    tipo_cama VARCHAR(40) NOT NULL,
    desayuno_incluido BOOLEAN NOT NULL DEFAULT FALSE,
    precio_noche NUMERIC(10, 2) NOT NULL CHECK (precio_noche >= 0),
    descripcion TEXT,
    servicios TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_habitacion_por_hotel UNIQUE (id_hotel, numero)
);

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    telefono VARCHAR(30),
    contrasena_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reservas (
    id_reserva SERIAL PRIMARY KEY,
    id_usuario INTEGER NOT NULL REFERENCES usuarios (id_usuario) ON DELETE RESTRICT,
    id_habitacion INTEGER NOT NULL REFERENCES habitaciones (id_habitacion) ON DELETE RESTRICT,
    fecha_ingreso DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    fecha_reservacion TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cantidad_huespedes SMALLINT NOT NULL CHECK (cantidad_huespedes > 0),
    precio_total NUMERIC(12, 2) NOT NULL CHECK (precio_total >= 0),
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente', 'confirmada', 'cancelada')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_rango_fechas CHECK (fecha_salida > fecha_ingreso)
);

CREATE INDEX IF NOT EXISTS idx_habitaciones_hotel ON habitaciones (id_hotel);
CREATE INDEX IF NOT EXISTS idx_reservas_habitacion ON reservas (id_habitacion);
CREATE INDEX IF NOT EXISTS idx_reservas_usuario ON reservas (id_usuario);
CREATE INDEX IF NOT EXISTS idx_reservas_estado ON reservas (estado);

-- Regla definitiva de disponibilidad:
-- dos reservas ACTIVAS de la misma habitación no pueden solaparse.
-- daterange(..., '[)') hace que la fecha de salida sea exclusiva:
-- una reserva que termina el 14 y otra que empieza el 14 NO chocan.
-- Las canceladas quedan fuera de la restricción y liberan la habitación.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'excl_reservas_solapadas'
    ) THEN
        ALTER TABLE reservas
        ADD CONSTRAINT excl_reservas_solapadas
        EXCLUDE USING gist (
            id_habitacion WITH =,
            daterange(fecha_ingreso, fecha_salida, '[)') WITH &&
        ) WHERE (estado <> 'cancelada');
    END IF;
END $$;
