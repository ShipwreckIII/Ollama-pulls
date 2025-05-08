# Ollama Model Installer

This script pulls multiple LLMs from the [Ollama](https://ollama.com) model registry using the CLI.

## 🧠 Models Included

- `mistral`
- `gemma`
- `codellama`
- `llama3`
- `dolphin-mixtral`
- `orca-mini`
- `phi3`

## 📦 Requirements

- [Ollama installed](https://ollama.com/download)
- Bash shell
- Internet connection

## 🚀 Usage

1. Clone or download this repository.
2. Make the script executable:

   ```bash
   chmod +x install_ollama_models.sh
   ```

3. Run the script:

   ```bash
   ./install_ollama_models.sh
   ```

Each model will be pulled with visible progress and a message after completion.

## 📓 Notes

- Models are downloaded locally to Ollama’s storage.
- You can list installed models with:
  ```bash
  ollama list
  ```

## 🛠️ License

MIT
