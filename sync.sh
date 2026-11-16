#!/usr/bin/env bash
# Zet de basis in een project. Draai vanuit de root van het project:
#   bash <pad-naar-claude-basis>/sync.sh <pad-naar-claude-basis>
# Overschrijft .claude/basis/CLAUDE.md en alleen de skills die uit de basis komen.
set -euo pipefail
basis=${1:?pad naar claude-basis ontbreekt}
lijst=.claude/basis/skills.txt

# Skills die de vorige keer uit de basis kwamen weghalen, zodat een geschrapte skill ook verdwijnt.
if [ -f "$lijst" ]; then
  while read -r s; do [ -n "$s" ] && rm -rf ".claude/skills/$s"; done < "$lijst"
fi

mkdir -p .claude/basis .claude/skills
cp "$basis/CLAUDE.md" .claude/basis/CLAUDE.md
: > "$lijst"
for d in "$basis"/skills/*/; do
  s=$(basename "$d")
  # Een eigen skill van het project met dezelfde naam wordt niet overschreven.
  if [ -e ".claude/skills/$s" ]; then echo "overgeslagen: .claude/skills/$s bestaat al in het project" >&2; continue; fi
  cp -r "$d" ".claude/skills/$s"
  echo "$s" >> "$lijst"
done
