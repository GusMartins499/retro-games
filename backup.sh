#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

git add saves states es-de
if git diff --cached --quiet; then
  echo "Nada novo para salvar."
  exit 0
fi

git commit -q -m "chore(saves): backup $(date '+%Y-%m-%d %H:%M')"
git push -q
echo "Backup enviado."
