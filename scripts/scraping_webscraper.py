"""
Taller Web Scraping - Etapa 3 CRISP-DM
Caso Práctico: Mercado Libre - Investigación de Mercado TechShop S.A.S.
"""
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

# --- PLAN DE EMERGENCIA: Usamos un sitio que NO bloquea para TechShop ---
TOPIC_URL = "https://webscraper.io/test-sites/e-commerce/allinone/computers/laptops"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"
}

def extraer_emergencia():
    print("=" * 60)
    print("  ETL TECHSHOP S.A.S. - MODO RECOPERACIÓN DE DATOS")
    print("=" * 60)
    
    try:
        response = requests.get(TOPIC_URL, headers=HEADERS, timeout=15)
        soup = BeautifulSoup(response.text, "html.parser")
        
        # Selectores para este sitio de laptops
        items = soup.find_all("div", class_="thumbnail")
        print(f"[*] Conectado con éxito. Procesando {len(items)} productos...")
        
        resultados = []
        for item in items[:15]:
            # Extracción
            nombre = item.find("a", class_="title").get_text(strip=True)
            precio_raw = item.find("h4", class_="price").get_text(strip=True)
            
            # Transformación (Limpieza de caracteres para MySQL)
            precio = int(float(precio_raw.replace('$', '')))
            
            resultados.append({"nombre": nombre, "precio": precio})
            print(f" Extraído: {nombre[:30]}... | ${precio}")
            time.sleep(2) # Pausa mínima

        # Carga
        if resultados:
            df = pd.DataFrame(resultados)
            df.to_csv("competencia_techshop.csv", index=False, encoding="utf-8-sig")
            print("\n ¡ARCHIVO GENERADO! Revisa 'competencia_techshop.csv' en tu carpeta.")
            
    except Exception as e:
        print(f" Error: {e}")

if __name__ == "__main__":
    extraer_emergencia()