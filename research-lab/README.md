# 🧪 research-lab/ — Laboratório de Experimentos & Desenvolvimento

> *"Teoria é quando você sabe tudo e nada funciona. Prática é quando tudo funciona e ninguém sabe o porquê. Neste laboratório, unimos a teoria à prática para que nada funcione sem que saibamos o porquê."*

Welcome ao **`research-lab/`**. Este diretório é o espaço dedicado a testes de código, provas de conceito (PoCs), exercícios práticos e explorações de linguagem. É a área de bancada onde ideias de baixo nível são codificadas, testadas e desconstruídas antes de serem integradas em análises complexas ou ferramentas de segurança.

---

## 🎯 Propósito do Laboratório

O objetivo principal deste repositório é documentar a jornada de aprendizado e desenvolvimento prático em diversas linguagens e arquiteturas. Aqui guardamos:

* **Experimentos de Linguagem:** Protótipos e rotinas para entender peculiaridades de sintaxe, compiladores e gerenciamento de recursos em **Assembly (x86/x64)**, **C**, **C++**, **Rust** e **COBOL**.
* **Laboratórios & Desafios:** Resoluções práticas de rotinas do curso de Assembly & Reverse Engineering (TCM Security), exercícios de manipulação de memória e estudos de caso.
* **Internos de Sistemas:** Experimentos que envolvem ponteiros, estruturas de dados de baixo nível, *system calls* (syscalls), depuração (*debugging*) e gerenciamento de processos.
* **Mecânica de Aplicações:** Códigos limpos criados do zero para estudar como compiladores traduzem lógica abstrata em instruções de máquina.

---

## 🛠️ Linguagens & Domínios de Estudo

| Linguagem / Tecnologia | Foco dos Experimentos |
| :--- | :--- |
| **Assembly (IA-32 / x64)** | Instruções de CPU, registradores, convenções de chamada (*calling conventions*), manipulação de pilha (*stack*) e análise de *flow control*. |
| **C / C++** | Gerenciamento manual de memória (`malloc`/`free`, ponteiros), estruturas internas, desenvolvimento de rotinas do sistema e comportamento não definido (*undefined behavior*). |
| **Rust** | Garantias de *memory safety*, abstrações de zero custo (*zero-cost abstractions*) e comparação de performance/segurança com C. |
| **COBOL** | Processamento de dados estruturados, lógica de negócios legada e arquitetura de registros. |

---

## 📂 Estrutura Interna Recomendada

À medida que os estudos progridem, os projetos e rotinas são organizados em subdiretórios temáticos:

```text
research-lab/
├── assembly/        # Exercícios x86/x64, rotinas TCM Security e PoCs em ASM
├── c-cpp/           # Manipulação de ponteiros, alocação de memória e ferramentas de sistema
├── rust/            # Experimentos com gerenciamento de memória e concorrência segura
├── cobol/           # Estudos de arquiteturas legadas e processamento de dados
└── PoCs/            # Provas de Conceito isoladas para testes de conceitos de baixo nível
```

