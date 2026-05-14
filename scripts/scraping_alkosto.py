from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
import pandas as pd
import time

def extraer_con_selenium():
    print(" Iniciando Navegador Inteligente para Alkosto...")
    
    # Configuración para que no detecten que es un robot
    options = Options()
    # options.add_argument("--headless") 
    
    driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)
    
    try:
        url = "https://www.alkosto.com/search?text=auriculares+bluetooth"
        driver.get(url)
        
        # Esperamos 5 segundos a que el JavaScript cargue los productos
        print(" Esperando a que Alkosto cargue los precios...")
        time.sleep(5)
        
        # Buscamos los productos por la clase que vimos en tu captura
        items = driver.find_elements(By.CLASS_NAME, "product__item")
        
        print(f"[*] ¡ÉXITO! Se encontraron {len(items)} productos reales.")
        
        resultados = []
        for item in items[:15]:
            try:
                # Usamos selectores de Selenium
                nombre = item.find_element(By.CLASS_NAME, "product__item__top__link").text
                precio_raw = item.find_element(By.CLASS_NAME, "price").text
                
                # Limpiamos el precio
                precio = int(''.join(filter(str.isdigit, precio_raw)))
                
                resultados.append({"nombre": nombre, "precio": precio})
                print(f" Capturado: {nombre[:30]}... | ${precio}")
            except:
                continue

        # Guardar CSV
        if resultados:
            df = pd.DataFrame(resultados)
            df.to_csv("c_alkosto_techshop.csv", index=False, encoding="utf-8-sig")
            print("\n ARCHIVO GENERADO CON DATOS REALES DE ALKOSTO")
            
    finally:
        driver.quit()

if __name__ == "__main__":
    extraer_con_selenium()