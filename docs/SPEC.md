# SPEC — WA Status

> Especificação de execução, escrita para ser implementada **e** operada pelo Claude (o plano foi pensado para o modelo Haiku).
> Regra de ouro para quem implementa: **não decida nada que esta spec não decidiu.** Se algo estiver ambíguo, pare e registre em `docs/PENDENCIAS.md`. Não improvise.

---

## 1. Objetivo

Publicar **4 status por dia, por produto**, no WhatsApp do número conectado a uma sessão do **WAHA**. Cada status é um **vídeo de 15 s**: uma arte 1080×1920 com jazz instrumental de fundo. O objetivo é gerar autoridade e engajamento e levar o público a uma conversa no WhatsApp.

Um **produto** é uma oferta com seu próprio número de WhatsApp, aprovador, marca, Documento-Chave (DC), fotos e temas. O sistema publica um ou mais produtos; tudo de um produto fica em `produtos/<id>/`.

### Fora do escopo
- Responder automaticamente quem responde aos status (o atendimento continua humano).
- Depoimentos, prints e números de clientes (exigem autorização por escrito; ver seção 7.4).
- Imagens geradas por IA: nenhuma pessoa ou rosto é gerado. Só fotos reais e autorizadas do dono.

---

## 2. Decisões de projeto (não reabrir)

| Tema | Decisão |
|---|---|
| WhatsApp | Via **WAHA** (API HTTP para WhatsApp), header `X-Api-Key`. Endereço, chave e sessões vêm do `.env`. |
| Onde roda | Rotinas agendadas do Claude Code na nuvem, sobre um repositório Git **privado** do usuário. |
| Geração | Templates HTML 1080×1920 renderizados por Chromium (Playwright). O texto é escrito pelo agente, a partir do DC. |
| Formato | Vídeo MP4 de 15 s (arte estática + trilha). Volta a JPEG se `video.ativo: false`. |
| Mix diário | 07:30 **Autoridade** · 12:00 **Dor** · 17:30 **Prova/Bastidor** · 20:30 **CTA** (padrão; cada produto pode mudar no `produto.yaml`). |
| Lote | Semanal: domingo às 19:00, gerando as 28 peças de segunda a domingo da semana seguinte, por produto. |
| Aprovação | Prévias enviadas por WhatsApp ao aprovador do produto. **Sem resposta = publica**, desde que a peça tenha passado em 100% dos validadores. |
| Validador falhou | **Bloqueia sempre**, mesmo sem resposta humana. |
| Fotos | Mesma foto proibida em dias consecutivos; reuso mínimo de 7 dias. |
| Fonte da verdade | O DC do produto. Nada que não esteja no DC vai ao ar. |
| Fuso | `America/Sao_Paulo` (horários em BRT). |

---

## 3. Arquitetura

```
┌──────────────── Repositório Git PRIVADO do usuário (clonado pela rotina) ──────────────────┐
│ produtos/<id>/  (DC, marca, fotos, temas, CTA — arquivos locais)                            │
│ config/  prompts/  templates/  wastatus/ (código Python)                                    │
│ cache/   (logo processado etc. — NÃO versionado)                                            │
│ state/<id>/ (lotes, peças, aprovações, log de publicações — VERSIONADO)                     │
└───────┬───────────────────────────────────────────────────────────────┬─────────────────────┘
        │ Rotina "Lote semanal" (dom 19:00)                             │ Rotinas "Slot" (4×/dia)
        │ sync → plan → agente escreve copy → validate                  │ respostas → (refazer?) →
        │ → render → validate → video → preview → commit/push           │ publicar → commit/push
        ▼                                                               ▼
                  WAHA  ($WAHA_BASE_URL, sessão $<PREFIXO>_WAHA_SESSION)
                  ├─ POST /api/sendImage                → prévias para o aprovador
                  ├─ GET  /api/{s}/chats/{id}/messages  → lê as respostas de aprovação
                  └─ POST /api/{s}/status/video         → publica o status
```

**Divisão de trabalho:**
- O **agente** só escreve texto. A copy vai para os campos de `lote.json`.
- **Scripts Python determinísticos** fazem todo o resto: planejamento, validação, renderização, vídeo, envio, leitura de respostas, publicação e registro.
- Nenhum script chama a API da Anthropic. A "IA" é o próprio agente da rotina.

---

## 4. Estrutura do repositório

```
wa-status/
├── README.md · COMECE-AQUI.md · CLAUDE.md · LICENSE.md
├── .env.example                 # nomes das variáveis (o .env real nunca é versionado)
├── requirements.txt             # versões fixadas (seção 12)
├── setup.sh                     # instala deps + chromium + ffmpeg + músicas (idempotente)
├── config/
│   ├── settings.yaml            # global: limites, área segura, vídeo, layouts
│   ├── musicas.json             # trilhas Mixkit (status: proposto|aprovado)
│   └── termos_proibidos.txt     # regex globais, um por linha
├── produtos/
│   ├── _modelo/                 # copiado para criar um produto novo
│   ├── exemplo/                 # produto FICTÍCIO usado nos testes
│   └── <id>/
│       ├── produto.yaml         # nome, prefixo do .env, voz, público, slots, regras
│       ├── dc/documento-chave.md
│       ├── marca/logo-principal.png
│       ├── fotos/*.jpg
│       ├── brand.json           # paleta, fontes, logo, assinatura (proposto|aprovado)
│       ├── photos.json          # fotos + área protegida (proposto|aprovado)
│       ├── cta.json             # destino do CTA (proposto|aprovado)
│       ├── temas.yaml           # banco de temas por pilar, ancorados no DC
│       └── termos_proibidos.txt # regex extras deste produto
├── prompts/ (copy_lote.md, refazer.md)
├── templates/ (base.html, layouts/*.html, liquid-glass.css)
├── assets/fonts/                # Inter e Libre Baskerville (OFL)
├── assets/musica/               # baixadas pelo setup (não versionadas)
├── routines/ (lote-semanal.md, slot.md)
├── schema/lote.schema.json
├── examples/ (lote-exemplo.json, render/, liquid-glass/)
├── scripts/baixar_musicas.py
├── wastatus/                    # pacote Python (seção 9) — criado na implementação
├── tests/                       # pytest (seção 11) — criado na implementação
└── state/
    └── <id>/
        ├── PAUSADO              # arquivo-flag; se existir, nada publica
        ├── manifest.json        # sha256 do DC, logo e fotos
        ├── fotos_uso.json · temas_cursor.json
        ├── publicacoes.jsonl    # 1 linha por tentativa de publicação
        └── semanas/2026-W47/
            ├── lote.json        # 28 peças (fonte da verdade da semana)
            ├── aprovacoes.json
            ├── pecas/SEG1.jpg …
            └── video/SEG1.mp4 …
```

---

## 5. Produtos

### 5.1 Configuração
- **Produto ativo** = está em `PRODUTOS_ATIVOS` (no `.env`) **e** tem `produto.yaml → ativo: true`. Produto inativo não planeja, não envia prévia, não publica.
- `produto.yaml → env_prefixo` define as variáveis do produto: `<PREFIXO>_WAHA_SESSION` (sessão do número que publica) e `<PREFIXO>_APPROVER_CHAT_ID` (WhatsApp de quem aprova).
- Produto novo: copiar `produtos/_modelo/` para `produtos/<novo>/`, preencher e incluir o id em `PRODUTOS_ATIVOS`.
- `produtos/exemplo/` é fictício e serve aos testes. Nunca é ativado.

### 5.2 Regras
- **Comandos:** todos aceitam `--produto <id>`. Sem o parâmetro, rodam para **todos os ativos**, em sequência; a falha de um produto não interrompe os demais (cada um gera seu alerta).
- **Isolamento:** um produto nunca usa DC, fotos, temas, marca, sessão ou aprovador de outro. O validador T05 usa só o DC do próprio produto.
- **Códigos das peças:** com o prefixo do produto nas prévias e no resumo (`CONSULTORIA-SEG1`). Nas respostas, o prefixo é opcional: cada produto lê as respostas **na sua sessão**.
- **Prévia e alertas** saem pela sessão do próprio produto para o aprovador dele.
- **Aprovador ≠ número que publica** (a resposta não seria lida). O `setup-check` falha se forem iguais.
- **Conteúdo local:** o comando `sync` verifica a pasta do produto: o DC existe e não está vazio, o logo existe, cada foto de `photos.json` existe. Grava `state/<id>/manifest.json` com sha256 e avisa se o DC mudou desde o último lote. A falta de DC ou logo bloqueia **só aquele produto**.
- **Referências não são DC:** arquivos `dc/REFERENCIA-*` nunca alimentam T04/T05.
- **Música:** `produto.yaml → musicas` = `todas_aprovadas` ou lista de ids de `config/musicas.json`. O rodízio é por produto.
- **Publicidade regulada** (`regras_publicidade: oab_205_2021`, advocacia): tom informativo, sem captação nem mercantilização, sem preço ou honorários, sem promessa de resultado, sem comparação, sem urgência, sem emojis, **sigilo absoluto** (nenhum caso concreto, cliente ou processo). No pilar `prova`, só `processo`, `bastidor` e `aprendizado` genérico. O prompt de copy recebe o bloco "Regras OAB".
- **Rotinas:** são 5 (lote semanal + 4 horários). Cada execução percorre os produtos ativos que têm slot naquele horário. Se um produto usar um horário que nenhuma rotina cobre, o `setup-check` avisa qual rotina criar.

---

## 6. Calendário e fluxos

### 6.1 Códigos e slots
- Semana ISO (`2026-W47`): segunda a domingo.
- **Código da peça** = dia em 3 letras sem acento + número do slot: `SEG1 … DOM4`. É o código que o aprovador digita.

| Slot | Hora BRT | Cron UTC | Pilar | Objetivo |
|---|---|---|---|---|
| 1 | 07:30 | `30 10 * * *` | `autoridade` | Ensinar uma ideia do DC |
| 2 | 12:00 | `0 15 * * *` | `dor` | Nomear uma dor do público com precisão, sem vender |
| 3 | 17:30 | `30 20 * * *` | `prova` | Bastidor, processo, aprendizado ou demonstração |
| 4 | 20:30 | `30 23 * * *` | `cta` | Convidar para uma conversa |

Lote semanal: domingo 19:00 BRT = `0 22 * * 0` UTC.

**Jitter:** antes de publicar, o script espera um tempo aleatório entre 0 e `jitter_max_min` minutos (padrão 7). Horários exatos todo dia parecem automação.

### 6.2 Rotina "Lote semanal" (domingo 19:00), por produto
1. `sync --produto <id>`.
2. `plan --produto <id> --semana PROXIMA`: cria `lote.json` com os 28 slots já preenchidos com `codigo`, `data`, `hora`, `pilar`, `layout`, `foto` (ou `null`) e `tema_id`. Os campos de texto ficam vazios. A escolha é determinística (6.5).
3. **Agente:** segue `prompts/copy_lote.md` e preenche os campos de texto.
4. `validate --fase texto`: quando uma peça falha, o agente corrige **só aquela peça**. Limite de 3 tentativas por peça; depois a peça fica `bloqueada` com o motivo.
5. `render`: gera `pecas/<COD>.jpg` e `pecas/<COD>.meta.json` com as caixas dos elementos.
6. `validate --fase imagem`. Peça reprovada fica `bloqueada`; o agente pode refazer uma vez se o problema for de texto (ex.: overflow).
7. `video`: gera os MP4 (seção 15).
8. `preview`: envia a prévia ao aprovador (8.1).
9. `git add state/ && git commit && git push`.

### 6.3 Rotinas "Slot" (4×/dia)
1. `git pull --rebase`.
2. `respostas`: lê as mensagens do aprovador, atualiza `aprovacoes.json` e o `status` das peças (8.2), e imprime a lista `REFAZER_PENDENTE`.
3. Se houver `REFAZER_PENDENTE` para peças **futuras**, o agente segue `prompts/refazer.md`.
4. `publicar --slot <N>`: aplica a regra 6.4 e publica (ou não).
5. Commit e push de `state/`.
6. Se for o slot 4: `resumo-dia` envia ao aprovador o resumo do dia.

### 6.4 Regra de decisão de publicação (`publicar`)
Avaliar em ordem. **A primeira regra que se aplica decide.**
1. `state/<id>/PAUSADO` existe → **não publica**, registra `pausado`.
2. Já existe linha em `publicacoes.jsonl` com o mesmo `codigo` e `resultado: "publicado"` → **não publica** (idempotência).
3. A peça não existe ou `status ∈ {bloqueada, reprovada}` → **não publica** e alerta o aprovador com o motivo.
4. `status == "refazer_pendente"` → **não publica** e alerta.
5. A peça foi reenviada (nova versão) há menos de `min_janela_nova_versao_min` minutos (padrão 90) e sem `OK` explícito → **não publica** e alerta.
6. Revalidação completa (texto + imagem + `sha256` do JPEG igual ao da prévia) falhou → **não publica** e alerta.
7. Sessão WAHA não está `WORKING` → **não publica**, alerta e registra `erro_sessao`.
8. Caso contrário (`aprovada` **ou** `aguardando` sem resposta) → **publica**.

Depois do POST, grava em `publicacoes.jsonl`: `{codigo, semana, ts, resultado, waha_message_id|null, http_status, erro|null, sha256}`. Em erro HTTP, tenta 1 vez após 60 s; se falhar de novo, alerta.

### 6.5 Planejamento determinístico (`plan`)
- **Layout por pilar** (rodízio, `settings.yaml → layouts_por_pilar`):
  - autoridade → `tipografico_escuro`, `lista`, `foto_topo`
  - dor → `tipografico_escuro`, `tipografico_claro`
  - prova → `foto_topo`, `lista`, `tipografico_claro`
  - cta → `cta`
- `foto_topo` só é escolhido quando há foto **elegível**: `photos.json` aprovado, foto não usada nos 7 dias anteriores (considerando `fotos_uso.json` **e** as peças já planejadas) e não usada no dia anterior. Sem foto elegível, o layout cai para o próximo do rodízio sem foto.
- No máximo **1 peça com foto por dia**.
- **Tema:** o próximo tema do pilar em rodízio, com o último índice usado em `state/<id>/temas_cursor.json`.

---

## 7. Conteúdo

### 7.1 Campos de copy por peça (preenchidos pelo agente)
| Campo | Limite | Observação |
|---|---|---|
| `kicker` | ≤ 28 caracteres | Rótulo pequeno em caixa alta |
| `headline` | ≤ 70 caracteres | Frase principal. Sem ponto de exclamação. |
| `corpo` | ≤ 180 caracteres | 1 a 3 frases. Obrigatório em `tipografico_escuro`, `tipografico_claro` e `cta`. **Vazio** em `lista` e `foto_topo` (o desenvolvimento vai na `legenda`). |
| `itens` | 3 itens de ≤ 48 caracteres | Só no layout `lista`. |
| `legenda` | ≤ 300 caracteres | Caption do status. Emojis: até `produto.yaml → emojis_legenda_max`. |
| `cta_texto` | ≤ 90 caracteres | Obrigatório no pilar `cta`. Opcional nos outros. |
| `fontes_dc` | 1 a 3 trechos **literais** do DC | Base de cada afirmação. Mínimo de 12 caracteres por trecho. |
| `tipo_prova` | `bastidor` \| `processo` \| `aprendizado` \| `demonstracao` | Obrigatório no pilar `prova`. |

### 7.2 Voz
Vem do `produto.yaml`: `autor` (primeira pessoa), `publico`, `voz`, `vocabulario` e `nome_da_oferta`. Regras fixas: frases curtas, uma ideia por peça, conversa e não anúncio, nenhum emoji na arte.

### 7.3 Proibições (validadas por máquina **e** declaradas no prompt)
1. Prometer resultado ou retorno financeiro.
2. Criar números. **Todo número** na copy precisa existir no texto do DC.
3. Inventar depoimentos, nomes de clientes, casos ou métricas.
4. Expor dados de clientes.
5. Citar concorrentes ou falar mal de ferramentas específicas.
6. Claims absolutos: "melhor", "único", "infalível", "sem risco", "100%", "definitivo", "revolucionário".
7. Características ou benefícios ausentes do DC.
8. Os padrões de `config/termos_proibidos.txt` e de `produtos/<id>/termos_proibidos.txt`.

### 7.4 Pilar Prova sem depoimentos
O pilar `prova` usa apenas:
- `bastidor`: como a operação do próprio autor funciona;
- `processo`: um passo do método explicado;
- `aprendizado`: um erro comum observado e a lição, sem identificar ninguém;
- `demonstracao`: "antes → depois" **conceitual**, sem números que não estejam no DC.

Depoimentos só com autorização escrita de cada pessoa, guardada fora do repositório e referenciada na peça (`autorizacao_ref`).

### 7.5 CTA (pilar `cta`)
O comportamento depende de `produtos/<id>/cta.json`:
- `modo: "responder_status"` (**padrão**): a peça convida a **responder este status** com a `palavra_chave` (ex.: "Responda este status com DIAGNÓSTICO"). Responder a um status abre conversa com o número que publicou, então nenhum número é presumido.
- `modo: "whatsapp"`: exige `numero_e164` e `status: "aprovado"`. O script monta `https://wa.me/<numero>?text=<urlencode(mensagem)>` e coloca na legenda.
- `modo: "formulario"`: exige `url` e `status: "aprovado"`. A arte usa `cta_texto` = `formulario.cta_texto_padrao`; o **script** acrescenta a URL numa linha própria ao fim da legenda. Antes de publicar, o validador confere se a URL responde HTTP 200.
- Com `status != "aprovado"` nos modos `whatsapp` ou `formulario`, a peça CTA fica **bloqueada**. **O agente nunca escreve número nem URL.**

---

## 8. Aprovação via WhatsApp

### 8.1 Envio da prévia (`preview`)
Destino: `<PREFIXO>_APPROVER_CHAT_ID` (confirmado com `check-exists` no setup).

Ordem das mensagens (intervalo aleatório de 20 a 45 s entre elas, com "digitando" antes de cada uma):
1. Texto de abertura:
   ```
   📋 <PRODUTO> · Lote <W> (<seg dd/mm> a <dom dd/mm>) — 28 status
   Bloqueadas pelo filtro: <n> (<códigos>)
   Como responder (uma linha por comando):
   OK  → aprova tudo
   OK SEG1  → aprova uma
   NAO TER3  → não publicar
   REFAZER QUA2 <o que mudar>  → reescrever
   PAUSAR / RETOMAR  → suspende ou retoma tudo
   Sem resposta = publica no horário (só peças aprovadas no filtro).
   ```
2. Uma imagem por peça **não bloqueada** (`POST /api/sendImage`). Caption: `<COD> · <dia dd/mm> <hh:mm> · <pilar> · 🎵 <faixa>\n\n<legenda>`.
3. Texto de fechamento com as peças bloqueadas e seus motivos.

Para cada peça enviada, grava `preview_enviado_em`, `preview_sha256` e `preview_message_id`.

### 8.2 Leitura de respostas (`respostas`)
- `GET /api/{session}/chats/{APPROVER}/messages?limit=100&downloadMedia=false&filter.fromMe=false&filter.timestamp.gte=<ts da prévia mais antiga em aberto>`
- Normalizar cada linha: maiúsculas, sem acentos, espaços colapsados.
- Gramática (uma por linha):
  - `^OK$` ou `^OK TUDO$` → todas as peças `aguardando` da semana passam a `aprovada`
  - `^OK ((SEG|TER|QUA|QUI|SEX|SAB|DOM)[1-4])$` → `aprovada`
  - `^NAO ((SEG|…|DOM)[1-4])$` → `reprovada`
  - `^REFAZER ((SEG|…|DOM)[1-4]) (.+)$` → `refazer_pendente`, com `instrucao_refazer`
  - `^PAUSAR$` → cria `state/<id>/PAUSADO`; `^RETOMAR$` → remove
  - Linha não reconhecida → ignorar e registrar em `aprovacoes.json.ignoradas`
- Resposta citando uma prévia (reply) com só `OK`, `NAO` ou `REFAZER <instr>` usa o código da prévia citada, se `replyTo` trouxer o id. **Verificar o formato real de `replyTo` no setup.**
- A última decisão sobre um mesmo código vale. Processar em ordem de `timestamp`. Idempotente: guardar `ultimo_ts_processado`.

### 8.3 Estados da peça
`rascunho → validada → renderizada → aguardando → (aprovada | reprovada | refazer_pendente → aguardando) → publicada | nao_publicada`. `bloqueada` pode acontecer em qualquer fase de validação.

---

## 9. Pacote `wastatus` (Python 3.11+)

CLI única: `python -m wastatus <comando> [opções]`. Cada comando imprime um resumo legível e termina com código `0` (ok) ou `≠0` (erro). **Nenhum comando imprime a API key.**

| Módulo | Responsabilidade |
|---|---|
| `config.py` | Carrega `.env`/ambiente, `config/` e `produtos/<id>/produto.yaml`. `produto(id)` resolve as variáveis do prefixo; `produtos_ativos()` lê `PRODUTOS_ATIVOS`. Falha cedo, com mensagem clara. |
| `conteudo.py` | `sync` (5.2). Processa o logo: converte para PNG RGBA e recorta as margens transparentes pela bbox do canal alfa com **limiar > 40** (ignora ruído de alfa). Grava em `cache/<id>/logo.png`. |
| `planner.py` | `plan` (6.5). |
| `lote.py` | Ler/gravar `lote.json`, validando contra `schema/lote.schema.json`. |
| `validators.py` | Todos os validadores (seção 10). Cada um retorna `(ok, codigo_erro, detalhe)`. |
| `photos.py` | `ImageOps.exif_transpose` **obrigatório**. Recorte quadrado: lado = `min(largura, altura)`, centralizado na área protegida e limitado às bordas; se a área protegida não couber, a foto não é elegível (`I04`). Redimensionar com LANCZOS para 1080, gravar `escala` e `recorte`. Nunca distorcer. Comando `fotos-preview`: folha de contato com a área protegida em vermelho. |
| `render.py` | Jinja2 (`templates/`, `autoescape=True`, `layouts/<layout>.html`) + Playwright Chromium, viewport 1080×1920, `device_scale_factor=1`. Variáveis: `asset_base`, `brand`, `p`, `layout`, `logo_src`, `foto_src`. Espera `document.fonts.ready`. Captura PNG e converte para JPEG (qualidade 88–92, ≤ 900 KB). Coleta `getBoundingClientRect()` de cada `data-box` e `scrollHeight`/`clientHeight` de cada `data-fit` para o `.meta.json`. Variante opcional liquid glass: `docs/GUIA-VISUAL.md`. |
| `video.py` | Comando `video` (seção 15). |
| `waha.py` | Cliente HTTP (`httpx`, timeout 30 s, 1 retry em 5xx/timeout). Métodos: `session_status()`, `me()`, `check_exists()`, `send_text()`, `send_image()`, `start_typing()/stop_typing()`, `messages()`, `post_status_image()`, `post_status_video()`. **Nunca** loga headers. |
| `approvals.py` | `preview`, `respostas`, `resumo-dia`. |
| `publisher.py` | `publicar` (6.4). |
| `__main__.py` | argparse. |

### 9.1 Comandos
`produtos` (lista os produtos, se estão ativos e o que falta) · `sync` · `plan --semana PROXIMA|<W>` · `validate --semana <W>|--pecas <C,...> --fase texto|imagem` · `render` · `video` · `preview` · `respostas` · `publicar --slot <1-4> [--teste]` · `resumo-dia` · `alerta "<texto>"` · `trocar --peca <C> --layout <x>|--foto <id>` · `fotos-preview` · `brand-preview` (uma arte de amostra por layout + logo e paleta, enviada ao aprovador) · `setup-check` (sessão, engine, `/me`, `check-exists` do aprovador; grava `engine` e `numero_publicador` no `produto.yaml`).

Todos aceitam `--produto <id>`. Em `--pecas`, o código é resolvido na semana corrente ou próxima que o contém com status não final.

### 9.2 Chamadas WAHA (contrato)
Header em todas: `X-Api-Key: $WHATSAPP_API_KEY`, `Content-Type: application/json`.

| Uso | Método e caminho | Corpo |
|---|---|---|
| Status da sessão | `GET /api/sessions/{s}` | — (esperar `status == "WORKING"`; ler `engine`) |
| Conta da sessão | `GET /api/sessions/{s}/me` | — (`id` = número que publica) |
| Verificar número | `GET /api/contacts/check-exists?phone=<n>&session={s}` | — (usar o `chatId` retornado) |
| Prévia | `POST /api/sendImage` | `{"session":s,"chatId":c,"file":{"mimetype":"image/jpeg","filename":"SEG1.jpg","data":"<b64>"},"caption":"…"}` |
| Texto | `POST /api/sendText` | `{"session":s,"chatId":c,"text":"…"}` |
| Ler respostas | `GET /api/{s}/chats/{c}/messages?…` | ver 8.2 |
| **Publicar status** | `POST /api/{s}/status/video` (ou `/status/image` se `video.ativo: false`) | `{"file":{"mimetype":"video/mp4","filename":"…","data":"<b64>"},"convert":false,"caption":"…"}` + `contacts` conforme 9.3 |
| Status já enviados | `GET /api/{s}/chats/status@broadcast/messages?limit=10&downloadMedia=false` | — (diagnóstico) |

### 9.3 Campo `contacts` do status (depende do engine)
- **WEBJS:** não aceita `contacts`. O status vai para os contatos conforme a privacidade de status configurada **no celular**. Não enviar o campo.
- **NOWEB/GOWS:** aceita `contacts`. Padrão: `status_contacts: null` (omitir o campo). O setup confirma com 1 publicação real conferida em outro aparelho; se a omissão não alcançar os contatos, passa a enviar uma lista explícita gerada de `GET /api/contacts/all` (somente contatos salvos).
- **Modo teste** (`--teste` ou `WASTATUS_TESTE=1`): envia `contacts: [<APPROVER_CHAT_ID>]` (NOWEB/GOWS), para validar o fluxo sem expor a base. Com WEBJS, ver `docs/INSTALACAO.md`.
- **Só vê o status quem tem o número que publica salvo nos contatos.**

---

## 10. Validadores (todos obrigatórios; qualquer falha bloqueia)

### Fase texto
| Código | Regra |
|---|---|
| `T01_CAMPOS` | Campos obrigatórios do pilar/layout presentes e não vazios. |
| `T02_LIMITES` | Limites da seção 7.1. |
| `T03_PROIBIDOS` | Nenhum padrão dos termos proibidos (global + produto) em nenhum campo (sem acento, minúsculas). |
| `T04_NUMEROS` | Todo token numérico (`\d+([.,]\d+)?`, incluindo "R$", "%", "x") existe no texto normalizado do DC. Exceção: os números dos itens de `lista`. |
| `T05_FONTES_DC` | 1 a 3 `fontes_dc`, cada uma presente **literalmente** no DC e com ≥ 12 caracteres. Normalização igual nos dois lados: `“ ”`→`"`, `’`→`'`, `– —`→`-`, espaços em sequência viram um só, `strip()`. Não remover acentos nem mudar caixa. A `dc_ancora` do tema precisa estar entre as fontes. |
| `T06_CTA` | Pilar `cta`: `cta.json` válido e aprovado (ou modo `responder_status`), `cta_texto` presente (com a `palavra_chave` no modo `responder_status`). Nenhuma URL ou telefone escrito pelo agente (regex `https?://`, `wa\.me`, `\+?55\s?\d{2}`). |
| `T07_PROVA` | Pilar `prova`: `tipo_prova` válido. Sem padrões de nome próprio de terceiros (`\bDra?\.\s+[A-Z]`, "meu cliente X"). |
| `T08_DUPLICADO` | `headline` com similaridade < 0,85 (`difflib`) com as headlines das últimas 4 semanas. |
| `T09_EMOJI` | Emojis só na legenda, no máximo `emojis_legenda_max`. |

### Fase imagem
| Código | Regra |
|---|---|
| `I01_ARQUIVO` | JPEG, exatamente 1080×1920, ≤ 900 KB. |
| `I02_AREA_SEGURA` | Toda caixa `data-box` de texto ou logo dentro de `x ∈ [72, 1008]`, `y ∈ [230, 1450]`. O topo fica para a barra de progresso e o nome do perfil; a base, para a **legenda** e o campo de resposta, que cobrem a arte. |
| `I03_OVERFLOW` | Nenhum texto com `scrollHeight > clientHeight`. Fonte mínima: 34 px no corpo, 56 px na headline. |
| `I04_PROTEGIDA` | Em `foto_topo`: a área protegida (rosto + tronco) não intersecta nenhuma caixa de texto ou logo e está 100% visível. |
| `I05_FOTO_QUALIDADE` | Escala ≤ 1,15, proporção preservada, orientação EXIF aplicada. |
| `I06_LOGO` | Logo de `brand.json` e `brand.status == "aprovado"`. |
| `I07_CONTRASTE` | Texto: WCAG ≥ 4,5 contra a cor média do fundo sob a caixa (medida no JPEG). Logo: ≥ 3,0 contra um anel de 24 px ao redor. |
| `I08_HASH` | `sha256` do JPEG igual ao `preview_sha256` (só no `publicar`). |
| `I09_FOTO_REUSO` | Regras de reuso de foto respeitadas na data real. |
| `I10_VIDEO` | Duração 14,5–15,5 s; 1080×1920; tem áudio; ≤ `video.max_kb`; JPEG de origem igual ao aprovado. |

---

## 11. Testes (pytest, obrigatórios antes de agendar as rotinas)
Usam o produto fictício `produtos/exemplo/` e `examples/lote-exemplo.json`.
- `test_validators.py`: 1 caso que passa e 1 que falha **por validador** ("resultado garantido" → T03; "aumente 45% o faturamento" → T04; trecho inexistente no DC → T05; "Dra. Ana" → T07).
- `test_respostas.py`: "ok", "Ok tudo", "não ter3", "REFAZER qua2 mais curto", "pausar", linhas inválidas, ordem de timestamps, idempotência.
- `test_publicar.py`: as 8 regras da 6.4, com `waha.py` mockado.
- `test_planner.py`: 4 semanas seguidas sem violar o reuso de fotos e com no máximo 1 foto por dia (usar fotos fictícias geradas no próprio teste).
- `test_render.py`: renderiza `examples/lote-exemplo.json` e passa em todos os validadores de imagem.
- `test_video.py` e `test_multiproduto.py`: ver `docs/TAREFAS.md`.

---

## 12. Dependências
`requirements.txt` (fixar as versões na implementação): `httpx`, `jinja2`, `playwright`, `pillow`, `pyyaml`, `jsonschema`, `python-dotenv`, `pytest`. Sistema: Python 3.11+, git, ffmpeg.

---

## 13. Variáveis de ambiente
Ver `.env.example`: `WAHA_BASE_URL`, `WHATSAPP_API_KEY`, `PRODUTOS_ATIVOS`, por produto `<PREFIXO>_WAHA_SESSION` e `<PREFIXO>_APPROVER_CHAT_ID`, e `WASTATUS_TESTE`.
- **Local:** no arquivo `.env` na raiz do projeto (`chmod 600`), nunca versionado.
- **Nuvem:** nas variáveis do ambiente da rotina.
- A chave **nunca** vai para o repositório, o prompt da rotina, log, commit ou chat.

---

## 14. Verificações do setup
| # | Verificação | Bloqueia | Como |
|---|---|---|---|
| 1 | Sessão `WORKING`, engine e número que publica | tudo do produto | `setup-check --produto <id>` |
| 2 | Aprovador existe no WhatsApp e é diferente do número que publica | prévias | `check-exists` |
| 3 | Comportamento de `contacts` omitido (NOWEB/GOWS) | publicação real | teste com `--teste` e depois 1 publicação real conferida em outro aparelho |
| 4 | Formato de `replyTo` | só o atalho "responder citando" | enviar 1 prévia, responder citando e inspecionar o JSON |
| 5 | Marca aprovada | **toda publicação** (I06) | `brand-preview` → usuário aprova |
| 6 | Área protegida das fotos | layouts com foto | `fotos-preview` → usuário aprova |
| 7 | CTA aprovado | peças das 20:30 (modos whatsapp/formulario) | usuário confirma `cta.json` |
| 8 | Músicas aprovadas | vídeo | 1 status de teste por faixa, só para o aprovador |

---

## 15. Status em vídeo com trilha de jazz
- **Geração (`video.py`, comando `video`):** depois do `render` e dos validadores de imagem, para cada peça: `ffmpeg -loop 1 -framerate 30 -i <codigo>.jpg -ss <inicio_s> -t 15 -i <faixa>.mp3 -t 15 -af "afade=t=in:d=1,afade=t=out:st=13:d=2,volume=<video.volume>"` + `settings.yaml → video.ffmpeg`. Saída em `video/<codigo>.mp4`. O campo `musica` da peça guarda o `id` da faixa.
- **Trilhas:** só as de `config/musicas.json` com `status: "aprovado"`, baixadas da Mixkit por `scripts/baixar_musicas.py` (licença Mixkit: uso comercial permitido, sem atribuição; **proibido redistribuir a música isolada**, por isso os MP3 não são versionados). Rodízio: a mesma faixa não se repete em 2 slots seguidos. O agente **nunca** baixa música de outra fonte.
- **Publicação:** `POST /api/{s}/status/video` (9.2). Com `video.ativo: false`, volta para `/status/image` com o JPEG.
- **Prévia:** continua sendo a imagem, com "🎵 <faixa>" na legenda.
