@echo off
REM Build script para Shell 1.0
REM Requer: NASM e ML64 (Windows SDK)

echo [+] Compilando Assembly Reverse Shell 1.0...

REM Compilar com NASM
nasm -f win64 shell.asm -o shell.obj
if errorlevel 1 (
    echo [!] Erro na compilacao
    exit /b 1
)

REM Linkar com MSVC Linker
link /SUBSYSTEM:CONSOLE /ENTRY:main shell.obj ws2_32.lib /OUT:shell.exe
if errorlevel 1 (
    echo [!] Erro no link
    exit /b 1
)

echo [+] Shell compilado com sucesso: shell.exe
echo [+] Tamanho: %~z1 shell.exe
pause
