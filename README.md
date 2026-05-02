# 🛠️ Laboratório de Pesquisa e Segurança de Baixo Nível
> **Foco:** Engenharia Reversa, Internos de S.O. e Análise de Artefatos.

Nota: Este portfólio é o núcleo técnico que fundamenta minhas operações de **[Red Team](https://github.com/edenzafire/Red_Team_Repo)** (simulação de adversário) e [**Blue Team Operations**](https://github.com/edenzafire/Blue_Team_Repo). Aqui, o foco é entender o *payload* além da execução: analisamos o comportamento do binário na memória e a manipulação de instruções a nível de CPU.

---

## 📊 Visão Geral do Lab
![LowLevel](https://img.shields.io/badge/Focus-Reverse--Engineering-blueviolet?style=for-the-badge&logo=binary&logoColor=white)
![Architecture](https://img.shields.io/badge/Arch-x86--64%20%7C%20IA--32-blue?style=for-the-badge&logo=intel&logoColor=white)
![OS](https://img.shields.io/badge/OS-Linux%20%7C%20Windows--Internals-lightgrey?style=for-the-badge&logo=linux&logoColor=black)

---

## 📌 Sobre este Repositório
Este diretório é o meu "estaleiro" de engenharia. Aqui, centralizo projetos, experimentos e ferramentas para a compreensão profunda da interação entre software e hardware. A segurança, vista daqui, não é apenas uma configuração de rede, mas a integridade de cada *stack frame* e o controle sobre o fluxo de execução.

### 🛡️ O Elo do Purple Teaming
Neste repositório, os artefatos desenvolvidos no **Red Team** são dissecados para fechar o ciclo de defesa:
* **Do Red:** Trazemos o dropper, o exploit ou o shellcode.
* **No Low Level:** Analisamos a ofuscação (XOR, encodings) e as Syscalls em nível de instrução.
* **Para o Blue:** Geramos assinaturas de memória e indicadores de comportamento para detecção precisa.

---

## 📂 Estrutura de Organização
Para facilitar a navegação, os projetos estão categorizados por domínio técnico:

| Diretório | Descrição |
| :--- | :--- |
| **[`artifact-analysis/`](./artifact-analysis)** | Engenharia reversa de binários e análise de comportamento de payloads. |
| **[`ia32-memory-toolkit/`](./ia32-memory-toolkit)** | Ferramentas e estudos sobre manipulação de memória em arquitetura x86. |
| **[`research-lab/`](./research-lab)** | Experimentos fundamentais em ASM, C/C++, Rust e COBOL. |
| **[`docs/`](./docs)** | Diagramas de arquitetura, anotações de debug e whitepapers técnicos. |

---

## 🛠️ Áreas de Pesquisa
Os projetos armazenados aqui cobrem detalhes como:

* **Programação Assembly:** Desenvolvimento em IA-32 e x64.
* **C e C++:** Gerenciamento de memória, ponteiros e desenvolvimento de ferramentas de sistema.
* **Rust:** Exploração de segurança e desempenho de memória em sistemas modernos.
* **COBOL:** Estudo de lógica de processamento de dados e arquiteturas legadas resilientes.
* **Sistemas Internos:** Estudo de memória, gerenciamento de processos e stack frames.
* **Engenharia Reversa:** Documentação e análise de binários e fluxos de execução com x64dbg e Ghidra.

---

## 🚀 Filosofia
Este repositório segue a mentalidade **"Aprender fazendo"**. Acredito que a melhor forma de entender a segurança cibernética é construir e desconstruir ferramentas no nível mais fundamental possível.

> *"Em níveis mais baixos, nós confiamos."*

---

## 🤝 Contato e Contribuições
Se você é um entusiasta de arquitetura de computadores ou segurança, feedbacks e discussões sobre otimizações são sempre bem-vindos via Issues ou Pull Requests.

**Desenvolvido por Éden Zafire (Nikolay)**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/seu-perfil)
