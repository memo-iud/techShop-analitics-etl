
DROP DATABASE IF EXISTS crisp_dm_ecommerce;
CREATE DATABASE IF NOT EXISTS crisp_dm_ecommerce
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crisp_dm_ecommerce;
 
CREATE TABLE dim_productos (
  sku           VARCHAR(20)    NOT NULL PRIMARY KEY,
  nombre        VARCHAR(200)   NOT NULL,
  categoria     VARCHAR(100)   NOT NULL,
  subcategoria  VARCHAR(100),
  precio_costo  DECIMAL(12,2)  NOT NULL,
  precio_venta  DECIMAL(12,2)  NOT NULL,
  peso_kg       DECIMAL(8,3),
  activo        TINYINT(1)     DEFAULT 1,
  created_at    DATETIME       DEFAULT CURRENT_TIMESTAMP
);
 
CREATE TABLE dim_tiempo (
  fecha         DATE           NOT NULL PRIMARY KEY,
  anio          SMALLINT       NOT NULL,
  trimestre     TINYINT        NOT NULL,
  mes           TINYINT        NOT NULL,
  semana        TINYINT        NOT NULL,
  dia_semana    TINYINT        NOT NULL,  -- 1=Lun ... 7=Dom
  es_festivo    TINYINT(1)     DEFAULT 0,
  temporada     VARCHAR(50)    -- 'Navidad','BlackFriday','Normal'
);

CREATE TABLE dim_canales (
  id_canal      TINYINT        NOT NULL PRIMARY KEY,
  nombre        VARCHAR(50)    NOT NULL,  -- 'Web','App','Marketplace'
  activo        TINYINT(1)     DEFAULT 1
);
 
--  TABLA DE HECHOS: Ventas 
CREATE TABLE fact_ventas (
  id_venta      BIGINT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fecha         DATE           NOT NULL,
  sku           VARCHAR(20)    NOT NULL,
  id_canal      TINYINT        NOT NULL,
  cantidad      INT            NOT NULL,
  precio_unit   DECIMAL(12,2)  NOT NULL,
  total_venta   DECIMAL(14,2)  GENERATED ALWAYS AS (cantidad * precio_unit) STORED,
  created_at    DATETIME       DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fecha) REFERENCES dim_tiempo(fecha),
  FOREIGN KEY (sku)   REFERENCES dim_productos(sku),
  FOREIGN KEY (id_canal) REFERENCES dim_canales(id_canal),
  INDEX idx_fecha (fecha),
  INDEX idx_sku   (sku),
  INDEX idx_fecha_sku (fecha, sku)
);
 
-- TABLA DE HECHOS: Inventario 
CREATE TABLE fact_inventario (
  id_inv        BIGINT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fecha         DATE           NOT NULL,
  sku           VARCHAR(20)    NOT NULL,
  stock_inicial INT            NOT NULL DEFAULT 0,
  entradas      INT            NOT NULL DEFAULT 0,
  salidas       INT            NOT NULL DEFAULT 0,
  stock_final   INT            GENERATED ALWAYS AS (stock_inicial + entradas - salidas) STORED,
  FOREIGN KEY (fecha) REFERENCES dim_tiempo(fecha),
  FOREIGN KEY (sku)   REFERENCES dim_productos(sku),
  INDEX idx_inv_sku_fecha (sku, fecha)
);

-- ============================================================
--  DATOS DE PRUEBA — muestra representativa para validación
-- ============================================================
-- Dimensión Tiempo (muestra: 2024)
INSERT INTO dim_tiempo (fecha, anio, trimestre, mes, semana, dia_semana, es_festivo, temporada)
VALUES
  ('2024-01-01', 2024, 1, 1, 1, 1, 1, 'Año Nuevo'),
  ('2024-01-15', 2024, 1, 1, 3, 1, 0, 'Normal'),
  ('2024-02-14', 2024, 1, 2, 7, 3, 0, 'San Valentin'),
  ('2024-03-08', 2024, 1, 3, 10, 5, 0, 'Dia Mujer');
  CALL LlenarDimTiempo2024();
 
-- Dimensión Canales
INSERT INTO dim_canales (id_canal, nombre)
VALUES (1,'Web'), (2,'App Movil'), (3,'Marketplace');
 
-- Dimensión Productos
INSERT INTO dim_productos (sku, nombre, categoria, precio_costo, precio_venta)
VALUES
  ('SKU-001', 'Auriculares Bluetooth Pro', 'Electronica', 45000, 89900),
  ('SKU-002', 'Cable USB-C 2m',            'Accesorios',   3500,  12900),
  ('SKU-003', 'Funda Laptop 15 pulgadas',  'Accesorios',  15000,  35900),
  ('SKU-004', 'Mouse Inalambrico Ergon.',  'Perifericos',  22000,  49900),
  ('SKU-005', 'Teclado Mecanico RGB',      'Perifericos',  85000, 189900);
 
-- Hechos: Ventas (muestra enero 2024)
INSERT INTO fact_ventas (fecha, sku, id_canal, cantidad, precio_unit)
VALUES
  ('2024-01-15', 'SKU-001', 1,  12, 89900),
  ('2024-01-15', 'SKU-002', 1,  45, 12900),
  ('2024-01-15', 'SKU-003', 2,   8, 35900),
  ('2024-01-16', 'SKU-001', 3,   5, 89900),
  ('2024-01-16', 'SKU-004', 1,  18, 49900),
  ('2024-01-20', 'SKU-005', 2,   3, 189900),
  ('2024-02-14', 'SKU-001', 1,  28, 89900),  -- pico San Valentín
  ('2024-02-14', 'SKU-003', 1,  35, 35900);
 
-- Hechos: Inventario (stock inicial)
INSERT INTO fact_inventario (fecha, sku, stock_inicial, entradas, salidas)
VALUES
  ('2024-01-01', 'SKU-001', 150, 0, 0),
  ('2024-01-01', 'SKU-002', 500, 0, 0),
  ('2024-01-01', 'SKU-003', 80,  0, 0),
  ('2024-01-01', 'SKU-004', 200, 0, 0),
  ('2024-01-01', 'SKU-005', 40,  0, 0);
  
  -- ==========================================================
-- 1. MÁS DATOS PARA LAS DIMENSIONES (Catálogos)
-- ==========================================================

-- Nuevos Canales de Venta
INSERT INTO dim_canales (id_canal, nombre)
VALUES 
  (4, 'Tienda Fisica'), 
  (5, 'Redes Sociales');

-- Nuevos Productos (con categorías nuevas y existentes)
INSERT INTO dim_productos (sku, nombre, categoria, precio_costo, precio_venta)
VALUES
  ('SKU-006', 'Monitor 24 pulgadas FHD', 'Pantallas', 350000, 550000),
  ('SKU-007', 'Soporte para Monitor',   'Accesorios', 45000,  85000),
  ('SKU-008', 'Cargador Carga Rapida',  'Accesorios', 25000,  55000),
  ('SKU-009', 'Disco Duro Externo 1TB', 'Almacenamiento', 120000, 210000),
  ('SKU-010', 'Webcam 1080p c/ Microfono', 'Perifericos', 65000, 120000);


-- ==========================================================
-- 2. MÁS DATOS PARA LAS TABLAS DE HECHOS (Operaciones)
-- ==========================================================

-- Más Ventas (Febrero, Marzo, Abril y Mayo)
INSERT INTO fact_ventas (fecha, sku, id_canal, cantidad, precio_unit)
VALUES
  ('2024-02-14', 'SKU-006', 4,  2, 550000),
  ('2024-02-15', 'SKU-008', 5, 15,  55000),
  ('2024-02-20', 'SKU-002', 1, 30,  12900),
  ('2024-02-28', 'SKU-010', 3,  5, 120000),
  ('2024-03-08', 'SKU-001', 1, 40,  89900),
  ('2024-03-08', 'SKU-003', 2, 25,  35900),
  ('2024-03-15', 'SKU-009', 1, 10, 210000),
  ('2024-03-22', 'SKU-007', 4, 12,  85000),
  ('2024-04-05', 'SKU-004', 1, 20,  49900),
  ('2024-04-10', 'SKU-006', 3,  4, 550000),
  ('2024-04-18', 'SKU-005', 2,  8, 189900),
  ('2024-04-25', 'SKU-008', 4, 22,  55000),
  ('2024-05-10', 'SKU-001', 5, 50,  89900),
  ('2024-05-12', 'SKU-010', 1, 15, 120000),
  ('2024-05-15', 'SKU-009', 3,  6, 210000);


-- Inventario (Stock inicial para los nuevos productos en Enero y reabastecimiento en Marzo)
INSERT INTO fact_inventario (fecha, sku, stock_inicial, entradas, salidas)
VALUES
  ('2024-01-01', 'SKU-006', 30,  0, 0),
  ('2024-01-01', 'SKU-007', 100, 0, 0),
  ('2024-01-01', 'SKU-008', 250, 0, 0),
  ('2024-01-01', 'SKU-009', 50,  0, 0),
  ('2024-01-01', 'SKU-010', 80,  0, 0),
  ('2024-02-28', 'SKU-001', 50,  100, 85),
  ('2024-02-28', 'SKU-002', 300, 200, 150),
  ('2024-02-28', 'SKU-006', 15,   20,  8);
  


