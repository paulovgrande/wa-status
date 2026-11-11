# Guia visual dos criativos

Como gerar um status com qualidade. Vale para o agente que escreve e renderiza as peças. Onde este guia não disser nada, vale `docs/SPEC.md`.

## 1. A regra principal
**Não desenhe a arte do zero.** Ela já está desenhada nos templates (`templates/base.html` e `templates/layouts/*.html`). O trabalho é: escrever o texto a partir do DC, preencher o template do layout do dia e renderizar no Chromium em 1080×1920. Compare sempre com `examples/render/folha-exemplos.jpg` e `examples/liquid-glass/`.

## 2. Tela e espaçamento
Tela fixa: **1080 × 1920 px**, escala 1. O WhatsApp cobre o topo e a base do status:

| Faixa (y) | Uso | Regra |
|---|---|---|
| **0 a 230** | Barra de progresso, foto e nome do perfil | Nada de texto ou logo (a foto do `foto_topo` pode começar em y=200). |
| **230 a 1450** | Todo o conteúdo | Margem lateral: x de **72 a 1008**. Painéis de vidro podem ir de 56 a 1024. |
| **1450 a 1920** | Legenda e campo "Responder" | Nada de texto ou logo. A legenda cobre essa área. |

Posições dos templates: bloco de conteúdo `top 250`, altura 960 (até y=1210), `gap 44px`; rodapé (logo + assinatura) `top 1250`, altura 180 (até y=1430), logo com 170 px de altura.

## 3. Cores
Só os 9 tokens de `produtos/<id>/brand.json → paleta`. Padrão: `ink #121417` (fundo), `grafite #1E2228`, `ouro #C9A45C` (kicker, régua, números, borda do botão), `ouro_claro #E8D48E` (texto do botão), `ouro_escuro #7A5A22` (detalhes sobre creme), `creme #F6F3EC` (fundo claro), `texto_claro #F3EFE6`, `texto_suave #B9B4A9`, `texto_escuro #1B1D21`.
- Contraste mínimo: **4,5:1** para texto, **3:1** para o logo.
- Logo de cor média (ex.: dourado) não tem contraste sobre fundo claro: no layout claro, ele fica sobre uma faixa escura.
- Para mudar a paleta, troque os valores mantendo os nomes dos tokens.

## 4. Tipografia
| Elemento | Fonte | Tamanho |
|---|---|---|
| Kicker | Inter 600 | 30 px, caixa alta, `letter-spacing .16em` |
| Headline | Libre Baskerville 700 | até 40 caracteres 84 px; até 55, 72 px; acima, 64 px. Entrelinha 1,16 |
| Corpo | Inter 400 | 44 px, entrelinha 1,42 |
| Itens da lista | número Libre Baskerville 60 px; texto Inter 46 px | 3 itens |
| Botão do CTA | Inter 600 | 44 px |
| Assinatura | Inter | nome 34 px 600; 2ª linha 30 px |

Mínimos: headline 56 px, corpo 34 px. Se não couber, **encurte o texto**. Carregue as fontes pelos `.ttf` de `assets/fonts/`.

## 5. Logo
- Só o arquivo de `brand.json`, com fundo transparente e margens cortadas (limiar de alfa > 40).
- Sem distorção (largura automática), sem recolorir, sem sombra, sem girar, sem texto em cima. Um logo por arte.
- 170 px de altura no rodapé; 160 px de largura no layout com foto.

## 6. Layouts
| Layout | Pilares | Como é |
|---|---|---|
| `tipografico_escuro` | autoridade, dor | Fundo radial escuro, filete vertical na borda esquerda, kicker, régua, headline, corpo |
| `tipografico_claro` | dor, prova | Fundo creme, texto escuro, faixa escura embaixo com o logo |
| `lista` | autoridade, prova | Headline + exatamente 3 itens numerados |
| `foto_topo` | autoridade, prova | Foto 960×960 no topo, kicker e headline embaixo; o corpo vai na legenda |
| `cta` | cta | Headline, corpo e botão com o `cta_texto` |

## 7. Fotos
Só fotos reais e autorizadas, com `exif_transpose`, recorte quadrado centrado na área protegida, escala ≤ 1,15, nada sobre o rosto. Nunca gere pessoa por IA.

## 8. Liquid glass (opcional, só layouts escuros)
Vidro fumê translúcido com borda dourada fina e reflexo, sobre luzes douradas desfocadas. CSS completo em `templates/liquid-glass.css`; exemplos em `examples/liquid-glass/`.
- **Como aplicar:** incluir o CSS no `<style>`, inserir `<div class="luzes"><i class="l1"></i><i class="l2"></i><i class="l3"></i></div>` como primeiro filho da `.canvas`, e acrescentar a classe `vidro` em `.bloco` e `.rodape`.
- Valores: desfoque `blur(28px) saturate(140%)`; preenchimento branco 10% → 3,5% → 6%; borda 1,5 px `ouro_claro` a 30%; cantos 40 px (cápsula da assinatura em pílula); sombra `0 30px 80px` a 45%; cartão de y=250 a 1210; cápsula de y=1240 a 1440.
- **Sem as luzes atrás, o vidro não aparece.** Vidro sempre escuro; no máximo 2 painéis; nunca em `foto_topo` nem em `tipografico_claro`.
- Não ponha `position: relative` em `.vidro` (`.bloco` e `.rodape` são `absolute`; o rodapé some).
- Renderize no Chromium: outros renderizadores ignoram `backdrop-filter`.

## 9. Checklist antes de mandar a prévia
- [ ] 1080×1920, fontes do projeto carregadas
- [ ] Nada acima de y=230 nem abaixo de y=1450
- [ ] Nenhum texto vazando; margens x 72–1008
- [ ] Só cores da paleta; contraste ok
- [ ] Logo sem distorção, sobre fundo escuro
- [ ] Headline ≥ 56 px, corpo ≥ 34 px
- [ ] Foto autorizada, sem distorção, rosto livre
- [ ] Vidro (se houver): luzes atrás, fumê, no máximo 2 painéis
- [ ] Nenhuma URL, telefone ou emoji na arte
- [ ] Todo número e afirmação estão no DC
- [ ] Mesmo nível de `examples/render/folha-exemplos.jpg`
