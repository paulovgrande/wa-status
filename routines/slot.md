# Rotina: Slot de publicação (4 rotinas, uma por horário · modelo Haiku)

| Rotina | Hora BRT | Cron UTC | Prompt |
|---|---|---|---|
| WA Status · 07:30 | 07:30 | `30 10 * * *` | `Execute routines/slot.md com SLOT=1` |
| WA Status · 12:00 | 12:00 | `0 15 * * *`  | `Execute routines/slot.md com SLOT=2` |
| WA Status · 17:30 | 17:30 | `30 20 * * *` | `Execute routines/slot.md com SLOT=3` |
| WA Status · 20:30 | 20:30 | `30 23 * * *` | `Execute routines/slot.md com SLOT=4` |

---

Você opera o sistema WA Status. O número do slot (`SLOT`) veio no prompt. Os comandos sem `--produto` rodam para **todos os produtos ativos** que têm esse slot (SPEC 5.2); a falha de um produto não para os outros. Siga em ordem.

0. **Alerta de falha.** Em erro fatal: `python -m wastatus alerta "Slot <SLOT> falhou: <resumo em 1 linha>"`, commit/push do que houver em `state/` e encerre. Nunca exponha a API key.
1. `bash setup.sh` (idempotente).
2. `git pull --rebase` (**modo local:** pule este passo)
3. `python -m wastatus respostas`
4. Se a saída listar `REFAZER_PENDENTE` com peças futuras, siga `prompts/refazer.md`.
5. `python -m wastatus publicar --slot <SLOT>`. O script decide se publica (SPEC 6.4). **Você não decide nem força a publicação.** Nunca edite `status` manualmente para "liberar" uma peça.
6. Se `SLOT == 4`: `python -m wastatus resumo-dia`
7. `git add state/ && git commit -m "slot <SLOT> <data>: <resultado>" && git push` (se o push for rejeitado: `git pull --rebase` e push de novo, 1 vez). **Modo local:** só o commit, sem push.
8. Responda com 1 linha **por produto**: código da peça, resultado (`publicado` | `nao_publicado: <motivo>`) e o `waha_message_id`, se houver.
