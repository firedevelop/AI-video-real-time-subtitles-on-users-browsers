#!/bin/bash

VIDEO="/mnt/c/Users/it77/Desktop/festival/2025-05-26 12-49-04.mkv"
OUTPUT_DIR="./transcripciones"
CHUNK_DURATION=60  # segundos por fragmento
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
    return 1
  else
    local base_name=$(basename "$file" .wav)
    local txt_file="$OUTPUT_DIR/$base_name.txt"
    if [ -f "$txt_file" ]; then
      echo -e "\n📝 Transcripción fragmento $base_name:\n"
      cat "$txt_file"
      echo -e "\n------------------------------\n"
    fi
    return 0
  fi
}

echo "⏳ Esperando que comience la grabación: $VIDEO"
while [ ! -f "$VIDEO" ]; do
  sleep 1
done
echo "🎬 Grabación detectada."

chunk_num=0
no_new_audio_count=0
MAX_NO_AUDIO=5  # número de veces que no encuentra nuevo audio antes de finalizar

while true; do
  START_TIME=$((chunk_num * CHUNK_DURATION))
  WAV_FILE="$OUTPUT_DIR/chunk_${chunk_num}.wav"

  # Extraer el chunk de audio
  ffmpeg -y -i "$VIDEO" \
    -ss "$START_TIME" -t "$CHUNK_DURATION" \
    -vn -acodec pcm_s16le -ar 16000 -ac 1 "$WAV_FILE" &> /dev/null

  # Verificamos si el archivo tiene contenido
  if [ ! -s "$WAV_FILE" ]; then
    no_new_audio_count=$((no_new_audio_count + 1))
    echo "⌛ No hay audio nuevo, intento $no_new_audio_count/$MAX_NO_AUDIO..."
    if [ $no_new_audio_count -ge $MAX_NO_AUDIO ]; then
      echo "✅ No se detecta más audio nuevo. Finalizando..."
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

# Fusionar todos los txt en uno solo con el nombre del video
FINAL_TXT="$OUTPUT_DIR/$(basename "$VIDEO" .mkv).txt"
echo "📄 Fusionando todos los fragmentos en $FINAL_TXT ..."

cat "$OUTPUT_DIR"/chunk_*.txt > "$FINAL_TXT"

echo "✅ Transcripción completa guardada en $FINAL_TXT"
