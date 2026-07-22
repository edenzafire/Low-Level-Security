# ⚙️ Assembly Research & Development (x86 / x64)

> *"High level languages tell the computer what to do; Assembly tells the computer how to think."*

Esta pasta é o centro de estudos focado no aprendizado e prática de programação em **Assembly (x86 e x64)**. Aqui estão centralizados os exercícios, provas de conceito (PoCs), análises de *stack frames* e laboratórios baseados no curso de Assembly & Reverse Engineering da **TCM Security**.

---

## 🎯 Objetivos do Estudo

* **Compreensão de Arquitetura:** Estudo detalhado de registradores (`EAX`/`RAX`, `EBX`/`RBX`, `ESP`/`RSP`, `EBP`/`RBP`, etc.), flag registers e gerenciamento da pilha de execução.
* **Convenções de Chamada (*Calling Conventions*):** Análise prática de `cdecl`, `stdcall`, `fastcall` e a convenção de chamada nativa x64 no Windows e Linux.
* **Mecânica de Instalação e Execução:** Manipulação direta de memória, instruções aritméticas/lógicas, saltos condicionais (`jmp`, `je`, `jne`) e controle de fluxo.
* **Conexão com Engenharia Reversa:** Mapeamento de rotinas compiladas em C/C++ para entendimento do código assembly gerado por compiladores (GCC/MSVC) e análise em depuradores (**x64dbg**, **Ghidra**, **GDB**).

---

## 📂 Estrutura de Pastas & Conteúdos

```text
assembly/
├── tcm-security/       # Exercícios, notas e desafios do curso da TCM Security
├── x86-32bit/          # Experimentos e rotinas focadas em arquitetura IA-32
├── x64-64bit/          # Módulos e práticas de Assembly moderno de 64 bits
└── docs-notes/         # Resumos de registradores, cheat-sheets de instruções e anotações
```


