#!/bin/bash

VIDEO="/mnt/c/Users/it77/Desktop/festival/2025-05-26 12-49-04.mkv"
OUTPUT_DIR="./transcripciones"
CHUNK_DURATION=60  # Duración en segundos de cada fragmento de audio
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
    echo "❌ Error al transcribir $file. Reintentando... ($retries/$MAX_RETRIES)"
    sleep 2
  done
  if [ $retries -eq $MAX_RETRIES ]; then
    echo "❌ Falló la transcripción de $file después de $MAX_RETRIES intentos."
  else
    # Mostrar el texto transcrito en consola
    local base_name=$(basename "$file" .wav)
    local txt_file="$OUTPUT_DIR/$base_name.txt"
    if [ -f "$txt_file" ]; then
      echo -e "\n📝 Transcripción fragmento $base_name:\n"
      cat "$txt_file"
      echo -e "\n------------------------------\n"
    fi
  fi
}

echo "⏳ Esperando que comience la grabación: $VIDEO"
while [ ! -f "$VIDEO" ]; do
  sleep 1
done
echo "🎬 Grabación detectada."

chunk_num=0

while true; do
  START_TIME=$((chunk_num * CHUNK_DURATION))
  WAV_FILE="$OUTPUT_DIR/chunk_${chunk_num}.wav"

  ffmpeg -y -i "$VIDEO" \
    -ss "$START_TIME" -t "$CHUNK_DURATION" \
    -vn -acodec pcm_s16le -ar 16000 -ac 1 "$WAV_FILE" &> /dev/null

  if [ ! -s "$WAV_FILE" ]; then
    echo "⌛ Esperando más contenido..."
    sleep 5
    continue
  fi

  echo "🔊 Transcribiendo el fragmento #$chunk_num..."
  transcribe_with_retry "$WAV_FILE"
  chunk_num=$((chunk_num + 1))
  sleep 10  # Para evitar solapamientos con fragmentos aún no grabados
done
