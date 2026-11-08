Claude

























Ollama models · SH
#!/bin/bash
# =====================================================================
# Ollama model manager for X99 (TrueNAS Ollama app)
# Talks to the Ollama API, so it runs from the TrueNAS shell
# (no need to open the container terminal).
#
# Usage:
#   bash ollama-models.sh pull    -> download the models below (skips installed ones)
#   bash ollama-models.sh list    -> show installed models and their size
#   bash ollama-models.sh bench   -> speed-test each installed model from the list
# =====================================================================
 
# ---------- Settings (edit these) ----------
OLLAMA_URL="http://localhost:30068"        # app API port
BENCH_PROMPT="Explain what ZFS is in about 200 words."
LOG_FILE="./ollama-models.log"
BENCH_CSV="./ollama-bench.csv"
 
# ---------- Model list (put # in front of a line to skip it) ----------
models=(
  # Light - fast on CPU
  gemma3:4b
  nomic-embed-text
 
  # MoE - big but fast on CPU
  qwen3:30b
  gpt-oss:20b
  qwen3-coder:30b
 
  # Medium - stress test
  gemma3:12b
  qwen3:14b
  mistral-small3.2:24b
  gemma3:27b
  qwen3:32b
 
  # Extreme - optional, ~43 GB, needs app memory limit > 48 GB
  # llama3.3:70b
)
 
# ---------- Helpers ----------
log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"; }
 
# "nomic-embed-text" is stored as "nomic-embed-text:latest"
full_name() { [[ "$1" == *:* ]] && echo "$1" || echo "$1:latest"; }
 
check_ready() {
  for cmd in curl jq; do
    command -v "$cmd" >/dev/null || { echo "Missing tool: $cmd"; exit 1; }
  done
  if ! ver=$(curl -sf "$OLLAMA_URL/api/version" | jq -r .version); then
    echo "Cannot reach Ollama at $OLLAMA_URL - is the app running?"; exit 1
  fi
  log "Connected to Ollama $ver at $OLLAMA_URL"
}
 
installed_models() { curl -s "$OLLAMA_URL/api/tags" | jq -r '.models[].name'; }
 
is_installed() { installed_models | grep -qx "$(full_name "$1")"; }
 
# ---------- Actions ----------
do_pull() {
  ok=(); skipped=(); failed=()
  for m in "${models[@]}"; do
    if is_installed "$m"; then
      log "SKIP   $m (already installed)"; skipped+=("$m"); continue
    fi
    log "PULL   $m ... (large models can take a while)"
    res=$(curl -s "$OLLAMA_URL/api/pull" -d "{\"model\":\"$m\",\"stream\":false}")
    if [[ "$(echo "$res" | jq -r '.status // empty')" == "success" ]]; then
      log "DONE   $m"; ok+=("$m")
    else
      log "FAIL   $m -> $(echo "$res" | jq -r '.error // "unknown error"')"; failed+=("$m")
    fi
  done
  echo "----------------------------------------"
  echo "Downloaded: ${#ok[@]}  Skipped: ${#skipped[@]}  Failed: ${#failed[@]}"
  [[ ${#failed[@]} -gt 0 ]] && echo "Failed models: ${failed[*]}"
}
 
do_list() {
  curl -s "$OLLAMA_URL/api/tags" |
    jq -r '.models[] | "\(.name)\t\((.size/1073741824*10|floor)/10) GB"' |
    sort | column -t
}
 
do_bench() {
  [[ -f "$BENCH_CSV" ]] || echo "date,model,load_sec,prompt_tok_per_sec,gen_tok_per_sec,tokens" > "$BENCH_CSV"
  printf "%-24s %8s %12s %10s\n" "MODEL" "LOAD(s)" "PROMPT t/s" "GEN t/s"
  for m in "${models[@]}"; do
    [[ "$m" == "nomic-embed-text" ]] && continue          # embedding model, can't chat
    is_installed "$m" || continue
    # keep_alive 0 = unload after the test so RAM is freed for the next model
    res=$(curl -s "$OLLAMA_URL/api/generate" \
      -d "{\"model\":\"$m\",\"prompt\":\"$BENCH_PROMPT\",\"stream\":false,\"keep_alive\":0}")
    read -r load ptps gtps toks < <(echo "$res" | jq -r '[
        (.load_duration/1e9*10|floor/10),
        (.prompt_eval_count/(.prompt_eval_duration/1e9)*10|floor/10),
        (.eval_count/(.eval_duration/1e9)*10|floor/10),
        .eval_count] | @tsv')
    printf "%-24s %8s %12s %10s\n" "$m" "$load" "$ptps" "$gtps"
    echo "$(date '+%F %T'),$m,$load,$ptps,$gtps,$toks" >> "$BENCH_CSV"
  done
  echo "Results saved to $BENCH_CSV"
}
 
# ---------- Main ----------
check_ready
case "$1" in
  pull)  do_pull ;;
  list)  do_list ;;
  bench) do_bench ;;
  *)     echo "Usage: bash $0 {pull|list|bench}" ;;
esac
 
Claude finished the response
