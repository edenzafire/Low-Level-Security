# Assembly Reverse Shells - Windows x64

Coleção de shells reversos em Assembly para Windows 10, 
desenvolvidos para fins de estudo e portfólio Purple Team.

## Estrutura

| Versão | Descrição | Complexidade |
|--------|-----------|--------------|
| 1.0 | Socket básico + cmd.exe | Iniciante |
| 2.0 | + Obfuscation + Persistence | Intermediário |
| 3.0 | + Evasion + Multi-stage | Avançado |

## Shell 1.0

Shell reverso básico utilizando Winsock2 e CreateProcess.

### Compilação

```bash
nasm -f win64 shell.asm -o shell.obj
link /SUBSYSTEM:CONSOLE shell.obj ws2_32.lib /OUT:shell.exe
```

## Configuração

*    IP: Linha 25 (192.168.1.100)
*    Porta: Linha 26 (4444)

## Listener

```
nc -lvnp 4444

```
## Requisitos


*    NASM (Netwide Assembler)
*    Windows SDK (ML64 ou MSVC Linker)
*    Windows 10 x64

### Autor

Éden Zafire




