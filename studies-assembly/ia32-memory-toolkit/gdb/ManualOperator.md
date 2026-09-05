# 🛠️ Lab Report: IA32 Memory Toolkit & Reverse Engineering
**Autor:** Zafire Daniel (Nikolay)
**Ambiente:** Debian 12 (ThinkPad E470)
**Foco:** Assembly x86, Stack Frames e Endianness

---

## 1. Preparação do Ambiente (Setup)
Antes de começar, precisamos garantir que o sistema de 64 bits suporte a compilação e o debug de 32 bits.

```bash
# Atualizar repositórios e instalar ferramentas essenciais
sudo apt update
sudo apt install gcc-multilib gdb gdb-multiarch binutils -y
``` 

## 2. Compilação Blindada

Para o estudo de segurança, desabilitamos proteções modernas (como o PIE) para que os endereços de memória sejam fixos e fáceis de analisar no GDB.

Bash

```
# -m32: Alvo 32-bit (IA-32)
# -no-pie: Desabilita endereços aleatórios
gcc -m32 -no-pie src/hexdump_toolkit.s -o hexdump_toolkit
```

## 3. Workflow de Análise Dinâmica (GDB)

O GDB é usado para "abrir o capô" do programa enquanto ele executa na CPU.

### Comandos de Inicialização:

Snippet de código

```
gdb ./hexdump_toolkit
(gdb) set disassembly-flavor intel   # Sintaxe amigável (Intel)
(gdb) b main                         # Breakpoint no início
(gdb) run                            # Inicia a execução
(gdb) layout regs                    # Abre a visão de registradores
```

### Inspeção de Memória (O Teste de Endianness):

Para verificar como o valor `0x12345678` está guardado fisicamente:

Snippet de código

```
(gdb) x/4xb &test_value    # Ver bytes brutos (78 56 34 12) -> Little Endian
(gdb) x/1xw &test_value    # Ver valor lógico (0x12345678) -> Human Readable
```

## 4. Inspeção de Stack (Pilha)

Este passo é vital para entender como as funções recebem argumentos.

### Procedimento para capturar a Stack:

1. Defina um breakpoint na função de processamento: `b print_ascii_char`
    
2. Avance a execução: `continue` ou `run`
    
3. Quando o programa parar, limpe a tela (`shell clear`) para o print e digite:
    

Snippet de código

```
(gdb) x/8xw $esp
```

**O que observar no dump:**

- **$esp (Top):** Endereço de retorno (Return Address).
    
- **$esp + 4:** Primeiro argumento passado para a função (o caractere).
    

---

## 5. Interpretação dos Resultados

- **Hexdump Engine:** O código percorre a memória usando o registrador `%esi` como ponteiro e `%ecx` como contador.
    
- **Stack Preservation:** O uso de `push` e `pop` em torno das chamadas de `printf` é obrigatório, pois funções de biblioteca externa não garantem a preservação dos registros voláteis (`eax`, `ecx`, `edx`).
    
- **Endianness:** Confirmado que o processador Intel utiliza Little-Endian, invertendo a ordem dos bytes na memória física.
    

---

## 6. Comandos Úteis de Terminal

- **Limpar tela do GDB:** `shell clear`
    
- **Sair do modo TUI (Visual):** `Ctrl+X` seguido de `A`
    
- **Sair do GDB:** `q` ou `quit`

