-- ============================================================
-- 1. CONFIGURACIÓN E INICIALIZACIÓN DE LA BASE DE DATOS
-- ============================================================
DROP DATABASE IF EXISTS crisp_dm_ecommerce;
CREATE DATABASE IF NOT EXISTS crisp_dm_ecommerce
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crisp_dm_ecommerce;

-- ============================================================
-- 2. CREACIÓN DE ESTRUCTURAS (TABLAS DE DIMENSIONES)
-- ============================================================
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

-- ============================================================
-- 3. CREACIÓN DE ESTRUCTURAS (TABLAS DE HECHOS Y STAGING)
-- ============================================================
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

CREATE TABLE fact_inventario (
  id_inv        BIGINT         NOT NULL AUTO_INCREMENT PRIMARY KEY,
  fecha         DATE           NOT NULL,
  sku           VARCHAR(20)    NOT NULL,
  stock_inicial INT            NOT NULL DEFAULT 0,
  entradas      INT            NOT NULL DEFAULT 0,
  outputs       INT            NOT NULL DEFAULT 0, -- Nota: renombrado internamente o dejado como salidas según tu motor
  salidas       INT            NOT NULL DEFAULT 0,
  stock_final   INT            GENERATED ALWAYS AS (stock_inicial + entradas - salidas) STORED,
  FOREIGN KEY (fecha) REFERENCES dim_tiempo(fecha),
  FOREIGN KEY (sku)   REFERENCES dim_productos(sku),
  INDEX idx_inv_sku_fecha (sku, fecha)
);

-- Tabla para la carga del Web Scraping (Alkosto)
CREATE TABLE scraping_alkosto (
    id_scraping    INT AUTO_INCREMENT PRIMARY KEY,
    producto_db    VARCHAR(100) NOT NULL,     
    nombre_alkosto VARCHAR(255) NOT NULL,   
    precio         INT NOT NULL,                    
    fecha_consulta DATE DEFAULT (CURRENT_DATE)
);

-- ============================================================
-- 4. INGESTIÓN DE DATOS (POBLAR TABLAS DE DIMENSIONES)
-- ============================================================

-- Dimensión Canales
INSERT INTO dim_canales (id_canal, nombre)
VALUES 
  (1,'Web'), 
  (2,'App Movil'), 
  (3,'Marketplace'), 
  (4, 'Tienda Fisica'), 
  (5, 'Redes Sociales');

-- Dimensión Tiempo 
INSERT INTO dim_tiempo (fecha, anio, trimestre, mes, semana, dia_semana, es_festivo, temporada)
VALUES
  -- AÑO 2024
  ('2024-01-01', 2024, 1, 1, 1, 1, 1, 'Año Nuevo'),
  ('2024-01-15', 2024, 1, 1, 3, 1, 0, 'Normal'),
  ('2024-01-16', 2024, 1, 1, 3, 3, 0, 'Normal'),
  ('2024-01-20', 2024, 1, 1, 3, 7, 0, 'Normal'),
  ('2024-02-14', 2024, 1, 2, 7, 3, 0, 'San Valentin'),
  ('2024-03-08', 2024, 1, 3, 10, 5, 0, 'Dia Mujer'),
  ('2024-03-28', 2024, 1, 3, 13, 5, 1, 'Semana Santa'),
  ('2024-03-29', 2024, 1, 3, 13, 6, 1, 'Semana Santa'),
  ('2024-04-15', 2024, 2, 4, 16, 1, 0, 'Normal'),
  ('2024-05-12', 2024, 2, 5, 19, 1, 0, 'Dia de la Madre'),
  ('2024-06-16', 2024, 2, 6, 24, 1, 0, 'Dia del Padre'),
  ('2024-08-15', 2024, 3, 8, 33, 4, 0, 'Normal'),
  ('2024-09-21', 2024, 3, 9, 38, 7, 0, 'Amor y Amistad'),
  ('2024-10-31', 2024, 4, 10, 44, 5, 0, 'Halloween'),
  ('2024-11-29', 2024, 4, 11, 48, 6, 0, 'Black Friday'),
  ('2024-12-02', 2024, 4, 12, 49, 2, 0, 'Cyber Monday'),
  ('2024-12-24', 2024, 4, 12, 52, 3, 0, 'Víspera Navidad'),
  ('2024-12-25', 2024, 4, 12, 52, 4, 1, 'Navidad'),
  ('2024-12-31', 2024, 4, 12, 53, 3, 0, 'Fin de Año'),

  -- AÑO 2025
  ('2025-01-01', 2025, 1, 1, 1, 4, 1, 'Año Nuevo'),
  ('2025-01-10', 2025, 1, 1, 2, 5, 0, 'Normal'),
  ('2025-01-15', 2025, 1, 1, 3, 4, 0, 'Normal'),
  ('2025-01-16', 2025, 1, 1, 3, 5, 0, 'Normal'),
  ('2025-01-20', 2025, 1, 1, 4, 2, 0, 'Normal'),
  ('2025-02-14', 2025, 1, 2, 7, 6, 0, 'San Valentin'),
  ('2025-03-08', 2025, 1, 3, 10, 7, 0, 'Dia Mujer'),
  ('2025-03-15', 2025, 1, 3, 11, 6, 0, 'Normal'),
  ('2025-04-17', 2025, 2, 4, 16, 5, 1, 'Semana Santa'),
  ('2025-04-18', 2025, 2, 4, 16, 6, 1, 'Semana Santa'),
  ('2025-05-11', 2025, 2, 5, 19, 1, 0, 'Dia de la Madre'),
  ('2025-06-15', 2025, 2, 6, 24, 1, 0, 'Dia del Padre'),
  ('2025-06-20', 2025, 2, 6, 25, 5, 0, 'Normal'),
  ('2025-07-15', 2025, 3, 7, 29, 2, 0, 'Normal'),
  ('2025-08-30', 2025, 3, 8, 35, 6, 0, 'Normal'),
  ('2025-09-20', 2025, 3, 9, 38, 7, 0, 'Amor y Amistad'),
  ('2025-10-31', 2025, 4, 10, 44, 6, 0, 'Halloween'),
  ('2025-11-28', 2025, 4, 11, 48, 6, 0, 'Black Friday'),
  ('2025-12-01', 2025, 4, 12, 49, 2, 0, 'Cyber Monday'),
  ('2025-12-15', 2025, 4, 12, 51, 1, 0, 'Navidad'),
  ('2025-12-24', 2025, 4, 12, 52, 4, 0, 'Víspera Navidad'),
  ('2025-12-25', 2025, 4, 12, 52, 5, 1, 'Navidad'),
  ('2025-12-31', 2025, 4, 12, 53, 4, 0, 'Fin de Año');

-- Dimensión Productos
INSERT INTO dim_productos (sku, nombre, categoria, precio_costo, precio_venta)
VALUES
  ('SKU-001', 'Auriculares Bluetooth', 'Audio', 45000, 89900),
  ('SKU-002', 'Cable USB-C 2m', 'Accesorios', 5000, 12900),
  ('SKU-003', 'Mouse Inalambrico', 'Periféricos', 15000, 35900),
  ('SKU-004', 'Soporte para Monitor', 'Mobiliario', 25000, 49900),
  ('SKU-005', 'Teclado Mecanico RGB', 'Periféricos', 95000, 189900),
  ('SKU-006', 'Monitor 24 pulgadas FHD', 'Monitores', 380000, 550000),
  ('SKU-007', 'Cargador Carga Rapida', 'Accesorios', 40000, 85000),
  ('SKU-008', 'Funda Laptop 15 pulgadas', 'Accesorios', 25000, 55000),
  ('SKU-009', 'Disco Duro Externo 1TB', 'Almacenamiento', 140000, 210000),
  ('SKU-010', 'Webcam HD 1080p', 'Periféricos', 70000, 120000)
ON DUPLICATE KEY UPDATE 
  nombre = VALUES(nombre),
  categoria = VALUES(categoria),
  precio_costo = VALUES(precio_costo),
  precio_venta = VALUES(precio_venta);

-- ============================================================
-- 5. INGESTIÓN DE DATOS (POBLAR TABLAS DE HECHOS)
-- ============================================================

-- Tabla de Hechos: Inventario (Consolidado y ordenado por fecha)
INSERT INTO fact_inventario (fecha, sku, stock_inicial, entradas, salidas)
VALUES
  -- Inventario Inicial (Enero 2024)
  ('2024-01-01', 'SKU-001', 150, 0, 0),
  ('2024-01-01', 'SKU-002', 500, 0, 0),
  ('2024-01-01', 'SKU-003', 80,  0, 0),
  ('2024-01-01', 'SKU-004', 200, 0, 0),
  ('2024-01-01', 'SKU-005', 40,  0, 0),
  ('2024-01-01', 'SKU-006', 30,  0, 0),
  ('2024-01-01', 'SKU-007', 100, 0, 0),
  ('2024-01-01', 'SKU-008', 250, 0, 0),
  ('2024-01-01', 'SKU-009', 50,  0, 0),
  ('2024-01-01', 'SKU-010', 80,  0, 0),

  -- Reabastecimiento San Valentín (Febrero 2024)
  ('2024-02-14', 'SKU-001', 50,  100, 85),
  ('2024-02-14', 'SKU-002', 300, 200, 150),
  ('2024-02-14', 'SKU-006', 15,   20,  8),

  -- Reabastecimiento Estratégico (Agosto 2024 - Soporte Anti-Desabastecimiento)
  ('2024-08-15', 'SKU-003', 37, 100, 0), 
  ('2024-08-15', 'SKU-005', 7,   50, 0);

-- Tabla de Hechos: Ventas (Ordenado estrictamente cronológico)
INSERT INTO fact_ventas (fecha, sku, id_canal, cantidad, precio_unit) 
VALUES 
  -- VENTAS AÑO 2024
  ('2024-01-15', 'SKU-001', 1, 10, 89900),
  ('2024-01-15', 'SKU-001', 1, 12, 89900),
  ('2024-01-15', 'SKU-002', 1, 45, 12900),
  ('2024-01-15', 'SKU-003', 2, 8, 35900),
  ('2024-01-16', 'SKU-001', 3, 5, 89900),
  ('2024-01-16', 'SKU-004', 1, 18, 49900),
  ('2024-01-20', 'SKU-002', 2, 50, 12900),
  ('2024-01-20', 'SKU-005', 2, 3, 189900),
  ('2024-02-14', 'SKU-001', 1, 28, 89900),  -- Pico San Valentín
  ('2024-02-14', 'SKU-003', 1, 35, 35900),
  ('2024-02-14', 'SKU-006', 4, 5, 550000),
  ('2024-03-08', 'SKU-005', 3, 12, 189900),
  ('2024-05-12', 'SKU-001', 2, 30, 89900),
  ('2024-06-16', 'SKU-007', 1, 15, 85000),
  ('2024-09-21', 'SKU-005', 2, 18, 189900),
  ('2024-10-31', 'SKU-010', 3, 10, 120000),
  ('2024-11-29', 'SKU-006', 2, 8, 550000),
  ('2024-12-24', 'SKU-009', 1, 12, 210000),
  ('2024-12-25', 'SKU-009', 4, 5, 210000),
  ('2024-12-31', 'SKU-001', 5, 20, 89900),

  -- VENTAS AÑO 2025
  ('2025-01-15', 'SKU-001', 1, 15, 89900),
  ('2025-01-20', 'SKU-002', 2, 40, 12900),
  ('2025-02-14', 'SKU-005', 2, 15, 189900),
  ('2025-03-08', 'SKU-003', 3, 30, 35900),
  ('2025-05-11', 'SKU-006', 1, 3, 550000),
  ('2025-09-20', 'SKU-001', 2, 45, 89900),
  ('2025-10-31', 'SKU-003', 3, 50, 35900),
  ('2025-11-28', 'SKU-006', 5, 12, 550000),
  ('2025-12-24', 'SKU-009', 1, 10, 210000),
  ('2025-12-31', 'SKU-001', 5, 25, 89900);