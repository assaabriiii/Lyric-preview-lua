import sys
import requests

def fetch_lyrics(artist, title):
    artist = artist.strip()
    title = title.strip()
    url = f"https://api.lyrics.ovh/v1/{artist}/{title}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return data.get("lyrics", "Lyrics not found or error occurred.")
    else:
        return "Error fetching lyrics."

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: fetch_lyrics.py <artist> <title>")
        sys.exit(1)
    
    artist = sys.argv[1]
    title = sys.argv[2]
    lyrics = fetch_lyrics(artist, title)
    print(lyrics)
