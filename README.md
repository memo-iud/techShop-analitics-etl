# TechShop S.A.S. - Sistema Predictivo y Monitoreo de Precios (CRISP-DM) 🚀

Este repositorio contiene la implementación de la **Etapa 3** (Preparación de Datos) de la metodología CRISP-DM, integrada en un proyecto macro de analítica para la optimización de inventarios y competitividad de **TechShop S.A.S.**

---

## 🏢 Contexto del Proyecto (Fases 1 y 2)

### Fase 1: Comprensión del Negocio (Business Understanding)
**TechShop S.A.S.** busca resolver la ineficiencia en la gestión de stock y la pérdida de competitividad. 
* **Objetivo Principal:** Reducir los costos de almacenamiento y evitar la pérdida de ventas por falta de productos (stockouts).
* **Estrategia:** Implementar modelos de series temporales (ARIMA) para predecir la demanda y, simultáneamente, monitorear los precios de la competencia para ajustar el margen de maniobra comercial.

### Fase 2: Comprensión de los Datos (Data Understanding)
Se determinó que el modelo requiere tres fuentes de información:
1.  **Histórico de Ventas:** (Datos internos).
2.  **Catálogo de Productos:** Almacenado en la base de datos relacional `techshop_db`.
3.  **Datos Externos (Competencia):** Precios en tiempo real de **Alkosto** y **Mercado Libre**, identificados como los competidores con mayor impacto en el flujo de caja de la compañía.

---

## 🛠️ Fase 3: Preparación de Datos (Implementación Técnica)
En esta etapa, se desarrolló la infraestructura para la ingesta de datos externos que alimentarán el tablero de decisiones.

### Arquitectura de Archivos .py
* **`scripts/scraping_alkosto.py`**: Implementación con **Selenium WebDriver**. Gestiona la búsqueda dinámica de los 10 productos estrella definidos en el inventario (Laptops, Monitores, Periféricos).
* **`scripts/scraping_mer_libre.py`**: Scraper diseñado para capturar la variabilidad de precios en el marketplace de Mercado Libre.
* **`scripts/conexion_MySQL.py`**: Módulo de conexión robusto que garantiza que cada dato extraído se vincule correctamente con el `ID` del producto en la base de datos de TechShop.

---

## 🚧 Desafíos de Ingeniería y Soluciones

Durante el desarrollo se superaron obstáculos críticos de integración:

1.  **Sincronización de Identificadores:** Se aseguró que los nombres extraídos de la web se normalizaran para coincidir con la tabla `productos` de la Base de Datos.
2.  **Superación de Barreras Dinámicas:** Implementación de esperas explícitas para capturar precios que se cargan vía JavaScript asíncrono, evitando el error de "0 productos encontrados".
3.  **Manejo de Errores de Red:** Corrección del error `getaddrinfo failed` mediante la implementación de reintentos lógicos y verificación de estados de conexión DNS.
4.  **Optimización de Carga SQL:** Uso de `executemany` para insertar el histórico de precios sin saturar el servidor local de MySQL.

---

## 📂 Estructura del Repositorio
* **`/scripts`**: Motores de automatización y lógica de persistencia.
* **`/sql`**: Esquema de la base de datos `techshop_db`, incluyendo la tabla de precios de competencia.
* **`/data`**: Archivos CSV con la data cruda procesada durante las pruebas.
* **`.gitignore`**: Filtro de seguridad para evitar la exposición de credenciales de la base de datos.

## ⚙️ Instalación 

 **Instalar librerías:** `pip install selenium mysql-connector-python pandas webdriver-manager`
  **Base de Datos:** Ejecutar los scripts de la carpeta `/sql` para recrear el entorno.

**Autores:** Guillermo Loaiza Mesa | Jaider Morales Bautista | Robinson Marin Morales| Aleicer Vesga Rueda 
**Instructora:** Ana Maria Lopez Moreno  
**Curso:** Programación para Análisis de Datos