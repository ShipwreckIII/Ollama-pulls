#!/bin/bash

models=(
  mistral
  gemma
  codellama
  llama3
  dolphin-mixtral
  orca-mini
  phi3
)

echo "📦 Starting Ollama model installation..."
echo "----------------------------------------"

for model in "${models[@]}"; do
  echo "⬇️ Pulling model: $model"
  if ollama pull "$model"; then
    echo "✅ Finished downloading: $model"
  else
    echo "❌ Failed to download: $model"
  fi
  echo "----------------------------------------"
done

echo "🎉 All model downloads attempted."
