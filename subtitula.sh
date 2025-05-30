#!/bin/bash

VIDEO="/mnt/c/Users/it77/Desktop/2025-05-26 13-36-15.mkv"
OUTPUT_DIR="./subtitles"
# change vale to 5 if you wich small delay near to real time
CHUNK_DURATION=60 
MAX_RETRIES=3

mkdir -p "$OUTPUT_DIR"

transcribe_with_retry() {
  local file="$1"
  local retries=0
  while [ $retries -lt $MAX_RETRIES ]; do
    whisper "$file" \
      --language Spanish \
      --task transcribe \
      --model medium \
      --device cuda \
      --output_format txt \
      --output_dir "$OUTPUT_DIR" && break
    retries=$((retries + 1))
    sleep 2
  done

  local base_name=$(basename "$file" .wav)
  local txt_file="$OUTPUT_DIR/$base_name.txt"
  if [ -f "$txt_file" ]; then
    cat "$txt_file" >> "$OUTPUT_DIR/subtitles.txt"
    echo -e "\n------------------------------\n" >> "$OUTPUT_DIR/subtitles.txt"
    tail -n 10 "$OUTPUT_DIR/subtitles.txt"
  fi
}

echo "⏳ Esperando video: $VIDEO"
while [ ! -f "$VIDEO" ]; do
  sleep 1
done

echo "🎬 Grabación detectada."

chunk_num=0
no_new_audio_count=0
MAX_NO_AUDIO=5

while true; do
  START_TIME=$((chunk_num * CHUNK_DURATION))
  WAV_FILE="$OUTPUT_DIR/chunk_${chunk_num}.wav"

  ffmpeg -y -i "$VIDEO" \
    -ss "$START_TIME" -t "$CHUNK_DURATION" \
    -vn -acodec pcm_s16le -ar 16000 -ac 1 "$WAV_FILE" &> /dev/null

  if [ ! -s "$WAV_FILE" ]; then
    no_new_audio_count=$((no_new_audio_count + 1))
    if [ $no_new_audio_count -ge $MAX_NO_AUDIO ]; then
      echo "✅ Transcripción terminada."
      break
    fi
    sleep 5
    continue
  fi

  no_new_audio_count=0
  echo "🔊 Transcribiendo fragmento #$chunk_num..."
  transcribe_with_retry "$WAV_FILE"

  chunk_num=$((chunk_num + 1))
  sleep 10
done
