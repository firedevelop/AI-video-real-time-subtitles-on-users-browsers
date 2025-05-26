#!/bin/bash

MAX_RETRIES=3

transcribe_with_retry() {
  local file="$1"
  local retries=0
  while [ $retries -lt $MAX_RETRIES ]; do
    whisper "$file" --language Spanish --task transcribe --model medium --device cuda --output_format txt --output_dir . && break
    retries=$((retries + 1))
    echo "Error transcribing $file. Retrying... ($retries/$MAX_RETRIES)"
    sleep 2
  done
  if [ $retries -eq $MAX_RETRIES ]; then
    echo "Failed to transcribe $file after $MAX_RETRIES attempts."
  fi
}

for mkvfile in *.mkv; do
  base="${mkvfile%.*}"
  wavfile="${base}.wav"
  echo "Converting $mkvfile to $wavfile..."
  ffmpeg -y -i "$mkvfile" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$wavfile"
  if [ $? -eq 0 ]; then
    echo "Starting transcription for $wavfile..."
    transcribe_with_retry "$wavfile"
  else
    echo "Failed to convert $mkvfile"
  fi
done
