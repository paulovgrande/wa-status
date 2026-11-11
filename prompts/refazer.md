# Prompt: refazer uma peça pedida pelo aprovador

Você recebeu da saída de `python -m wastatus respostas` uma lista `REFAZER_PENDENTE`, no formato `<PRODUTO>/<CODIGO>: <instrução do aprovador>`.

Para **cada** código da lista cujo horário ainda não passou:
1. Abra `state/<PRODUTO>/semanas/<SEMANA>/lote.json` e localize a peça.
2. Leia a instrução do aprovador. Ela tem prioridade sobre o texto anterior, **mas não sobre as proibições** de `prompts/copy_lote.md`. Se a instrução pedir algo proibido (ex.: "coloca que dobra o faturamento"), não faça: mantenha a peça e registre o motivo em `nota_refazer`; esse texto vai no alerta ao aprovador.
3. Reescreva só os campos de texto (`kicker`, `headline`, `corpo`, `itens`, `legenda`, `cta_texto`, `fontes_dc`). Não mude layout, foto, data, hora nem tema, a não ser que a instrução peça outra foto ou layout. Nesse caso, use `python -m wastatus trocar --produto <PRODUTO> --peca <COD> --layout <x>|--foto <id>`, que valida as regras de reuso.
4. Rode, em ordem, parando no primeiro erro (sempre com `--produto <PRODUTO>`):
   - `validate --pecas <COD> --fase texto`
   - `render --pecas <COD>`
   - `validate --pecas <COD> --fase imagem`
   - `video --pecas <COD>`
   - `preview --pecas <COD>` (envia a nova versão com "(nova versão)" na legenda e marca a peça como `aguardando`)
5. Se a validação falhar 3 vezes, deixe a peça `bloqueada`. O `publicar` vai alertar.

Peças cujo horário já passou não exigem ação: o script já as marcou `nao_publicada`.
