# Segurança

| Item | Regra |
|---|---|
| Chave do WAHA | Só no `.env` local (`chmod 600`) e nas variáveis do ambiente da nuvem. Nunca no chat, prompt, commit ou log. Se vazar: troque a chave no servidor WAHA e atualize o `.env` e o ambiente. |
| `.env` | Fica na raiz do projeto e já está no `.gitignore`. Confira com `git check-ignore .env`. |
| Repositório do usuário (modo nuvem) | **Privado.** O `state/` guarda prévias, códigos e o histórico de publicação; `produtos/<id>/` guarda seu DC, logo e fotos. |
| Repositório público (este) | Contém só o modelo e o produto fictício. Não abra pull requests com dados seus. |
| Números de telefone | O do aprovador fica só no `.env`. Históricos de teste (`state/teste-*.json`) não são versionados. |
| Dados de clientes | Nenhum dado de cliente entra no sistema; os validadores T03/T07 bloqueiam nomes e "meu cliente". |
| Depoimentos | Só com autorização escrita de cada pessoa, guardada fora do repositório e referenciada na peça (`autorizacao_ref`). |

## Servidor WAHA
- Exponha o WAHA só por **HTTPS**, com chave de API forte (32+ caracteres aleatórios).
- Se possível, use uma chave exclusiva para esta automação e troque-a a cada 90 dias.
- Não exponha o painel do WAHA sem senha.
- O WAHA conecta o WhatsApp por meio não oficial: o WhatsApp pode restringir ou banir números com comportamento de automação. Use um volume moderado (o padrão é 4 status por dia) e não envie mensagens em massa.

## Auditoria
`state/<id>/publicacoes.jsonl` registra o que foi ao ar, quando e com qual id do WhatsApp. Revise uma vez por mês.
