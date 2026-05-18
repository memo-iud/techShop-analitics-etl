"""
Taller Web Scraping - Etapa 3 CRISP-DM
Caso Práctico: Mercado Libre - Investigación de Mercado TechShop S.A.S.
"""
import requests
from bs4 import BeautifulSoup
import pandas as pd
import time
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

TOPIC_URL = "http://webscraper.io/test-sites/e-commerce/allinone/computers/laptops"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
    "Accept-Language": "es-CO,es;q=0.9"
}

def extraer_emergencia():

    print("=" * 60)
    print(" ETL TECHSHOP S.A.S. - MODO RECUPERACIÓN DE DATOS")
    print("=" * 60)

    try:

        response = requests.get(
            TOPIC_URL,
            headers=HEADERS,
            timeout=15,
            verify=False
        )

        print("STATUS:", response.status_code)

        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")

        items = soup.find_all("div", class_="thumbnail")

        print(f"[*] Conectado con éxito. Procesando {len(items)} productos...")

        resultados = []

        for item in items[:15]:

            nombre = item.find("a", class_="title").get_text(strip=True)

            precio_raw = item.find("h4", class_="price").get_text(strip=True)

            precio = int(float(precio_raw.replace('$', '')))

            resultados.append({
                "nombre": nombre,
                "precio": precio
            })

            print(f"Extraído: {nombre[:30]}... | ${precio}")

            time.sleep(1)

        if resultados:

            df = pd.DataFrame(resultados)

            df.to_csv(
                "competencia_techshop.csv",
                index=False,
                encoding="utf-8-sig"
            )

            print("\nARCHIVO GENERADO CORRECTAMENTE")

    except Exception as e:
        print("ERROR DETALLADO:")
        print(type(e))
        print(e)

if __name__ == "__main__":
    extraer_emergencia()