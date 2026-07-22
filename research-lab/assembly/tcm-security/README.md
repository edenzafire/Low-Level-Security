# 🥊 TCM Security — Practical Assembly & Reverse Engineering

> *"Entender a instrução na CPU é a diferença entre quem apenas executa scripts e quem realmente domina o que o software faz."*

Este diretório é dedicado às anotações, laboratórios práticos e exercícios desenvolvidos ao longo do curso de **Assembly & Reverse Engineering** da **TCM Security**. O foco aqui é ir direto à raiz da execução, dissecando binários e entendendo o comportamento do sistema operacional no nível mais baixo possível.

---

## 📌 Por que este curso?

O material da TCM Security entrega uma base sólida e mão na massa para quem atua em segurança defensiva e ofensiva. Nesta jornada, o aprendizado foca em:

* **Desmistificar o Assembly:** Perder o medo de olhar para o código assembly no depurador e entender o fluxo lógico real de uma aplicação.
* **Mapeamento de Vulnerabilidades:** Compreender como falhas de corrupção de memória (*stack overflows*, estouro de inteiros) acontecem no nível de instrução.
* **Análise de Artefatos:** Desenvolver a habilidade de analisar payloads, droppers e malwares sem precisar do código-fonte original.

---

## 🛠️ Conteúdo & Tópicos Práticos

Os estudos estão organizados cobrindo os seguintes pilares:

| Módulo / Tópico | Conceitos Chave | Status |
| :--- | :--- | :---: |
| **Arquitetura & Registradores** | `EAX`/`RAX`, `EBX`/`RBX`, `ESP`/`RSP`, `EBP`/`RBP`, `EIP`/`RIP`, Flags | 🟢 Concluído |
| **Pilha & Memória (*Stack*)** | *Stack frames*, `push`, `pop`, alocação de variáveis locais | 🟢 Concluído |
| **Controle de Fluxo** | Saltos condicionais (`je`, `jne`, `jg`), instruções `cmp` e `test` | 🟡 Em Progresso |
| **Convenções de Chamada** | `cdecl`, `stdcall`, repasse de parâmetros e retorno de funções | 🟡 Em Progresso |
| **Engenharia Reversa Prática** | Análise estática/dinâmica com **x64dbg**, **Ghidra** e **GDB** | 📅 Planejado |

---

## 📂 Estrutura de Arquivos

```text
tcm-security/
├── 01-architecture-basics/  # Anotações sobre registradores e modelo de memória
├── 02-stack-manipulation/   # Exercícios práticos sobre a pilha de execução
├── 03-control-flow/         # Exemplos de desvios, condicionais e laços
├── labs/                    # Desafios práticos e binários analisados durante o curso
└── notes.md                 # Cheat-sheet rápida de instruções e atalhos de depuradores
```

