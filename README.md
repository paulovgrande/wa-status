# WA Status

Publica **4 status por dia no WhatsApp**, de forma automática: arte vertical com jazz instrumental de fundo, texto escrito pelo Claude a partir do documento que descreve a sua oferta, e aprovação semanal pelo próprio WhatsApp.

![Exemplos de artes geradas (produto fictício)](examples/render/folha-exemplos.jpg)

> Todo o conteúdo deste repositório é **modelo**. O produto "Consultoria Exemplo" e a "Ana Exemplo" são fictícios.

## Como instalar (um link e algumas perguntas)

1. Abra o **Claude Code** (app desktop, extensão do VS Code ou terminal) numa pasta vazia.
2. Cole esta mensagem:
   ```
   Instale o WA Status a partir de https://github.com/paulovgrande/wa-status
   ```
3. Responda às perguntas. O Claude baixa o projeto, faz uma entrevista curta sobre o seu produto, monta o arquivo `.env` com as suas conexões **na sua máquina**, implementa o sistema, faz um teste que só você vê e agenda as publicações.

Antes de começar, tenha em mãos: um servidor **WAHA** funcionando (https://waha.devlike.pro), o número de WhatsApp que vai publicar, um segundo número para aprovar as prévias e uma conta no GitHub. Detalhes em [COMECE-AQUI.md](COMECE-AQUI.md).

### Para o Claude
Se você recebeu o link deste repositório para instalar: clone o repositório numa pasta escolhida pelo usuário, entre nela e siga **exatamente** [.claude/skills/wa-status-instalacao/SKILL.md](.claude/skills/wa-status-instalacao/SKILL.md). Nunca peça a chave da API no chat: o usuário a cola no `.env`, pelo editor.

## Como funciona

| Horário (BRT) | Pilar | Objetivo |
|---|---|---|
| 07:30 | Autoridade | Ensinar uma ideia do seu método |
| 12:00 | Dor | Nomear uma dor do seu público |
| 17:30 | Prova / Bastidor | Mostrar como você trabalha (sem depoimentos inventados) |
| 20:30 | CTA | Convidar para uma conversa |

- **Domingo, 19h:** o Claude escreve as 28 peças da semana a partir do seu Documento-Chave e manda as prévias para o seu WhatsApp de aprovação.
- **Você responde** `OK`, `NAO TER3` ou `REFAZER QUA2 deixe mais curto`. Sem resposta, publica, mas só o que passou em 100% dos filtros automáticos.
- **Filtros automáticos:** nenhum número que não esteja no seu documento, nenhuma promessa de resultado, nenhum depoimento inventado, nada fora da área visível do status. Para advocacia, há um modo com as regras de publicidade da OAB (Provimento 205/2021).
- Roda sozinho na nuvem do Claude Code, a partir de um repositório **privado** seu.

## Documentação

| Arquivo | Para quê |
|---|---|
| [COMECE-AQUI.md](COMECE-AQUI.md) | O que ter em mãos e como é a instalação |
| [docs/SPEC.md](docs/SPEC.md) | Especificação completa: regras, fluxos, validadores, API do WAHA |
| [docs/TAREFAS.md](docs/TAREFAS.md) | Plano de implementação, tarefa por tarefa |
| [docs/INSTALACAO.md](docs/INSTALACAO.md) | Passo a passo de instalação, rotinas e operação |
| [docs/GUIA-VISUAL.md](docs/GUIA-VISUAL.md) | Padrão visual: espaçamento, cores, logo, liquid glass |
| [docs/SEGURANCA.md](docs/SEGURANCA.md) | Chaves, `.env`, repositório privado, riscos do WhatsApp |

## Ressalvas importantes

- **WhatsApp:** o WAHA usa uma conexão **não oficial** com o WhatsApp. O WhatsApp pode restringir ou banir números com comportamento de automação. Use por sua conta e risco, num volume moderado.
- **Conteúdo:** você é responsável por tudo o que for publicado e por cumprir as regras da sua profissão (por exemplo, o Provimento 205/2021 da OAB para advogados). Os filtros ajudam, mas não substituem a sua revisão.
- **Custos:** o Claude Code e o servidor WAHA (e eventualmente o WAHA Plus) são pagos à parte.
- **Sem garantia e sem suporte:** o projeto é fornecido "como está".
- **Status só aparece** para quem tem o número que publica salvo nos contatos.

## Licença

[PolyForm Internal Use 1.0.0](LICENSE.md). Em resumo (o texto da licença é o que vale):
- ✅ Você pode usar e adaptar o projeto **nas operações internas do seu negócio**.
- ❌ Você não pode redistribuir, revender, sublicenciar nem oferecer o projeto (original ou modificado) a terceiros, nem como serviço.
- Sem garantia de qualquer tipo.

Componentes de terceiros: fontes Inter e Libre Baskerville sob a SIL Open Font License (`assets/fonts/OFL-*.txt`); trilhas da Mixkit, baixadas na instalação sob a licença da Mixkit (https://mixkit.co/license/) e não incluídas neste repositório.
