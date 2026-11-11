# WA Status — instruções para o Claude

Este repositório é o **modelo** do WA Status: especificação, templates, prompts e skills. O código Python (`wastatus/`) é criado na instalação, a partir de `docs/TAREFAS.md`.

- **Instalar ou continuar a instalação:** siga `.claude/skills/wa-status-instalacao/SKILL.md`.
- **Manutenção depois de instalado:** siga `.claude/skills/wa-status-operacao/SKILL.md`.
- **Fonte de verdade:** `docs/SPEC.md`. Não invente comportamento que ela não define; registre a dúvida em `docs/PENDENCIAS.md`.

Regras que valem sempre:
- A chave do WAHA nunca aparece no chat, em arquivo versionado, prompt ou log. Ela fica no `.env` da pasta do projeto, preenchida pelo usuário no editor.
- Endereço do WAHA, sessões e números ficam só no `.env`, nunca em arquivos versionados.
- Nada vai ao ar para os contatos sem "pode publicar" explícito do usuário. Testes vão só para o aprovador.
- Nada que não esteja no Documento-Chave do produto vai ao ar: nem número, nem depoimento, nem característica.
- `produtos/exemplo/` é fictício e serve só para testes; nunca o ative.
- O repositório de cada usuário é **privado**. Nunca torne público um repositório com `produtos/<id>/` ou `state/` reais.
