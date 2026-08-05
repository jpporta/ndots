# Dev Orchestrator — AI Workflow Guide

Toolchain de desenvolvimento com IA: **OpenCode** (agente) + **OpenSpec** (spec-driven dev) + **Dev Orchestrator** (loop dev→QA automático).

---

## Ferramentas — Quando Usar Cada Uma

### OpenCode — O Agente

Executa tarefas de código. Use **diretamente** quando:

- Explorar uma codebase nova: `opencode` (TUI interativo)
- Fazer uma mudança pontual: `opencode run "corrige typo no header"`
- Debugar um erro específico: `opencode run "por que esse teste falha?" --thinking`
- Revisar um PR manualmente: `opencode pr 42`

Use via **orquestrador** quando:
- Implementar uma feature completa com spec (`dev-orchestrator build`)
- Precisar de QA automático depois do dev
- Quiser loop dev→QA sem babysitting

```bash
# Modos do OpenCode
opencode                          # TUI interativo (exploração)
opencode run "tarefa"             # one-shot (automação)
opencode run "..." --thinking     # vê o raciocínio do modelo
opencode run "..." -f arquivo.ts  # anexa contexto
```

### OpenSpec — O Spec Engine

Gerencia specs como source of truth. Use **diretamente** quando:

- Criar spec manualmente: `openspec new change minha-feature`
- Validar um spec existente: `openspec validate minha-feature --strict`
- Ver status de todos os changes: `openspec list --json`
- Arquivar spec concluído: `openspec archive minha-feature --yes`

Use via **orquestrador** quando:
- Quiser que a IA preencha o spec automaticamente (`dev-orchestrator spec`)
- O archive deve acontecer automático pós-QA-pass (`dev-orchestrator build`)

```bash
# Comandos OpenSpec que você mais usa
openspec list                          # o que está ativo?
openspec show minha-feature            # ler um spec
openspec validate minha-feature        # check pré-implementação
openspec status --change minha-feature # progresso dos artefatos
openspec instructions --change minha-feature  # o que o agente deve fazer
```

### Dev Orchestrator — O Script

Automatiza o loop completo. **Substitui** os comandos manuais acima no fluxo principal.

```
você tem ideia → spec → review → build → PR pronto
                     ↑        ↑        ↑
                orquestrador  você    automático
```

---

## Pré-requisitos

```bash
npm install -g opencode-ai@latest
npm install -g @fission-ai/openspec@latest
opencode auth login          # configura provider (OpenRouter, Anthropic, etc.)
```

---

## Comandos do Orquestrador

| Comando | O que faz |
|---|---|
| `dev-orchestrator init` | Configura repo (OpenSpec + .gitignore) — 1x por projeto |
| `dev-orchestrator spec <nome>` | Cria spec + worktree isolado + preenche spec via IA |
| `dev-orchestrator build <nome>` | Loop dev→QA (3 tentativas), merge automático se passar |
| `dev-orchestrator status` | Dashboard de features em andamento |
| `dev-orchestrator clean <nome>` | Remove worktree + branch (abortar feature) |

---

## Fluxo Completo

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐    ┌─────────────┐
│   init   │───→│  spec <nome> │───→│   [review]    │───→│ build <nome> │
│ (1x/proj)│    │ (orquestrador│    │ (você aprova) │    │ (dev→QA loop)│
└──────────┘    │   preenche)  │    └──────────────┘    └──────┬──────┘
                └──────────────┘                               │
                                          ┌────────────────────┘
                                          │ QA PASS → merge + archive
                                          │ QA FAIL → retry (3x max)
                                          └────────────────────────
```

### 1. Inicializar

```bash
cd ~/projetos/meu-app
dev-orchestrator init
```

### 2. Especificar feature

```bash
dev-orchestrator spec add-oauth
```

O que acontece internamente:
1. `openspec new change add-oauth --json` → cria templates
2. `git worktree add -b dev-flow/add-oauth ../.worktrees/add-oauth/ HEAD`
3. `npm install` dentro do worktree
4. `opencode run "preenche os specs lendo a codebase"` → orquestrador preenche spec.md, design.md, tasks.md

### 3. Revisar os specs (MOMENTO CRÍTICO)

```bash
# Ler o spec gerado
cat openspec/changes/add-oauth/spec.md
cat openspec/changes/add-oauth/design.md

# Validar
openspec validate add-oauth --strict

# Ajustar manualmente se quiser — edite os arquivos
vim openspec/changes/add-oauth/spec.md
```

> **Você é o gatekeeper aqui.** Se o spec não está certo, o build vai sair errado.  
> Gaste tempo revisando os specs — é o investimento mais rentável do fluxo.

### 4. Build (dev→QA loop)

```bash
dev-orchestrator build add-oauth
```

Loop:
```
Dev Phase ──→ OpenCode implementa + testa + commita
    │
    ▼
QA Phase ──→ OpenCode revisa: spec compliance, testes, regressões
    │
    ├── PASS → merge no main, archive spec, remove worktree ✅
    │
    └── FAIL → volta pro Dev (até 3 tentativas)
               falhou 3x → worktree mantido pra correção manual
```

### 5. Status dashboard

```bash
dev-orchestrator status
```

---

## Quando Sair do Orquestrador

O script cobre 90% dos casos. Saia dele quando:

| Situação | O que fazer |
|---|---|
| Spec ficou ruim e quero reescrever do zero | `openspec new change X` manual, preenche na mão |
| QA rejeitou e quero corrigir eu mesmo | `cd ../.worktrees/feature/` → edita → commita → `dev-orchestrator build feature` |
| Feature complexa demais pra um spec só | `openspec new change feature-pt1`, `openspec new change feature-pt2` |
| Quero iterar rápido sem spec | `opencode` TUI direto (pula o orquestrador) |
| Bug fix trivial (1-2 linhas) | `opencode run "fix: ..."` direto, nem cria spec |

---

## Paralelismo

Rode múltiplos features ao mesmo tempo:

```bash
# Terminal 1
dev-orchestrator build feature-a

# Terminal 2
dev-orchestrator build feature-b
```

Cada um em seu worktree isolado. O merge no main serializa no final — se houver conflito, o script para e avisa.

---

## Estrutura de Diretórios

```
~/projetos/meu-app/
├── src/
├── openspec/
│   ├── specs/                    # specs arquivados
│   └── changes/                  # specs ativos
│       └── add-oauth/
│           ├── spec.md
│           ├── design.md
│           └── tasks.md
├── .gitignore                    # inclui .worktrees/
└── ...

../.worktrees/
└── add-oauth/                    # worktree isolado
    ├── .git                      # branch: dev-flow/add-oauth
    ├── src/
    ├── node_modules/
    └── ...
```

---

## Opcional: Swarm Tools + .hive

Kanban mais visual, sem servidor:

```bash
npm install -g opencode-swarm-plugin
swarm setup
```

Dentro do OpenCode:
- `/swarm "tarefa"` — decompõe e spawna workers paralelos
- `/hive` — quadro kanban das tasks
- `/inbox` — mensagens entre agentes

O `.hive/` é uma pasta git-tracked. Independe do `dev-orchestrator`.