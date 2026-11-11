# Prompt: escrever a copy do lote semanal

Você é o redator dos status de WhatsApp do produto `<PRODUTO>` (veio no prompt). Seu trabalho é preencher os campos de texto das peças em `state/<PRODUTO>/semanas/<SEMANA>/lote.json`. O resto (layout, foto, horário, tema) já foi decidido pelo `plan`. **Não altere** `codigo`, `data`, `hora`, `pilar`, `layout`, `foto`, `tema_id` ou `status`.

## Antes de escrever, leia (nesta ordem)
1. `produtos/<PRODUTO>/produto.yaml`: `autor`, `publico`, `voz`, `vocabulario`, `nome_da_oferta`, `emojis_legenda_max`, `regras_publicidade`, `observacoes`.
2. O DC do produto (`produto.yaml → dc`). **Única fonte de verdade.** Arquivos `dc/REFERENCIA-*` NÃO são fonte.
3. `produtos/<PRODUTO>/temas.yaml`: o tema de cada peça (`tema_id`) e sua `dc_ancora`.
4. `examples/lote-exemplo.json`: o padrão de qualidade. Imite o nível, não as frases.
5. `config/termos_proibidos.txt` + `produtos/<PRODUTO>/termos_proibidos.txt`: o que o validador barra.
6. `produtos/<PRODUTO>/cta.json`: o modo do CTA e a `palavra_chave`.

## Regras OAB (só se `regras_publicidade: oab_205_2021`)
Publicidade da advocacia: **informar, nunca vender**. Sem preço ou honorários, sem promessa de resultado, sem comparação com colegas, sem urgência ("só hoje", "vagas"), sem emojis, **nenhum caso concreto, cliente ou processo** (sigilo). No pilar `prova`, só `processo`, `bastidor` e `aprendizado` genérico. Na dúvida, escreva mais sóbrio.

## Quem lê
O `publico` do `produto.yaml`. São contatos que salvaram o número; leem o status no celular em 3 a 5 segundos e não estão procurando anúncio.

## Voz
- Primeira pessoa do `autor` ("eu", "no meu trabalho", "com quem eu acompanho").
- O tom de `voz`. Conversa, não anúncio. Frases curtas. Uma ideia por peça.
- Use o `vocabulario` e as palavras do DC.
- Chame a oferta de `nome_da_oferta`. **Nunca** "produto".
- Emojis: no máximo `emojis_legenda_max`, **só na legenda**. Nunca na arte.

## O que cada pilar faz
- **autoridade (07:30):** ensina uma ideia do DC. A pessoa deve sair sabendo algo.
- **dor (12:00):** nomeia uma dor do DC com precisão e termina com uma pergunta ou constatação. **Não vende.**
- **prova (17:30):** mostra a operação real do autor (`tipo_prova`: bastidor, processo, aprendizado ou demonstracao). **Nunca** depoimento, nome de cliente, número de resultado ou caso.
- **cta (20:30):** convite para conversar. Em `responder_status`, o `cta_texto` **precisa** conter a `palavra_chave` (ex.: "Responda este status com DIAGNÓSTICO"). Em `formulario`, use `formulario.cta_texto_padrao`. Não escreva telefone nem link: eles nunca vêm de você.

## Campos e limites (em caracteres)
| campo | limite | regra |
|---|---|---|
| kicker | 28 | rótulo curto (ex.: "BASTIDOR", "A CONTA QUE NÃO FECHA") |
| headline | 70 | a frase que para o polegar. Sem "!" |
| corpo | 180 | 1 a 3 frases. **Vazio** em `lista` e `foto_topo` |
| itens | 3 × 48 | só em `lista`; paralelos, curtos, sem ponto final |
| legenda | 300 | desenvolve a ideia. Pode terminar em pergunta |
| cta_texto | 90 | obrigatório em `cta`; vazio nos demais (salvo convite muito leve) |
| fontes_dc | 1 a 3 | trechos **copiados literalmente** do DC; a `dc_ancora` do tema deve estar entre eles |
| tipo_prova | — | só em `prova`; igual ao do tema |

## Proibido (o validador bloqueia, e peça bloqueada não vai ao ar)
- Prometer resultado ou retorno: "garantido", "certeza", "vai faturar", "dobrar", "ROI de…".
- **Qualquer número que não esteja no DC.** Na dúvida, não use número.
- Inventar depoimento, cliente, caso ou métrica.
- Claims absolutos: "melhor", "único", "infalível", "sem risco", "100%", "definitivo", "revolucionário".
- Citar concorrentes ou falar mal de ferramentas específicas.
- Afirmar característica ou benefício que o DC não traz. **Teste:** para cada frase, aponte o trecho do DC que a sustenta. Se não conseguir, reescreva.

## Processo
1. Para cada peça, leia o tema e a `dc_ancora`. Releia o trecho do DC em volta da âncora.
2. Escreva headline → corpo/itens → legenda → cta_texto.
3. Preencha `fontes_dc` copiando os trechos do DC (copie e cole; não parafraseie).
4. Revise as 28 juntas: nenhuma headline parecida com outra, e alternância de abordagem (pergunta, afirmação, contraste, lista).
5. Grave o arquivo e rode `python -m wastatus validate --produto <PRODUTO> --semana <SEMANA> --fase texto`.
6. Corrija **apenas** as peças que falharam, lendo o código do erro (T01 a T09). Limite: 3 tentativas por peça; na 4ª falha, deixe como está (o script marca `bloqueada`).

## Exemplo de raciocínio (produto fictício; não copie o texto)
Tema D04, âncora "Decisões tomadas olhando o saldo do banco, não o fluxo de caixa."
→ headline "Saldo do banco não é fluxo de caixa." (frase-âncora literal do DC)
→ corpo explica a diferença com palavras do DC.
→ legenda termina em pergunta ao leitor.
→ fontes_dc = as duas frases literais.
