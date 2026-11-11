# WA Status — comece aqui

Este projeto publica **4 status por dia no WhatsApp**: arte + jazz instrumental de fundo, textos escritos a partir do documento que descreve a sua oferta, com aprovação pelo WhatsApp. Você não precisa ler a documentação técnica: o Claude conduz a instalação passo a passo.

## Antes de começar
- [ ] **Claude Code** instalado (app desktop, extensão do VS Code ou terminal) e logado na sua conta Claude.
- [ ] Um Mac, Linux ou Windows com WSL, com **Python 3.11+**, **git** e **ffmpeg**. Se faltar algo, o Claude diz como instalar.
- [ ] Um servidor **WAHA** acessível pela internet (HTTPS), com a **chave da API** (https://waha.devlike.pro). Se alguém administra o servidor para você, peça o endereço, a chave e o nome da sessão.
- [ ] O número de WhatsApp que vai **publicar**, conectado a uma sessão do WAHA.
- [ ] Um **segundo** número de WhatsApp, de quem vai **aprovar** as prévias.
- [ ] Um computador que fique **ligado** nos horários das publicações (07:30, 12:00, 17:30, 20:30 e domingo 19:00). **Não precisa de GitHub.**
  - Alternativa: rodar na nuvem do Claude Code, com o computador desligado. Aí é preciso uma conta no **GitHub**.
- [ ] Opcional, mas ajuda muito: um texto descrevendo a sua oferta, o seu logo (PNG com fundo transparente) e fotos suas.

## Instalação
1. Abra o Claude Code numa pasta vazia.
2. Cole: `Instale o WA Status a partir de https://github.com/paulovgrande/wa-status`
3. Responda às perguntas.

Se você já baixou o projeto: abra o Claude Code dentro da pasta e digite `/wa-status-instalacao`.

O Claude vai, nesta ordem: conferir o computador → entrevistar você sobre o produto, o conteúdo e o WhatsApp → montar o `.env` → testar o WAHA → preparar o conteúdo (documento, temas, marca, CTA) → (só no modo nuvem) criar um repositório **privado** seu → implementar o sistema, tarefa por tarefa → pedir suas aprovações (marca, fotos, CTA, músicas) → fazer um teste que só você vê → agendar as publicações no seu computador (ou na nuvem).

Pode parar a qualquer momento: na próxima vez, digite `/wa-status-instalacao` e ele retoma de onde parou.

## Onde ficam os seus dados
| O quê | Onde |
|---|---|
| Endereço do WAHA, chave, sessão, número do aprovador | `.env`, na pasta do projeto, **só na sua máquina** (fora do git); no modo nuvem, também nas variáveis do ambiente da rotina |
| Documento-Chave, logo, fotos, temas, CTA | `produtos/<seu-produto>/`, na pasta do projeto (e no seu repositório **privado**, no modo nuvem) |
| Prévias e histórico de publicações | `state/`, na pasta do projeto (e no repositório privado, no modo nuvem) |
| Logs das execuções (modo local) | `logs/`, na pasta do projeto |

## Três cuidados
- 🔑 **A chave da API nunca vai no chat.** Quando o Claude pedir, abra o arquivo `.env` no editor, cole a chave e salve.
- 👀 **Testes só para você:** nada é publicado para os contatos sem você escrever "pode publicar".
- 📇 **Só vê o status quem tem o número que publica salvo nos contatos.**

## Aprovação no dia a dia (pelo WhatsApp)
No domingo, por volta das 19h, chegam as prévias da semana. Responda:

| Você escreve | Efeito |
|---|---|
| `OK` | aprova tudo |
| `OK SEG1` | aprova uma peça |
| `NAO TER3` | não publica essa peça |
| `REFAZER QUA2 deixe mais curto` | reescreve e reenvia |
| `PAUSAR` / `RETOMAR` | suspende ou retoma tudo |

Sem resposta, a peça é publicada no horário, mas só se passou em 100% dos filtros automáticos.

Para qualquer ajuste depois de instalado (trocar música, aprovar fotos, mudar o CTA, pausar, resolver um erro): `/wa-status-operacao`.
