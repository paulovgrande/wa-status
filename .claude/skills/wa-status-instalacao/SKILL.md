---
name: wa-status-instalacao
description: Instala e configura do zero o WA Status (4 status por dia no WhatsApp via WAHA, com arte + jazz, gerados a partir do Documento-Chave do produto, com aprovação pelo WhatsApp). Faz uma entrevista curta, monta o .env local, cria o produto, implementa o sistema, testa só com o aprovador e agenda as rotinas. Use quando o usuário colar o link do repositório WA Status, pedir para instalar, configurar, implementar, "começar" ou "continuar a instalação", ou digitar /wa-status-instalacao.
---

# Instalação guiada do WA Status

Você conduz a instalação **em etapas curtas**, uma por vez. Ao fim de cada etapa: diga em 1 a 3 linhas o que foi feito e o resultado da verificação, e pergunte se pode seguir. Fale em português simples, sem jargão. O usuário pode não ser técnico.

Fontes de verdade (leia antes de agir): `docs/SPEC.md`, `docs/TAREFAS.md`, `docs/INSTALACAO.md`, `docs/GUIA-VISUAL.md`. Esta skill só organiza o caminho. **Não invente comportamento que a SPEC não define**: registre a dúvida em `docs/PENDENCIAS.md` e pergunte.

## Regras inegociáveis
- **Segredos:** nunca peça a chave do WAHA no chat, nunca a imprima, nunca a coloque em arquivo versionado, prompt ou log. O usuário digita a chave **no editor**, dentro do `.env`. Para conferir, mostre só o tamanho: `${#WHATSAPP_API_KEY}`. Se o usuário colar a chave no chat mesmo assim, avise que ela deve ser trocada no servidor WAHA depois da instalação.
- **Dados do usuário ficam na máquina dele:** respostas da entrevista vão para `produtos/<id>/` e para o `.env` **da pasta do projeto**. Nada é enviado a outro lugar além do WAHA do próprio usuário e do repositório **privado** dele.
- **Nada vai ao ar sem confirmação:** testes de status sempre só para o aprovador. Publicar para todos os contatos exige o "pode publicar" explícito do usuário.
- **Nunca invente números, depoimentos ou fatos:** tudo o que vai ao ar sai do Documento-Chave aprovado pelo usuário.
- **Músicas:** só as de `config/musicas.json`, baixadas por `scripts/baixar_musicas.py`.
- Uma tarefa de `docs/TAREFAS.md` por vez; só avance com os testes passando.

## Progresso
Mantenha `state/instalacao.json` com `{"etapa_concluida": N, "produto": "<id>", "notas": "..."}`. Ao iniciar, leia esse arquivo e **retome** da etapa seguinte, dizendo onde parou.

---

## Etapa 0 — Obter o projeto e conferir o computador
1. Se a pasta atual ainda não tem `docs/SPEC.md`, o usuário colou o link do repositório: pergunte em que pasta quer instalar (sugira `~/wa-status`), rode `git clone <link> <pasta>` e passe a trabalhar **dentro** dela.
2. Rode e mostre um resumo (✅/❌):
   ```bash
   python3 --version; git --version; ffmpeg -version | head -1; gh --version | head -1
   ```
   - Python ≥ 3.11, git e ffmpeg são obrigatórios. macOS: `brew install python@3.12 git ffmpeg gh`. Ubuntu/Debian: `sudo apt-get install -y python3 python3-venv git ffmpeg gh`. Windows: recomende o WSL (Ubuntu).
   - `gh` (GitHub CLI) facilita criar o repositório privado. Se faltar, dá para criar pelo site.

## Etapa 1 — Entrevista (faça as perguntas em blocos de 2 a 4, não todas de uma vez)
Explique antes: "vou fazer algumas perguntas para configurar o seu produto; nada sai da sua máquina".

**Bloco A — O produto**
1. Nome do produto ou serviço que os status vão divulgar.
2. Seu nome como deve aparecer na assinatura da arte, e a 2ª linha (ex.: nome do negócio).
3. Quem é o público, em uma frase.
4. Como você chama o que oferece (mentoria, consultoria, curso, serviço…).
5. Você é de uma profissão com regras de publicidade? (Advocacia → ative `regras_publicidade: oab_205_2021`: tom informativo, sem emojis, sem promessa, sigilo. Para outras profissões regulamentadas, registre as restrições em `produtos/<id>/termos_proibidos.txt` e em `observacoes`.)
6. Usa emojis na comunicação? (0 a 2 por legenda; 0 se a resposta da 5 for advocacia.)

**Bloco B — Conteúdo**
7. Você já tem um texto que descreve a sua oferta (o "Documento-Chave")? Se sim, peça para colocar o arquivo em `produtos/<id>/dc/` (ou colar o texto, que você grava como `documento-chave.md`). Se não, faça uma entrevista curta seguindo `produtos/_modelo/dc/LEIA-ME.md` (o que é, para quem, dores, método, diferenciais, o que não prometer, números autorizados, chamada) e escreva um rascunho **só com o que o usuário disse**. Marque números e afirmações para revisão. O usuário aprova antes de virar DC.
8. Logo: peça para colocar o arquivo (PNG com fundo transparente, de preferência) em `produtos/<id>/marca/logo-principal.png`. Pergunte se ele é para fundo escuro ou claro.
9. Fotos suas (opcional): coloque em `produtos/<id>/fotos/`. Só fotos reais e que você autoriza usar. Sem fotos, os layouts sem foto são usados.
10. CTA (o convite das 20:30): (a) "responda este status com <PALAVRA>" — padrão, não precisa de link; (b) link para um formulário ou página (URL); (c) link para outro WhatsApp (número com DDI e DDD).

**Bloco C — WhatsApp (WAHA)**
11. Você já tem um servidor **WAHA** funcionando? Se não: explique que o WAHA é o programa que conecta um número de WhatsApp a uma API; ele precisa estar instalado num servidor acessível pela internet (HTTPS) e protegido por chave. Indique a documentação oficial (https://waha.devlike.pro) e **pause a instalação** até ele existir. Não instale servidor por conta própria sem o usuário pedir.
12. Endereço do WAHA (ex.: `https://waha.seudominio.com.br`).
13. Nome da **sessão** do WAHA conectada ao número que vai **publicar** os status.
14. Número de WhatsApp de quem vai **aprovar** as prévias (precisa ser **diferente** do número que publica). Formato: `55` + DDD + número.

Grave as respostas: crie `produtos/<id>/` copiando `produtos/_modelo/`, defina `id` (minúsculas, sem espaço) e `env_prefixo` (MAIÚSCULAS), e preencha `produto.yaml`, `brand.json → assinatura`, `cta.json`. **Não** grave endereço, sessão, número ou chave em arquivos versionados: eles vão só no `.env` (Etapa 2).

## Etapa 2 — Montar o `.env` local
1. `cp .env.example .env` (se já existir, faça backup `.env.backup-<data>` antes). `chmod 600 .env`.
2. Troque o bloco `MEUPRODUTO_` pelo prefixo do produto e preencha **você mesmo** os valores não secretos que o usuário informou: `WAHA_BASE_URL`, `PRODUTOS_ATIVOS=<id>`, `<PREFIXO>_WAHA_SESSION`, `<PREFIXO>_APPROVER_CHAT_ID=55DDDNUMERO@c.us`, `WASTATUS_TESTE=1`.
3. Diga ao usuário, com o caminho completo do arquivo: "Abra `<pasta do projeto>/.env` no editor, cole a chave da API do WAHA depois de `WHATSAPP_API_KEY=` e salve. Não cole a chave aqui no chat." Espere ele confirmar.
4. Explique onde os dados ficaram: `.env` (conexões e chave, só nesta máquina, fora do git) e `produtos/<id>/` (conteúdo do produto).
5. Valide sem expor: `set -a; . ./.env; set +a; echo "chave: ${#WHATSAPP_API_KEY} caracteres"; git check-ignore -q .env && echo ".env fora do git ✅"`.

## Etapa 3 — Testar o WAHA
```bash
set -a; . ./.env; set +a; H="X-Api-Key: $WHATSAPP_API_KEY"; P=<PREFIXO>
S=$(eval echo \$${P}_WAHA_SESSION); A=$(eval echo \$${P}_APPROVER_CHAT_ID)
curl -s -H "$H" "$WAHA_BASE_URL/api/sessions/$S"
curl -s -H "$H" "$WAHA_BASE_URL/api/contacts/check-exists?phone=${A%@c.us}&session=$S"
```
Esperado: `"status":"WORKING"`, um `engine`, `me.id` (número que publica) e `numberExists: true`.
- **401** = chave errada, ou o servidor não foi reiniciado depois de trocar a chave. Peça o valor exato (não o hash `sha512:`) e que confira no Swagger do WAHA (`/api`, botão Authorize).
- **Sessão inexistente ou parada** = criar/iniciar a sessão no painel do WAHA e ler o QR com o celular do número que publica.
- Grave `engine` e `numero_publicador` em `produtos/<id>/produto.yaml → waha`.
- Se `me.id` == aprovador: **pare** e peça outro número para aprovar.
- Lembre: **só vê o status quem tem o número que publica salvo nos contatos.**

## Etapa 4 — Conteúdo do produto
- **DC:** confirme que o usuário aprovou o texto final.
- **Temas:** proponha `temas.yaml` com `dc_ancora` copiada **literalmente** do DC (mínimo 12 autoridade, 12 dor, 9 prova, 7 cta; se o DC for curto, proponha o que ele sustenta e avise). Siga o formato de `produtos/exemplo/temas.yaml`.
- **Marca:** se o logo não for dourado, proponha uma paleta com as cores do logo mantendo os nomes de token de `brand.json`, e garanta os contrastes do `docs/GUIA-VISUAL.md`. Status `proposto` até a Etapa 7.
- **Fotos:** para cada foto, `exif_transpose`, medir a área protegida (rosto + tronco) em coordenadas 0–1 e registrar em `photos.json` como `proposto`.

## Etapa 5 — Repositório privado do usuário
As rotinas na nuvem precisam de um repositório **privado** do próprio usuário (o `state/` guarda prévias e o histórico).
1. Desligue o vínculo com o repositório público: `git remote remove origin` (ou renomeie para `upstream`, só para buscar atualizações).
2. Crie o privado: `gh repo create wa-status --private --source . --push` (ou pelo site: New repository → **Private** → sem README; depois `git remote add origin … && git push -u origin main`).
3. Confirme que nenhum segredo subiu: `git ls-files | grep -E '^\.env$' | wc -l` deve dar 0.
4. **Nunca** torne esse repositório público e não faça fork público: ele terá o conteúdo do usuário. (A licença também não permite redistribuir o projeto.)

## Etapa 6 — Implementação
Recomende trocar para o modelo **Haiku** (`/model`): o plano foi escrito para ele. Execute `docs/TAREFAS.md` na ordem (1 … 7, 7b, 8 … 12, 12b, 13), **uma por resposta**: implementar → rodar os testes de aceite → mostrar o resultado → perguntar "sigo para a Tarefa N+1?". Ao final de cada tarefa, `git commit` e `git push`.
Referências de qualidade: `examples/lote-exemplo.json`, `examples/render/` e `docs/GUIA-VISUAL.md`.

## Etapa 7 — Aprovações iniciais (cada uma com resposta explícita do usuário)
1. `python -m wastatus brand-preview --produto <id>` → aprovar marca (`brand.json → aprovado`).
2. `python -m wastatus fotos-preview --produto <id>` → aprovar as áreas protegidas (se houver fotos).
3. CTA: confirmar modo e URL/número (`cta.json → aprovado`).
4. Músicas: 1 status de teste por faixa **só para o aprovador**; o usuário diz quais aprova (`config/musicas.json → aprovado`) e se o volume está bom.

## Etapa 8 — Teste ponta a ponta (só o aprovador vê)
Com `WASTATUS_TESTE=1`, Tarefa 12. Peça ao usuário para conferir no celular do aprovador: o vídeo tocou com música, a legenda não cobre o logo, o texto está legível, o link do CTA abre. Com engine WEBJS, siga `docs/INSTALACAO.md`, passo D4.

## Etapa 9 — Nuvem e rotinas
Siga `docs/INSTALACAO.md`, partes C e E:
- Ambiente na nuvem do Claude Code com as **mesmas variáveis do `.env`** (o usuário digita os valores na tela do ambiente, não no chat) e rede liberada para: o domínio do WAHA, `assets.mixkit.co`, `pypi.org`, `files.pythonhosted.org`, `github.com` e os domínios do Playwright.
- Crie as 5 rotinas com `/schedule` (tabela da Parte E), modelo Haiku.
- Rode o primeiro lote manualmente.
- Depois de 1 ou 2 dias conferidos, pergunte se pode mudar `WASTATUS_TESTE` para `0`. **Só com "pode publicar" explícito.**

## Encerramento
Resumo final: o que está ativo, horários, como aprovar pelo WhatsApp (`OK`, `NAO TER3`, `REFAZER QUA2 …`, `PAUSAR`/`RETOMAR`), onde estão os dados (`.env` e `produtos/<id>/`) e que a skill `wa-status-operacao` cuida da manutenção.
