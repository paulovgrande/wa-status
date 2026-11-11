# Instalação — referência passo a passo

> O jeito recomendado é deixar o Claude conduzir: abra o Claude Code na pasta do projeto e digite `/wa-status-instalacao` (ou cole o link do repositório e peça "instale"). Este documento é a referência que a skill segue.

Legenda: 👤 = você faz · 🤖 = Claude faz · ✅ = como saber que deu certo.

---

## Parte A — Preparação (👤)

### A1. O que você precisa ter
- **Claude Code** (app desktop, extensão do VS Code ou terminal), logado na sua conta.
- **Python 3.11+, git e ffmpeg** no computador. O Claude confere e diz como instalar o que faltar.
- Um servidor **WAHA** acessível pela internet (HTTPS), com chave de API (https://waha.devlike.pro).
- Uma **sessão** do WAHA conectada ao número de WhatsApp que vai **publicar** os status.
- Um **segundo** número de WhatsApp, de quem vai **aprovar** as prévias.
- **Onde vai rodar:** no seu computador (**sem GitHub**; ele precisa ficar ligado nos horários) ou na nuvem do Claude Code (com conta no **GitHub**; roda com o computador desligado). Ver SPEC 16.

### A2. Conteúdo do produto (fica em `produtos/<id>/`)
1. `dc/documento-chave.md`: o Documento-Chave. Veja `produtos/_modelo/dc/LEIA-ME.md` e o exemplo em `produtos/exemplo/`. Sem DC, o Claude faz uma entrevista e escreve um rascunho para você aprovar.
2. `marca/logo-principal.png`: logo com fundo transparente.
3. `fotos/` (opcional): fotos reais suas, autorizadas.
4. O Claude propõe os temas (`temas.yaml`), a marca (`brand.json`) e o CTA (`cta.json`) para você aprovar.

### A3. Onde ficam as conexões: o `.env`
Na pasta do projeto, o arquivo `.env` (criado a partir de `.env.example`) guarda o endereço do WAHA, a chave, a sessão e o número do aprovador. Ele **nunca vai para o git**.
- Preencha a chave **no editor**, nunca no chat.
- `chmod 600 .env` (só o seu usuário lê).
- ✅ `git check-ignore .env` imprime `.env`.

### A4. Teste manual do WAHA (opcional; o Claude faz na instalação)
```bash
set -a; . ./.env; set +a; H="X-Api-Key: $WHATSAPP_API_KEY"
S=<sua sessão>; A=<55DDDNUMERO do aprovador>
curl -s -H "$H" "$WAHA_BASE_URL/api/sessions/$S" | python3 -m json.tool | grep -E '"(status|engine|name)"'
curl -s -H "$H" "$WAHA_BASE_URL/api/sessions/$S/me"
curl -s -H "$H" "$WAHA_BASE_URL/api/contacts/check-exists?phone=$A&session=$S"
```
✅ `"status": "WORKING"`, um `engine` (WEBJS, NOWEB ou GOWS), o número que publica em `/me` e `"numberExists": true` para o aprovador.

### A5. No celular do número que publica
- WhatsApp → **Configurações → Privacidade → Status** → "Meus contatos".
- **Só vê o status quem tem esse número salvo.** Para ampliar o alcance, peça aos seus contatos que salvem o número.

---

## Parte B — Implementação (🤖)
1. Troque o modelo para Haiku (`/model`): o plano foi escrito para ele.
2. O Claude executa `docs/TAREFAS.md` uma tarefa por vez: implementa, roda os testes, mostra o resultado e pergunta se segue.
3. Depois da Tarefa 11: `python -m pytest -q` passa 100%.

✅ `python -m wastatus setup-check --produto <id>` mostra sessão WORKING, engine e número que publica.

---

## Parte C — Só no modo nuvem: repositório privado e ambiente (👤 + 🤖)
1. O Claude cria um repositório **privado** no seu GitHub e envia o projeto (sem o `.env`). Nunca deixe esse repositório público: ele terá seu conteúdo e o histórico de publicações.
2. Em **claude.ai/code**, conecte o GitHub e selecione esse repositório.
3. Crie o **ambiente** (environment) das rotinas:
   - **Variáveis:** as mesmas do seu `.env` (`WAHA_BASE_URL`, `WHATSAPP_API_KEY`, `PRODUTOS_ATIVOS`, `<PREFIXO>_WAHA_SESSION`, `<PREFIXO>_APPROVER_CHAT_ID`, `WASTATUS_TESTE=1`). Digite os valores na tela do ambiente, não no chat.
   - **Rede:** liberar o domínio do seu WAHA, `assets.mixkit.co`, `pypi.org`, `files.pythonhosted.org`, `github.com` e os domínios de download do Chromium do Playwright (se o `setup.sh` falhar nesse passo, o log mostra o domínio bloqueado).
4. **Push:** as rotinas gravam `state/` na branch `main`. Libere o push para `main` nas configurações da rotina/repositório, ou use uma branch fixa `estado` (`git push origin HEAD:estado`) e avise o Claude antes da Tarefa 12.

✅ Uma sessão manual na nuvem com "rode `bash setup.sh && python -m wastatus setup-check`" termina sem erro.

---

## Parte D — Aprovações e teste (👤 + 🤖)
- **D1. Marca:** `brand-preview` envia ao aprovador uma arte por layout. Enquanto `brand.json` estiver `proposto`, nada é publicado (I06).
- **D2. Fotos:** `fotos-preview` envia as fotos com a área protegida em vermelho.
- **D3. CTA:** padrão "Responda este status com <PALAVRA>" (quem responde cai na conversa do número que publica). Alternativas: link de formulário ou outro WhatsApp. Enquanto `cta.json` estiver `proposto` nesses modos, as peças das 20:30 ficam bloqueadas.
- **D4. Teste ponta a ponta** (`WASTATUS_TESTE=1`):
  - **NOWEB/GOWS:** o status vai **só** para o aprovador.
  - **WEBJS:** não dá para restringir pela API. Antes do teste, no celular que publica, ajuste a privacidade de status para **"Somente com…"** e selecione só o aprovador. Volte para "Meus contatos" depois.
  - Responda ao status de teste com a palavra-chave, de outro aparelho, e confira se a mensagem chega no número que publica.

✅ `state/<id>/publicacoes.jsonl` tem uma linha `"resultado": "publicado"` com `waha_message_id`.

---

## Parte E — Rotinas no modo nuvem (👤 via Claude Code)
Use **`/schedule`** e crie **5 rotinas** no seu repositório privado, modelo **Haiku**, com o ambiente da Parte C:

| Nome | Agenda (UTC) | Equivale a (BRT) | Prompt |
|---|---|---|---|
| WA Status · Lote semanal | `0 22 * * 0` | domingo 19:00 | `Execute as instruções de routines/lote-semanal.md` |
| WA Status · 07:30 | `30 10 * * *` | todo dia 07:30 | `Execute routines/slot.md com SLOT=1` |
| WA Status · 12:00 | `0 15 * * *` | todo dia 12:00 | `Execute routines/slot.md com SLOT=2` |
| WA Status · 17:30 | `30 20 * * *` | todo dia 17:30 | `Execute routines/slot.md com SLOT=3` |
| WA Status · 20:30 | `30 23 * * *` | todo dia 20:30 | `Execute routines/slot.md com SLOT=4` |

**Primeiro lote:** rode a rotina "Lote semanal" manualmente com `Execute routines/lote-semanal.md, mas gere a semana ATUAL a partir de amanhã`.

**Primeira semana:** mantenha `WASTATUS_TESTE=1` por 1 ou 2 dias, confira tudo e depois mude para `0` no ambiente.

---

## Parte E2 — Rotinas no modo local (sem GitHub)
O agendador do computador chama `scripts/run-rotina.sh`, que carrega o `.env`, roda o Claude Code sem interface e grava o log em `logs/`.

**macOS (launchd).** Um arquivo por rotina em `~/Library/LaunchAgents/`. Modelo para o slot 1 (troque `/CAMINHO/DO/PROJETO`, o nome, os argumentos e o horário):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>wastatus.slot1</string>
  <key>ProgramArguments</key><array>
    <string>/bin/bash</string><string>/CAMINHO/DO/PROJETO/scripts/run-rotina.sh</string>
    <string>slot</string><string>1</string>
  </array>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>30</integer></dict>
</dict></plist>
```
| Arquivo | Argumentos | Horário |
|---|---|---|
| `wastatus.lote.plist` | `lote` | `Weekday 0`, `Hour 19`, `Minute 0` (domingo) |
| `wastatus.slot1.plist` | `slot 1` | 07:30 |
| `wastatus.slot2.plist` | `slot 2` | 12:00 |
| `wastatus.slot3.plist` | `slot 3` | 17:30 |
| `wastatus.slot4.plist` | `slot 4` | 20:30 |

Ative com `launchctl load ~/Library/LaunchAgents/wastatus.*.plist`. Se o Mac estiver dormindo no horário, a rotina roda quando ele acordar. Para acordar sozinho: `sudo pmset repeat wakeorpoweron MTWRFSU 07:25:00`.

**Linux / Windows com WSL (cron).** `crontab -e` e acrescente (horários locais; confira com `date +%Z` que o sistema está no horário de Brasília):
```
0 19 * * 0   /CAMINHO/DO/PROJETO/scripts/run-rotina.sh lote
30 7 * * *   /CAMINHO/DO/PROJETO/scripts/run-rotina.sh slot 1
0 12 * * *   /CAMINHO/DO/PROJETO/scripts/run-rotina.sh slot 2
30 17 * * *  /CAMINHO/DO/PROJETO/scripts/run-rotina.sh slot 3
30 20 * * *  /CAMINHO/DO/PROJETO/scripts/run-rotina.sh slot 4
```

✅ `scripts/run-rotina.sh slot 1` roda na hora e `logs/<hoje>.log` termina com "fim (código 0)".

**Limite do modo local:** com o computador desligado, aquele status não sai; o próximo horário segue normal.

---

## Parte F — Dia a dia (👤, pelo WhatsApp do aprovador)
Domingo, por volta das 19h, chegam as prévias da semana, cada uma com um código (`SEG1` … `DOM4`). Responda uma linha por comando:

| Você escreve | Efeito |
|---|---|
| `OK` | aprova tudo |
| `OK SEG1` | aprova uma peça |
| `NAO TER3` | não publica essa peça |
| `REFAZER QUA2 deixe mais curto` | reescreve; você recebe a nova versão |
| `PAUSAR` / `RETOMAR` | suspende ou retoma todas as publicações |
| *(nada)* | publica no horário, **se** passou em 100% do filtro automático |

Às 20:30 chega o resumo do dia.

---

## Parte G — Problemas comuns
| Sintoma | Causa provável | O que fazer |
|---|---|---|
| Alerta "sessão não WORKING" | WhatsApp desconectou no WAHA | Reconectar no painel do WAHA (QR). Não recriar a sessão. |
| Erro `401` | Chave errada ou servidor não reiniciado | Corrigir no `.env` (editor) e no ambiente da nuvem. |
| Erro `463` | Timelock de contato novo (WAHA) | Aguardar; não reiniciar. |
| Erro `475` | Limite de mensagens | Aguardar. |
| Todas as peças bloqueadas por I06 | `brand.json` ainda `proposto` | Parte D1. |
| Peças das 20:30 bloqueadas | `cta.json` ainda `proposto` | Parte D3. |
| "DC alterado" no resumo | Você editou o DC | Normal. Âncoras de tema que sumirem do DC bloqueiam (T05); peça ao Claude para atualizar `temas.yaml`. |
| Status não aparece para contatos | Privacidade de status ou contato sem o número salvo | Parte A5. |
| Rotina não faz push (nuvem) | Permissão de branch | Parte C4. |
| Status do horário não saiu (local) | Computador desligado ou Claude Code deslogado | Ver `logs/<data>.log`; rodar `claude` no terminal para conferir o login. |
