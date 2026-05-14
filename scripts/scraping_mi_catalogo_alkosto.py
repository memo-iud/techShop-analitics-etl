from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
import pandas as pd
import time

def scraping_masivo_techshop():
    # 1. Lista de productos de techshop 
    productos_db = [
        "Auriculares Bluetooth", 
        "Cable USB-C 2m", 
        "Funda Laptop 15 pulgadas",
        "Soporte para Monitor",
        "Mouse Inalambrico", 
        "Cargador Carga Rapida",
        "Teclado Mecanico RGB",
        "Monitor 24 pulgadas FHD",
        "Disco Duro Externo 1TB",
        "Webcam HD 1080p",
    ]
    
    print(" Iniciando Comparador de Precios Inteligente...")
    
    options = Options()
    # options.add_argument("--headless") # Opcional: ocultar ventana
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    resultados_finales = []

    try:
        for producto in productos_db:
            print(f" Buscando competencia para: {producto}...")
            # Vamos a la página de búsqueda de Alkosto
            url_busqueda = f"https://www.alkosto.com/search?text={producto.replace(' ', '+')}"
            driver.get(url_busqueda)
            
            time.sleep(4) # Espera para carga de JavaScript
            
            try:
                # Tomamos el primer resultado que aparezca (el más relevante)
                item = driver.find_element(By.CLASS_NAME, "product__item")
                nombre_comp = item.find_element(By.CLASS_NAME, "product__item__top__link").text
                precio_raw = item.find_element(By.CLASS_NAME, "price").text
                
                # Transformación de datos
                precio_comp = int(''.join(filter(str.isdigit, precio_raw)))
                
                resultados_finales.append({
                    "Producto_DB": producto,
                    "Competencia_Nombre": nombre_comp,
                    "Precio_Competencia": precio_comp
                })
                print(f" Encontrado: {nombre_comp[:30]}... | ${precio_comp}")
                
            except:
                print(f" No se encontró resultado exacto para '{producto}'")
                continue
            
            time.sleep(4) # Pausa entre búsquedas para evitar bloqueos

        # 2. Carga de resultados a CSV
        if resultados_finales:
            df = pd.DataFrame(resultados_finales)
            df.to_csv("res_cata_alko_techshop.csv", index=False, encoding="utf-8-sig")
            print("\n" + "="*50)
            print(" PROCESO COMPLETADO")
            print("Se generó 'res_cata_alko_techshop.csv' con la comparativa.")
            print("="*50)

    finally:
        driver.quit()

if __name__ == "__main__":
    scraping_masivo_techshop()
    