# 📂 Artifact Analysis & Binary Forensics
> **Status:** Investigação Ativa | **Nível:** Baixo Nível (Kernel/User Mode)

![Analysis](https://img.shields.io/badge/Analysis-Static%20%26%20Dynamic-orange?style=for-the-badge&logo=analogue)
![Reversing](https://img.shields.io/badge/Reversing-Ghidra%20%7C%20x64dbg-blueviolet?style=for-the-badge&logo=reverseengineering)
![Target](https://img.shields.io/badge/Target-PE%20%7C%20ELF%20%7C%20Shellcode-lightgrey?style=for-the-badge&logo=target)

Este diretório contém a documentação detalhada da análise de artefatos desenvolvidos ou capturados durante as operações de **Purple Teaming**. O objetivo aqui é entender o *payload* além da execução: dissecamos a interação com a CPU, memória e as chamadas de sistema (Syscalls).

---

## 🛠️ Metodologia de Análise
Para cada artefato, seguimos um fluxo de perícia padrão:

| Fase | Descrição | Ferramentas |
| :--- | :--- | :--- |
| **1. Estática** | Inspeção de Headers, Strings e Entropia. | `DIE`, `PeStudio`, `Binwalk` |
| **2. Dinâmica** | Monitoramento de comportamento e API Hooks. | `Strace`, `Ltrace`, `Wireshark` |
| **3. Reversa** | Desmontagem do fluxo de execução em ASM. | `Ghidra`, `x64dbg`, `GDB` |

---

## 🔬 Artefatos em Destaque

| Caso | Artefato | Técnica Principal | Status |
| :--- | :--- | :--- | :--- |
| **#01** | [Luthieria Dropper](./case-luthieria-dropper) | XOR Encoding & HTML Smuggling | ✅ Concluído |


---

## 🧰 Toolbox de Baixo Nível
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Assembly](https://img.shields.io/badge/Assembly-x86--64-red?style=for-the-badge&logo=assemblyscript&logoColor=white)

No meu ThinkPad E470, a análise foca em:
* **Binary Diffing:** Comparação de versões de código.
* **Deobfuscation:** Quebra de XOR e algoritmos customizados.
* **Memory Forensics:** Análise de dumps de memória RAM.

---

## 🛡️ Integração Purple Team
Os resultados obtidos alimentam o meu **[Portfólio de Blue Team](https://github.com/edenzafire/Blue_Team_Repo)**, transformando a análise em regras YARA e assinaturas de detecção reais.

> *"A análise de um artefato é a tradução da intenção do atacante em código."*

---
**Desenvolvido por Éden Zafire (Nikolay)**

