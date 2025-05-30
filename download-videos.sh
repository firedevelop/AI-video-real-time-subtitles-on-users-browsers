# download video and open in visual studio code to see language data
yt-dlp --referer "https://player.company.org" -f bestaudio --extract-audio --audio-format wav -o "01_retiro.%(ext)s" "https://vz-000-4a3.b-cdn.net/ece34373-b3a9-47a3-8a22-000/playlist.m3u8"

# see something like this:
EXT-X-MEDIA:TYPE=AUDIO,URI="audio_2/audio.m3u8",GROUP-ID="audio",LANGUAGE="es",NAME="Spanish",DEFAULT=NO,AUTOSELECT=YES,CHANNELS="1"

# here is the language:
audio_2/audio.m3u8

# modify the url like this:
https://player.company.org" -i "https://vz-000.b-cdn.net/000/audio_2/audio.m3u8

# use this bash to download only the audio in your language
# download using ffmeg
ffmpeg -headers "Referer: https://player.company.org" -i "https://vz-000-4a3.b-cdn.net/000/audio_2/audio.m3u8" -c copy 02_retiro_es.m4a
