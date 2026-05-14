from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
import pandas as pd
import time

def scraping_masivo_techshop():
    productos_db_lista = [
        "Auriculares Bluetooth", "Cable USB-C 2m", "Funda Laptop 15 pulgadas",
        "Soporte para Monitor", "Mouse Inalambrico", "Cargador Carga Rapida",
        "Teclado Mecanico RGB", "Monitor 24 pulgadas FHD",
        "Disco Duro Externo 1TB", "Webcam HD 1080p",
    ]
    
    print(" Iniciando Scraper Profesional Sincronizado...")
    
    # --- CONFIGURACIÓN DE HEADERS Y OPCIONES ---
    options = Options()
    # Header para simular navegador humano
    options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36")
    # Evita que Alkosto detecte que Selenium tiene el control
    options.add_argument("--disable-blink-features=AutomationControlled")
    # options.add_argument("--headless") # Descomenta si no quieres ver la ventana abrirse
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    resultados_finales = []

    try:
        for producto_buscado in productos_db_lista:
            print(f"\n Buscando competencia para: {producto_buscado}...")
            url_busqueda = f"https://www.alkosto.com/search?text={producto_buscado.replace(' ', '+')}"
            driver.get(url_busqueda)
            
            # Scroll automático para cargar datos dinámicos (Lazy Load)
            for i in range(3):
                driver.execute_script(f"window.scrollTo(0, {(i+1)*1000});")
                time.sleep(2) # Tiempo prudente para carga de red
            
            items = driver.find_elements(By.CLASS_NAME, "product__item")
            
            for item in items:
                try:
                    nombre_web = item.find_element(By.CLASS_NAME, "product__item__top__link").text
                    precio_raw = item.find_element(By.CLASS_NAME, "price").text
                    precio_limpio = int(''.join(filter(str.isdigit, precio_raw)))
                    
                    resultados_finales.append({
                        "producto_db": producto_buscado,
                        "nombre_producto": nombre_web,
                        "precio": precio_limpio
                    })
                except:
                    continue
            
            time.sleep(5) # Pausa estratégica entre productos para evitar bloqueos

        #  Generación de CSV final
        if resultados_finales:
            df = pd.DataFrame(resultados_finales)
            df.to_csv("res_cata_alko_techshop_masivo.csv", index=False, encoding="utf-8-sig")
            print("\n" + "="*60)
            print(f" ÉXITO TOTAL: {len(resultados_finales)} registros capturados.")
            print("Archivo: 'res_cata_alko_techshop_masivo.csv'")
            print("="*60)

    finally:
        driver.quit()

if __name__ == "__main__":
    scraping_masivo_techshop()