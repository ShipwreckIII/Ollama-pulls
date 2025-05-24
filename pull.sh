#!/bin/bash

models=(
  mistral
  gemma
  codellama
  llama3
  dolphin-mixtral
  orca-mini
  phi3
  phi4
  o4-mini
  gemma:3n
  medgemma
  openai-openmodel
  deepseek-r1
  llama4:scout
  llama4:maverick
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
