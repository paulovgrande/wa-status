# Plano de implementação

Leia **inteiro** `docs/SPEC.md` antes da Tarefa 1. Todo comando aceita `--produto`, todo conteúdo fica em `produtos/<id>/…` e todo estado em `state/<id>/…`. Faça as tarefas **em ordem**, uma por vez. Ao terminar cada uma, rode os testes indicados e só avance se passarem. Dúvida que a SPEC não resolve vai para `docs/PENDENCIAS.md`. Não invente comportamento.

Regras gerais
- Python 3.11+, sem frameworks além de `requirements.txt`.
- Funções pequenas, com nomes em português iguais aos da SPEC.
- Nenhum `print` de segredo. `config.py` expõe `api_key()` e nada mais da chave.
- Todo acesso de rede passa por `waha.py`, para os testes poderem mockar.
- Datas sempre com fuso `America/Sao_Paulo` (`zoneinfo`).
- Os testes usam o produto fictício `produtos/exemplo/` e `examples/lote-exemplo.json`. Nunca use dados do produto real do usuário em teste.

---

### Tarefa 1: Esqueleto e configuração
Criar `wastatus/__init__.py`, `__main__.py` (argparse com todos os comandos da SPEC 9.1, cada um ainda levantando `NotImplementedError`), `config.py` (`carregar()` global, `produto(id)` e `produtos_ativos()`) e `setup.sh`.
`setup.sh`: cria `.venv` se não existir, instala `requirements.txt`, roda `python -m playwright install --with-deps chromium` (se `--with-deps` falhar sem root, tenta sem a flag), confere o `ffmpeg` (instala com `apt-get install -y ffmpeg` se faltar e houver permissão; no macOS orienta `brew install ffmpeg`) e roda `python scripts/baixar_musicas.py`. Idempotente.
**Aceite:** `python -m wastatus --help` lista todos os comandos; `config.carregar()` falha com mensagem clara se faltar `WAHA_BASE_URL` ou `WHATSAPP_API_KEY`; `config.produto('exemplo')` falha com mensagem clara se faltar `EXEMPLO_WAHA_SESSION`; `produtos_ativos()` ignora ids sem pasta e avisa.

### Tarefa 2: Lote e schema
`lote.py`: `carregar(produto, semana)`, `salvar(lote)` (valida contra o schema antes de gravar), `peca(lote, codigo)`, `semana_proxima(hoje)`, `semana_de(data)`.
**Aceite:** `examples/lote-exemplo.json` carrega e salva sem erro; um lote com `headline` de 71 caracteres é rejeitado.

### Tarefa 3: Validadores de texto (T01 a T09)
`validators.py` com a normalização da SPEC (T05) **numa única função** `normalizar_dc()` usada em todo lugar.
**Aceite:** `tests/test_validators.py` cobre cada código com 1 caso que passa e 1 que falha; as 5 peças de `examples/lote-exemplo.json` passam em todos os validadores de texto contra o DC de `produtos/exemplo/`.

### Tarefa 4: Conteúdo local (`sync`) e comando `produtos`
`conteudo.py` (SPEC 5.2 e 9): verifica DC, logo e fotos; processa o logo em `cache/<id>/logo.png`; grava `state/<id>/manifest.json`. `produtos` lista cada produto e o que falta.
**Aceite:** `python -m wastatus sync --produto exemplo` → ok (1 DC, 1 logo, 0 fotos); um produto sem DC é bloqueado com a mensagem "falta dc/documento-chave.md"; rodar 2 vezes não reprocessa o que não mudou.

### Tarefa 5: Fotos
`photos.py`: recorte quadrado da SPEC + `fotos-preview`.
**Aceite:** `tests/test_photos.py` gera no próprio teste uma foto retrato 3000×4000 com tag EXIF de rotação e uma área protegida; o recorte contém 100% da área protegida, `escala ≤ 1.15`, sai 1080×1080 e na orientação correta.

### Tarefa 6: Planner
`planner.py` (`plan`), conforme a SPEC 6.5.
**Aceite:** `tests/test_planner.py` simula 4 semanas seguidas com 6 fotos fictícias: no máximo 1 foto por dia e nenhuma foto repetida em 7 dias.

### Tarefa 7: Render e validadores de imagem (I01 a I07, I09)
`render.py` + validadores de imagem. Contraste WCAG medido no JPEG (luminância relativa sRGB). Logo: luminância média dos pixels do logo (máscara alfa) contra um anel de 24 px ao redor da caixa.
**Aceite:** `tests/test_render.py` renderiza as 5 peças de `examples/lote-exemplo.json` com a marca de `produtos/exemplo/` e todas passam; o resultado é visualmente equivalente a `examples/render/*.jpg`.

### Tarefa 7b: Vídeo com trilha (SPEC 15)
`video.py` + validador I10 + campo `musica` no lote/schema.
**Aceite:** `tests/test_video.py` gera o MP4 de SEG1 a partir de `examples/render/SEG1.jpg` e passa no I10 (se nenhuma música estiver baixada, o teste gera 15 s de tom com ffmpeg); o rodízio nunca repete a faixa em slots seguidos numa semana simulada.

### Tarefa 8: Cliente WAHA
`waha.py` com os métodos da SPEC 9.2, header `X-Api-Key`, timeout de 30 s e 1 retry em 5xx/timeout. **Nunca** logar headers.
**Aceite:** `tests/test_waha.py` com `httpx.MockTransport` confere os corpos JSON exatos de `post_status_image` e `post_status_video` (com e sem `contacts`) e de `send_image`.

### Tarefa 9: `setup-check`, `brand-preview`, `alerta`
**Aceite (manual, com o WAHA real do usuário):** `setup-check --produto <id>` imprime status da sessão, engine, número que publica e chatId do aprovador, falha se aprovador == número que publica, e grava `engine` e `numero_publicador` no `produto.yaml`.

### Tarefa 10: Prévia e respostas
`approvals.py`: `preview`, `respostas` (gramática da SPEC 8.2), `resumo-dia`.
**Aceite:** `tests/test_respostas.py` cobre todos os comandos, acentos e minúsculas ("não ter3"), linhas inválidas, ordem de timestamp e idempotência.

### Tarefa 11: Publicar
`publisher.py` com as 8 regras da SPEC 6.4, na ordem, jitter, `--teste` e `publicacoes.jsonl`.
**Aceite:** `tests/test_publicar.py` tem 1 teste por regra (WAHA mockado), mais o de idempotência (rodar 2 vezes publica 1 vez).

### Tarefa 12: Fluxo ponta a ponta em modo teste (produto real do usuário)
Com `WASTATUS_TESTE=1`: `sync` → `plan --semana <atual>` → copy de 4 peças (só hoje) → `validate` → `render` → `validate --fase imagem` → `video` → `preview` → o usuário responde "OK" no celular → `respostas` → `publicar --slot N --teste`.
**Aceite:** o status chega **apenas** ao aparelho do aprovador e `publicacoes.jsonl` registra o `waha_message_id`. Se o engine for WEBJS, ver `docs/INSTALACAO.md`, passo D4.

### Tarefa 12b: Isolamento entre produtos
**Aceite:** `tests/test_multiproduto.py` (2 produtos fictícios em `tests/fixtures/produtos/`) prova que nenhum produto usa foto, tema, DC, sessão ou aprovador do outro.

### Tarefa 13: Documentar
Atualizar o `README.md` (comandos reais) e fixar as versões em `requirements.txt`.
