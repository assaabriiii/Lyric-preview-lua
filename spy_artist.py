from subprocess import getoutput


def get_artist():
    song = getoutput("spotify status")
    song = song.split("\n")
    song = song[1]
    song = song.split(":")
    song = song[1]
    song = song.split("-")
    music = song[0].strip()
    artist = song[1].strip()
    print(artist)

get_artist()
