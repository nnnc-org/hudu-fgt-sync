#!/usr/bin/env bash
# List Hudu companies and their ids (for filling company_id in terraform.tfvars).
#
# Usage:
#   export HUDU_API_HOST="https://hudu.example.com"
#   export HUDU_API_KEY="your-api-key"
#   ./scripts/list-companies.sh            # all companies
#   ./scripts/list-companies.sh acme       # filter by name substring (case-insensitive)
#
# Requires: curl, jq.
set -euo pipefail

: "${HUDU_API_HOST:?set HUDU_API_HOST, e.g. https://hudu.example.com}"
: "${HUDU_API_KEY:?set HUDU_API_KEY}"

host="${HUDU_API_HOST%/}"
filter="${1:-}"

printf '%-8s  %s\n' "ID" "NAME"
printf '%-8s  %s\n' "------" "----"

page=1
while :; do
  resp="$(curl -fsS "$host/api/v1/companies?page=$page&page_size=100" \
    -H "x-api-key: $HUDU_API_KEY")"

  count="$(jq '.companies | length' <<<"$resp")"
  [ "$count" -eq 0 ] && break

  jq -r --arg f "$filter" '
    .companies[]
    | select($f == "" or (.name | ascii_downcase | contains($f | ascii_downcase)))
    | "\(.id)\t\(.name)"
  ' <<<"$resp" | while IFS=$'\t' read -r id name; do
    printf '%-8s  %s\n' "$id" "$name"
  done

  page=$((page + 1))
done
