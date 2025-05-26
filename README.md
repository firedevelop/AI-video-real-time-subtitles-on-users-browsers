# AI-video-real-time-subtitles-on-users-browsers
Capture OBS Socket audio convert to text with wisper. Socket text translated to localhost browsers for the audience.

# 🎬 Whisper Subtitles to Browser

This project uses [Whisper](https://github.com/openai/whisper) by OpenAI to transcribe `.mkv` videos and display subtitles in a web browser in real-time. It is designed to run in WSL2 with GPU acceleration (CUDA) and supports Spanish language transcription.

---

## 📁 Project Structure
terminal-to-browser/
├── index.html # Web page that shows subtitles
├── server.js # Express server that sends subtitles to the browser
├── watcher.sh # Bash script that splits the video, transcribes, and saves results
└── transcripciones/ # Folder where .wav and .txt fragments are stored


---

## ⚙️ Requirements

- Windows 11 with WSL2 (Ubuntu)
- NVIDIA GPU with CUDA support (e.g., RTX 4060)
- Node.js + npm
- ffmpeg
- Python + Whisper

### Install Whisper on WSL2

```bash
pip install git+https://github.com/openai/whisper.git
```

### Install Node.js dependencies
`` npm install express

🚀 Run the Project
Step 1: Place your video
Move your .mkv video to a known Windows path, for example:

makefile
Copy
Edit
C:\Users\YourName\Desktop\festival\myvideo.mkv
In the script watcher.sh, set the path using WSL style:

bash
Copy
Edit
VIDEO="/mnt/c/Users/YourName/Desktop/festival/myvideo.mkv"
Step 2: Start the Node.js server
bash
Copy
Edit
node server.js
Then open your browser at:

arduino
Copy
Edit
http://localhost:3000
🔴 Mode 1: Real-time subtitles (CHUNK_DURATION = 5)
This mode is best for displaying subtitles in sync with a video.

How to enable real-time mode
In watcher.sh, set:

bash
Copy
Edit
CHUNK_DURATION=5
Then run the transcription script:

bash
Copy
Edit
./watcher.sh
This will start splitting the audio into 5-second chunks and transcribe each one. Each transcribed fragment is sent to the browser immediately.

📄 Mode 2: Full-text mode (CHUNK_DURATION = 60)
This mode is better for reading or for presentations with larger blocks of text.

How to enable full-text mode
In watcher.sh, set:

bash
Copy
Edit
CHUNK_DURATION=60
Then run:

bash
Copy
Edit
./watcher.sh
This will process the audio in longer chunks and send larger blocks of text to the browser as they are ready.

🌐 Web Interface Features
Displays the latest transcribed text from Whisper

Automatically scrolls to the newest subtitle

Keeps previous blocks visible in the browser

Works on any browser at http://localhost:3000

🧠 How It Works
The script watcher.sh waits for your .mkv video to appear.

It extracts small audio chunks with ffmpeg.

Each chunk is passed to whisper for transcription.

The resulting .txt files are saved to transcripciones/.

The Node.js server watches the output and pushes it to the browser.

The browser updates the display and auto-scrolls.

🖼️ Screenshot Example
Add your screenshot here
Example:


✅ Features Summary
Real-time and full-text transcription modes

Whisper transcriptions with retry mechanism

GPU support with CUDA

Works with .mkv videos

Simple and readable interface

Auto-scrolling to latest subtitle

Easy to run and customize

🔧 Configuration Tips
You can adjust CHUNK_DURATION to balance speed vs context.

Whisper model used: medium (can be changed to base, small, etc.)

Language is currently set to Spanish, but you can change --language flag.



# Notes
# Download
yt-dlp -f bestaudio --postprocessor-args "-ss 00:03:44" -o "002_Teaching.%(ext)s" "https://youtu.be/xxx"

# convert audio .webm to wav
ffmpeg -i 002_Teaching.webm -ar 16000 -ac 1 002_Meditacion.wav

# convert all audio files
for f in *.webm; do ffmpeg -i "$f" -ar 16000 -ac 1 "${f%.webm}.wav"; done


yt-dlp -f bestaudio --postprocessor-args "-ss 00:03:44" -o "003_Ensenanza.%(ext)s" "https://youtu.be/xxx"


