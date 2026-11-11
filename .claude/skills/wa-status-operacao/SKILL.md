---
name: wa-status-operacao
description: Manutenção do WA Status já instalado — adicionar produto, aprovar marca/fotos/músicas/CTA, registrar fotos novas, trocar trilha de jazz, pausar/retomar, publicar teste, atualizar o Documento-Chave, diagnosticar falha de publicação (401, sessão não WORKING, 463/475, status que não aparece). Use quando o usuário pedir qualquer ajuste ou diagnóstico do WA Status depois da instalação, ou digitar /wa-status-operacao.
---

# Operação e manutenção do WA Status

Fonte de verdade: `docs/SPEC.md`. Cada produto fica em `produtos/<id>/`; as conexões ficam no `.env` (`<PREFIXO>_WAHA_SESSION`, `<PREFIXO>_APPROVER_CHAT_ID`). Pergunte **qual produto** quando o pedido não disser. Regras: **a chave nunca aparece**; teste vai **só para o aprovador**; publicar para todos exige "pode publicar" explícito; nada fora da SPEC sem registrar em `docs/PENDENCIAS.md`.

Sempre comece com `set -a; . ./.env; set +a` (local). Na nuvem, as variáveis já existem.

## Pedidos comuns

| Pedido | O que fazer |
|---|---|
| "Novo produto" | Copiar `produtos/_modelo/` → `produtos/<id>/`, fazer as perguntas dos blocos A e B da skill `wa-status-instalacao`, adicionar `<PREFIXO>_*` no `.env` (o usuário cola segredos no editor) e o id em `PRODUTOS_ATIVOS`. |
| "Aprovar marca / fotos / CTA" | Mudar `status` para `aprovado` em `produtos/<id>/brand.json`, `photos.json` ou `cta.json`; commit. Músicas: `config/musicas.json`. |
| "Registre as fotos novas" | Para cada foto de `produtos/<id>/fotos/` fora do `photos.json`: `exif_transpose`, medir a área protegida (rosto + tronco) em coordenadas 0–1, adicionar como `proposto`; rodar `fotos-preview --produto <id>` e pedir aprovação. |
| "Quero outra música" | Buscar **só na Mixkit** (jazz instrumental), adicionar em `config/musicas.json` com `mixkit_id` e `status: proposto`, rodar `scripts/baixar_musicas.py`, publicar 1 status de teste só para o aprovador. |
| "Volume da música" | `config/settings.yaml → video.volume` (0.8 padrão). |
| "Voltar para imagem sem música" | `video.ativo: false`. |
| "Mudar CTA" | `produtos/<id>/cta.json`: `formulario` (URL; conferir HTTP 200), `whatsapp` (número E.164) ou `responder_status`. O agente nunca escreve URL ou número na copy. |
| "Pausar tudo" | Responder `PAUSAR` no WhatsApp de aprovação, ou criar `state/<id>/PAUSADO`. `RETOMAR` desfaz. |
| "Publicar teste agora" | `python -m wastatus publicar --produto <id> --slot N --teste` (só aprovador). |
| "Atualizei o DC" | `python -m wastatus sync --produto <id>`; conferir se as `dc_ancora` dos temas continuam existindo (T05) e propor ajustes. |
| "Trocar a chave do WAHA" | O usuário edita o `.env` no editor e o ambiente da nuvem. Conferir só o tamanho. |

## Diagnóstico rápido

```bash
H="X-Api-Key: $WHATSAPP_API_KEY"; P=<PREFIXO>; S=$(eval echo \$${P}_WAHA_SESSION)
curl -s -H "$H" "$WAHA_BASE_URL/api/sessions/$S"          # WORKING? engine? me?
curl -s -H "$H" "$WAHA_BASE_URL/api/$S/chats/status@broadcast/messages?limit=10&downloadMedia=false"   # status realmente enviados
tail -5 state/<id>/publicacoes.jsonl
```

| Sintoma | Causa | Ação |
|---|---|---|
| 401 | chave errada / servidor não reiniciado | usuário corrige no `.env` (editor) ou no servidor |
| sessão ≠ WORKING | WhatsApp desconectou | reconectar pelo QR no painel do WAHA; não recriar a sessão |
| 463 / 475 | timelock / limite de mensagens | aguardar; não reiniciar |
| status enviado (201) mas ninguém vê | contato sem o número salvo, privacidade do status, ou `contacts` restrito (modo teste) | conferir no `status@broadcast`; pedir para salvar o número e checar a privacidade |
| legenda cobre o logo | legenda longa ou layout alterado | manter tudo acima de y=1450 (I02); encurtar a `legenda` |
| peça bloqueada | algum validador T/I falhou | mostrar o código e a peça; corrigir a copy (`prompts/refazer.md`), nunca forçar publicação |

Ao terminar qualquer ajuste: commit + push (as rotinas na nuvem leem o repositório privado).
