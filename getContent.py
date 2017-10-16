import cfscrape
import sys
	
scraper = cfscrape.create_scraper()
scraper.headers["User-Agent"] = "Mozilla/5.0 (Linux; Android 4.4.2; Nexus 4 Build/KOT49H) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.114 Mobile Safari/537.36"
print(scraper.get(sys.argv[1]).content)