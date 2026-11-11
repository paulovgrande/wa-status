#!/usr/bin/env bash
# Executa uma rotina do WA Status no MODO LOCAL (sem GitHub), chamado pelo agendador do sistema
# (launchd no macOS, cron no Linux/WSL). Ver docs/INSTALACAO.md, Parte E2.
#
# Uso:  scripts/run-rotina.sh lote
#       scripts/run-rotina.sh slot 1      (1 a 4)
#
# - Carrega o .env da pasta do projeto (a chave nunca é impressa).
# - Impede duas execuções ao mesmo tempo (trava em state/.lock-rotina).
# - Chama o Claude Code sem interface (claude -p) com o prompt da rotina.
# - Grava o log em logs/AAAA-MM-DD.log e mantém só os últimos 30 dias.
set -uo pipefail

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RAIZ" || exit 1
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

TIPO="${1:-}"; SLOT="${2:-}"
case "$TIPO" in
  lote) PROMPT="Execute as instruções de routines/lote-semanal.md. MODO LOCAL: pule os passos de git pull e git push." ;;
  slot) [[ "$SLOT" =~ ^[1-4]$ ]] || { echo "uso: $0 slot <1-4>" >&2; exit 2; }
        PROMPT="Execute routines/slot.md com SLOT=$SLOT. MODO LOCAL: pule os passos de git pull e git push." ;;
  *)    echo "uso: $0 lote | slot <1-4>" >&2; exit 2 ;;
esac

mkdir -p logs state
LOG="logs/$(date +%F).log"
find logs -name '*.log' -mtime +30 -delete 2>/dev/null

# Trava simples e portátil (mkdir é atômico; funciona no macOS, que não tem flock)
TRAVA="state/.lock-rotina"
if ! mkdir "$TRAVA" 2>/dev/null; then
  # trava com mais de 3 h é resto de execução interrompida
  if [ -n "$(find "$TRAVA" -maxdepth 0 -mmin +180 2>/dev/null)" ]; then rm -rf "$TRAVA"; mkdir "$TRAVA"
  else echo "$(date '+%F %T') outra rotina em andamento; saindo" >> "$LOG"; exit 0; fi
fi
trap 'rm -rf "$TRAVA"' EXIT

# .env: exporta as variáveis sem mostrar valores
if [ -f .env ]; then set -a; . ./.env; set +a; else echo "$(date '+%F %T') sem .env" >> "$LOG"; exit 1; fi

{
  echo "════ $(date '+%F %T') · rotina $TIPO $SLOT ════"
  claude -p "$PROMPT" --model haiku \
    --allowedTools "Bash" "Read" "Edit" "Write" "Glob" "Grep"
  COD=$?
  echo "──── fim (código $COD) $(date '+%F %T')"
  if [ "$COD" -ne 0 ] && [ -d .venv ]; then
    .venv/bin/python -m wastatus alerta "Rotina $TIPO $SLOT falhou no computador local (código $COD). Veja $LOG." || true
  fi
  # histórico local (git sem servidor; não precisa de conta)
  if [ -d .git ]; then git add state/ >/dev/null 2>&1 && git commit -qm "rotina $TIPO $SLOT $(date +%F)" >/dev/null 2>&1 || true; fi
} >> "$LOG" 2>&1
