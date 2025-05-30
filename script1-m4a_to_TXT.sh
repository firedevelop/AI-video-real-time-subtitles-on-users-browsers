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

for file in *.m4a; do
  echo "Starting transcription for $file..."
  transcribe_with_retry "$file"
done
