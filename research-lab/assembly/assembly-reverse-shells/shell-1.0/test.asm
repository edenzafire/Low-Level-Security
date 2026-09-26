BITS 64
default rel
section .data
    msg db "teste", 0
section .text
global main
main:
    lea rax, [msg]
    ret
