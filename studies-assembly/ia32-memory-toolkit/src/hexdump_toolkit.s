# =================================================================
# Tool Name: IA32-Memory-Toolkit (Portfolio Edition)
# Autor: Nikolay (Zafire Daniel)
# Baseado no Curso: Assembler para Programadores C (Intuit.ru)
# Objetivo: Estudo de Endianness, Stack Frames e Alinhamento
# =================================================================

.section .data
    # Cabeçalho decorativo para o terminal
    header:           .string "---[ IA32 MEMORY DUMP ]---\nOFFSET    HEX DATA                                 ASCII\n"
    
    # Formatações do printf
    format_offset:    .string "%08x  "
    format_hex:       .string "%02x "
    format_space:     .string "   "
    format_ascii:     .string "%c"
    format_separator: .string " | "
    newline:          .string "\n"

    # Dados de teste
    input_string:     .ascii "Portfol-Linux"
    input_string_len = . - input_string
    test_value:       .long 0x12345678

.section .bss
    .lcomm ascii_buffer, 16

.section .text
.global main
.extern printf

# --- Função: print_ascii_char(char) ---
# Trata caracteres não imprimíveis para evitar quebrar o terminal
print_ascii_char:
    pushl %ebp
    movl %esp, %ebp
    
    movzbl 8(%ebp), %eax  # Garante limpeza total do registrador EAX
    
    # Filtro: Caracteres imprimíveis estão entre 32 (espaço) e 126 (~)
    cmpb $32, %al
    jl is_dot
    cmpb $126, %al
    jg is_dot
    jmp do_print_final

is_dot:
    movl $'.', %eax       # Substitui caracteres lixo por ponto

do_print_final:
    pushl %eax
    pushl $format_ascii
    call printf
    addl $8, %esp

    leave
    ret

# --- Função: hexdump(ptr, size) ---
hexdump:
    pushl %ebp
    movl %esp, %ebp
    pushl %ebx
    pushl %edi
    pushl %esi

    movl 8(%ebp), %esi    # Endereço dos dados de entrada
    movl 12(%ebp), %ecx   # Tamanho total a ser processado
    xorl %edi, %edi       # EDI = Offset (começa em 0)
    xorl %ebx, %ebx       # EBX = Contador de colunas (0-15)

loop_start:
    cmpl $0, %ecx
    je finish_up

    # Se EBX é 0, iniciamos uma nova linha imprimindo o Offset
    testl %ebx, %ebx
    jnz skip_off
    pushl %ecx
    pushl %edi
    pushl $format_offset
    call printf
    addl $8, %esp
    popl %ecx

skip_off:
    movzbl (%esi), %edx   # Lê 1 byte da memória para EDX
    
    # Prepara impressão do Hexadecimal
    pushl %ecx            
    pushl %edx            
    pushl %edx            # Empilha o byte para uso posterior
    pushl $format_hex
    call printf
    addl $8, %esp
    popl %edx             
    popl %ecx             

    # Salva o byte no buffer temporário para a coluna ASCII
    movb %dl, ascii_buffer(%ebx)

    incl %ebx
    incl %esi             
    incl %edi             
    decl %ecx

    # Se chegamos a 16 colunas, encerramos a linha com a parte ASCII
    cmpl $16, %ebx
    jne loop_start

    call print_full_line
    xorl %ebx, %ebx       # Reseta contador de colunas
    jmp loop_start

finish_up:
    # Caso a última linha seja menor que 16 bytes, aplica padding (espaçamento)
    testl %ebx, %ebx
    jz exit_now
    
    movl %ebx, %edi       
pad:
    cmpl $16, %ebx
    je print_last
    pushl $format_space
    call printf
    addl $4, %esp
    incl %ebx
    jmp pad

print_last:
    movl %edi, %ebx
    call print_full_line

exit_now:
    popl %esi
    popl %edi
    popl %ebx
    leave
    ret

# --- Função: print_full_line ---
# Imprime a barra separadora e percorre o buffer ASCII
print_full_line:
    pushl %ebx
    pushl $format_separator
    call printf
    addl $4, %esp
    popl %ebx

    xorl %esi, %esi       # Índice do buffer
ascii_loop_final:
    cmpl %esi, %ebx
    je end_line
    
    movzbl ascii_buffer(%esi), %eax
    
    # Preservação de contexto antes da chamada de sub-função
    pushl %ebx            
    pushl %esi
    pushl %eax            
    call print_ascii_char
    addl $4, %esp
    popl %esi
    popl %ebx
    
    incl %esi
    jmp ascii_loop_final

end_line:
    pushl $newline
    call printf
    addl $4, %esp
    ret

# --- Ponto de Entrada Principal ---
main:
    pushl %ebp
    movl %esp, %ebp
    
    pushl $header
    call printf
    addl $4, %esp

    # Teste 1: String
    pushl $input_string_len
    pushl $input_string
    call hexdump
    addl $8, %esp

    # Teste 2: Inteiro (Visualização de Little-Endian)
    pushl $4
    pushl $test_value
    call hexdump
    addl $8, %esp

    movl $0, %eax
    leave
    ret

# Proteção contra pilha executável (Padrão de Segurança)
.section .note.GNU-stack,"",@progbits
