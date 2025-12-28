#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${LOG_FILE:-.vite-dev.log}"
SHOPIFY_LOG="${SHOPIFY_LOG:-.shopify-dev.log}"
ENABLE_LOGS="${ENABLE_LOGS:-0}"

if [ "$ENABLE_LOGS" -eq 1 ]; then
  : > "$LOG_FILE"
  : > "$SHOPIFY_LOG"
else
  LOG_FILE="/dev/null"
  SHOPIFY_LOG="/dev/null"
fi

if [ "$ENABLE_LOGS" -eq 1 ]; then
  npm run -s vite:dev >"$LOG_FILE" 2>&1 &
else
  npm run -s vite:dev >/dev/null 2>&1 &
fi
VITE_PID=$!

cleanup() {
  kill "$VITE_PID" 2>/dev/null || true
}
trap cleanup EXIT

printf "Waiting for Vite tunnel...\n"
SNIPPET_FILE="snippets/vite-tag.liquid"
until grep -q "trycloudflare.com" "$SNIPPET_FILE"; do
  if ! kill -0 "$VITE_PID" 2>/dev/null; then
    echo "Vite exited. Check $LOG_FILE"
    exit 1
  fi
  sleep 0.5
done

printf "Tunnel ready. Starting Shopify dev...\n"
if [ "$ENABLE_LOGS" -eq 1 ]; then
  shopify theme dev "$@" 2>&1 | tee -a "$SHOPIFY_LOG" &
else
  shopify theme dev "$@" &
fi
SHOPIFY_PID=$!

# Force a sync of the updated snippet once Shopify CLI is running.
printf "Waiting for Shopify sync of vite-tag.liquid...\n"
if [ "$ENABLE_LOGS" -eq 1 ]; then
  until grep -q "Uploaded snippets/vite-tag.liquid" "$SHOPIFY_LOG"; do
    if ! kill -0 "$SHOPIFY_PID" 2>/dev/null; then
      echo "Shopify dev exited."
      echo "Check $SHOPIFY_LOG"
      exit 1
    fi
    touch "snippets/vite-tag.liquid"
    sleep 1
  done
else
  for _ in {1..15}; do
    if ! kill -0 "$SHOPIFY_PID" 2>/dev/null; then
      echo "Shopify dev exited."
      exit 1
    fi
    touch "snippets/vite-tag.liquid"
    sleep 1
  done
fi

wait "$SHOPIFY_PID"
