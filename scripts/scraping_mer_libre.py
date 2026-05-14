import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

TOPIC_URL = "https://listado.mercadolibre.com.co/computacion/portatiles-laptops/"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
    "Accept-Language": "es-CO,es;q=0.9"
}

def extraer_mercado_libre_seguro():
    print("Iniciando extracción en Mercado Libre...")
    
    try:
        # Pausa inicial para no entrar "en seco" al servidor
        time.sleep(2) 
        
        response = requests.get(TOPIC_URL, headers=HEADERS, timeout=15)
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, "html.parser")
            items = soup.find_all("li", class_="ui-search-layout__item")
            
            resultados = []
            for item in items[:15]:
                nombre = item.find("h2", class_="ui-search-item__title").get_text(strip=True)
                precio_raw = item.find("span", class_="andes-money-amount__fraction").get_text(strip=True)
                
                precio = int(precio_raw.replace('.', ''))
                
                resultados.append({"nombre": nombre, "precio": precio})
                print(f"   Extraído: {nombre[:30]}... | ${precio}")
                
                # PAUSA CRÍTICA: Espera entre cada producto para simular lectura humana
                time.sleep(2) 

            if resultados:
                df = pd.DataFrame(resultados)
                df.to_csv("com_mercadolibre.csv", index=False, encoding="utf-8-sig")
                print("\ Archivo generado con éxito.")
            else:
                print("\n Lista vacía. El servidor bloqueó el contenido.")
        else:
            print(f"\n Error de conexión: {response.status_code}")
            
    except Exception as e:
        print(f"\n Error: {e}")

if __name__ == "__main__":
    extraer_mercado_libre_seguro()