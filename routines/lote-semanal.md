# Rotina: Lote semanal (domingo 19:00 BRT · cron `0 22 * * 0` UTC · modelo Haiku)

Modo nuvem: cole como prompt da rotina **apenas** a linha abaixo. Modo local: o `scripts/run-rotina.sh lote` já faz isso.

> Execute as instruções de `routines/lote-semanal.md`.

---

Você opera o sistema WA Status. Execute os passos 3 a 10 **para cada produto ativo** (`python -m wastatus produtos` lista), sempre com `--produto <id>`; se um produto falhar, envie o alerta dele e siga para o próximo. Siga os passos em ordem e **pare no primeiro erro que não souber resolver**: envie o alerta (passo 0) e encerre.

0. **Alerta de falha.** Em qualquer erro fatal, rode
   `python -m wastatus alerta --produto <id> "Lote semanal falhou: <resumo do erro em 1 linha>"`
   e encerre. Nunca inclua a API key ou o conteúdo do `.env` no alerta, em commit ou na saída.
1. `bash setup.sh` (idempotente).
2. `git pull --rebase` (**modo local:** pule este passo)
3. `python -m wastatus sync --produto <id>`
4. `python -m wastatus plan --produto <id> --semana PROXIMA`. Anote a semana impressa (ex.: `2026-W47`).
   Se o lote dessa semana já existir com peças `aguardando` ou `aprovada`, **não refaça**: pule para o passo 10.
5. Leia e siga `prompts/copy_lote.md` (com `PRODUTO=<id>`) para preencher as 28 peças.
6. `python -m wastatus validate --produto <id> --semana <W> --fase texto` (corrigir conforme o prompt; máximo 3 tentativas por peça).
7. `python -m wastatus render --produto <id> --semana <W>`
8. `python -m wastatus validate --produto <id> --semana <W> --fase imagem`. Se falhar por estouro de texto (I03), encurte o texto da peça e repita os passos 6 a 8 só para ela (1 vez).
9. `python -m wastatus video --produto <id> --semana <W>`
10. `python -m wastatus preview --produto <id> --semana <W>`
11. `git add state/ && git commit -m "lote <W>: copy, render e prévia" && git push` (**modo local:** sem `git push`)
12. Responda com um resumo de 5 linhas **por produto**: semana, peças prontas, peças bloqueadas (códigos e motivos), hora do envio da prévia, avisos do `sync` (ex.: DC alterado).
