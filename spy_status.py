from subprocess import getoutput


def get_status():
    song = getoutput("spotify status")
    if "playing" in song:
        print("true")
    else: 
        print("false")

get_status()
