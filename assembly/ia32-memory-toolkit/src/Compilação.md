

## 📑 Lab: IA32 Memory Toolkit - Workflow
Este guia detalha os procedimentos de compilação, execução e depuração para o toolkit desenvolvido em Assembly x86 (IA-32) no Linux.

## 1. Compilação (Otimizada para Segurança)
Usamos o gcc como front-end para o as (assembler) e o ld (linker).

Bash
gcc -m32 -no-pie hexdump_toolkit.s -o hexdump_toolkit
-m32: Força a compilação para arquitetura de 32 bits (IA-32).

-no-pie: Desabilita o Position Independent Executable. Isso fixa os endereços de memória, facilitando o estudo de offsets e debugging inicial.

.note.GNU-stack: (Interno ao código) Garante que a stack não seja executável, seguindo boas práticas de segurança moderna.

## 2. Execução
Para rodar o binário gerado:

Bash
./hexdump_toolkit
## 3. Debugging com GDB (The Low-Level Way)
O GDB é essencial para entender como os registradores estão mudando a cada instrução.

Iniciando o Debug
Bash
gdb ./hexdump_toolkit
Comandos Essenciais dentro do GDB:
Definir Layout: Para ver o código e os registradores simultaneamente:

Snippet de código
layout asm
layout regs
Breakpoints: Pare o programa na função principal ou em uma label específica:

Snippet de código
b main
b hexdump
Execução:

r (run): Inicia o programa.

si (step instruction): Executa uma instrução de assembly por vez.

ni (next instruction): Pula chamadas de função (como o printf).

Inspecionando a Memória:

info registers: Mostra o estado de todos os registradores.

x/16xb &ascii_buffer: Examina 16 bytes em formato hex no nosso buffer.

## 4. Troubleshooting Comum
Segmentation Fault: Geralmente causado por desbalanceamento da pilha (push sem pop correspondente antes de um ret). Verifique se o %esp voltou ao estado original.

ASCII sumindo: Verifique se os registradores %ebx ou %esi foram sobrescritos por uma chamada de biblioteca externa (como o printf).

Endianness: Lembre-se que no dump, o valor 0x12345678 aparecerá como 78 56 34 12 devido à arquitetura Little-Endian da Intel.
