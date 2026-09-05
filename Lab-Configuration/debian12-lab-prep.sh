#!/bin/bash
# ============================================================================
#  debian12-lab-prep.sh
#  Script de automação para preparar uma VM Debian 12 para:
#    - Análise de binários
#    - Estudos de malware
#    - Desenvolvimento / Engenharia reversa
# ============================================================================
#  Uso:
#    chmod +x debian12-lab-prep.sh
#    sudo ./debian12-lab-prep.sh          # modo interativo (pergunta tudo)
#    sudo ./debian12-lab-prep.sh --full   # instala TUDO sem perguntar
#    sudo ./debian12-lab-prep.sh --min    # instala só o essencial
# ============================================================================

set -euo pipefail   # Para o script se qualquer comando falhar

# ===== CORES PARA OUTPUT =====
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ===== VARIÁVEIS GLOBAIS =====
LOG_FILE="/tmp/debian12-lab-prep-$(date +%Y%m%d-%H%M%S).log"
INSTALL_ALL=false
INSTALL_MIN=false
USER_HOME="$HOME"

# ===== FUNÇÃO: CABEÇALHO =====
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       🛠️  Debian 12 — Lab de Binários & Malware            ║"
    echo "║       Script de automação para engenharia reversa           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ===== FUNÇÃO: LOG =====
log() {
    echo -e "${GREEN}[✓]${NC} $1"
    echo "[$(date '+%H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
    echo "[$(date '+%H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    echo "[$(date '+%H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

# ===== FUNÇÃO: VERIFICA ROOT =====
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error "Este script precisa ser executado como root (sudo)."
        exit 1
    fi
}

# ===== FUNÇÃO: DETECTA DEBIAN 12 =====
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        warn "Não foi possível detectar a distribuição. Continuando mesmo assim..."
        return
    fi
    
    source /etc/os-release
    if [[ "$ID" != "debian" ]] || [[ "$VERSION_ID" != "12"* ]]; then
        warn "Este script foi feito para Debian 12. Detectado: $NAME $VERSION_ID"
        echo -n "Deseja continuar mesmo assim? (s/N): "
        read -r resp
        [[ "$resp" != "s" && "$resp" != "S" ]] && exit 0
    fi
}

# ===== FUNÇÃO: ATUALIZA SISTEMA =====
system_update() {
    log "Atualizando lista de pacotes e sistema..."
    apt-get update -y >> "$LOG_FILE" 2>&1
    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    log "Sistema atualizado."
}

# ===== FUNÇÃO: FERRAMENTAS ESSENCIAIS =====
install_essentials() {
    log "━━━ Instalando ferramentas essenciais do sistema ━━━"
    
    # build-essential: gcc, g++, make e headers do kernel
    # git: controle de versão
    # curl / wget: download de arquivos
    # unzip / p7zip / xz-utils: compressão/descompressão
    # vim / nano: editores de texto
    # htop / iotop: monitoramento
    # tmux / screen: multiplexador de terminal
    # net-tools / iproute2: rede
    # ca-certificates: certificados SSL
    
    apt-get install -y \
        build-essential \
        git \
        curl \
        wget \
        unzip \
        p7zip-full \
        xz-utils \
        bzip2 \
        gzip \
        tar \
        vim \
        nano \
        htop \
        iotop \
        tmux \
        screen \
        net-tools \
        iproute2 \
        ca-certificates \
        software-properties-common \
        apt-transport-https \
        lsb-release \
        gnupg \
        file \
        tree \
        >> "$LOG_FILE" 2>&1
    
    log "Essenciais instalados."
}

# ===== FUNÇÃO: FERRAMENTAS DE ANÁLISE DE BINÁRIOS =====
install_binary_tools() {
    log "━━━ Instalando ferramentas de análise de binários ━━━"
    
    # ----------------------------------------------------------------
    # 1. radare2 — Framework completo de engenharia reversa
    #    (desassembler, debugger, analisador binário)
    # ----------------------------------------------------------------
    log "Instalando radare2..."
    apt-get install -y radare2 >> "$LOG_FILE" 2>&1 || {
        warn "radare2 não disponível nos repositórios. Instalando via git..."
        if [[ ! -d /opt/radare2 ]]; then
            git clone --depth=1 https://github.com/radareorg/radare2 /opt/radare2 >> "$LOG_FILE" 2>&1
            cd /opt/radare2 && ./sys/install.sh >> "$LOG_FILE" 2>&1
            cd "$OLDPWD"
        fi
    }
    
    # ----------------------------------------------------------------
    # 2. rizin — Fork do radare2 com foco em usabilidade
    # ----------------------------------------------------------------
    log "Instalando rizin..."
    apt-get install -y rizin >> "$LOG_FILE" 2>&1 || {
        warn "rizin não disponível. Pulando (radare2 cobre)."
    }
    
    # ----------------------------------------------------------------
    # 3. Cutter — GUI para radare2/rizin (usando AppImage)
    # ----------------------------------------------------------------
    log "Instalando Cutter (GUI reversa)..."
    if [[ ! -f /opt/cutter/Cutter ]]; then
        mkdir -p /opt/cutter
        CUTTER_URL=$(curl -s https://api.github.com/repos/rizinorg/cutter/releases/latest | \
                     grep "browser_download_url" | grep "Linux-x86_64.AppImage" | cut -d'"' -f4)
        if [[ -n "$CUTTER_URL" ]]; then
            wget -q -O /opt/cutter/Cutter.AppImage "$CUTTER_URL" >> "$LOG_FILE" 2>&1
            chmod +x /opt/cutter/Cutter.AppImage
            ln -sf /opt/cutter/Cutter.AppImage /usr/local/bin/cutter
            log "Cutter AppImage instalado em /opt/cutter/"
        else
            warn "Não foi possível baixar Cutter. Faça manualmente depois."
        fi
    fi
    
    # ----------------------------------------------------------------
    # 4. objdump / readelf / strings — GNU binutils
    # ----------------------------------------------------------------
    apt-get install -y binutils >> "$LOG_FILE" 2>&1
    # strings já vem no binutils — extrai strings legíveis de binários
    
    # ----------------------------------------------------------------
    # 5. xxd / hexdump — visualização hexadecimal
    # ----------------------------------------------------------------
    apt-get install -y xxd vim-common >> "$LOG_FILE" 2>&1  # xxd vem com vim-common
    
    # ----------------------------------------------------------------
    # 6. Ghidra — Plataforma de reversa da NSA (via Java)
    # ----------------------------------------------------------------
    log "Preparando Ghidra (requer Java 17+)..."
    apt-get install -y openjdk-17-jdk openjdk-17-jre >> "$LOG_FILE" 2>&1
    
    if [[ ! -d /opt/ghidra ]]; then
        GHIDRA_URL="https://github.com/NationalSecurityAgency/ghidra/releases/latest/download/ghidra_11.2.1_PUBLIC_20250219.zip"
        warn "Baixando Ghidra (~500MB) de: $GHIDRA_URL"
        wget -q -O /tmp/ghidra.zip "$GHIDRA_URL" >> "$LOG_FILE" 2>&1 || {
            warn "Download automático falhou. Instale manualmente de: https://ghidra-sre.org/"
        }
        if [[ -f /tmp/ghidra.zip ]]; then
            unzip -q /tmp/ghidra.zip -d /opt/ >> "$LOG_FILE" 2>&1
            mv /opt/ghidra_* /opt/ghidra 2>/dev/null || true
            # Cria link simbólico
            GHIDRA_DIR=$(ls -d /opt/ghidra* 2>/dev/null | head -1)
            if [[ -n "$GHIDRA_DIR" ]]; then
                ln -sf "$GHIDRA_DIR/ghidraRun" /usr/local/bin/ghidra
                log "Ghidra instalado em $GHIDRA_DIR"
            fi
            rm -f /tmp/ghidra.zip
        fi
    else
        log "Ghidra já existe em /opt/ghidra"
    fi
    
    # ----------------------------------------------------------------
    # 7. NASM / Yasm — Montadores assembly
    # ----------------------------------------------------------------
    apt-get install -y nasm yasm >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 8. UPX — Empacotador/desempacotador de executáveis
    # ----------------------------------------------------------------
    apt-get install -y upx-ucl >> "$LOG_FILE" 2>&1
    
    log "Ferramentas de análise de binários instaladas."
}

# ===== FUNÇÃO: DEBUGGERS =====
install_debuggers() {
    log "━━━ Instalando debuggers ━━━"
    
    # ----------------------------------------------------------------
    # 1. GDB — GNU Debugger (base)
    # ----------------------------------------------------------------
    apt-get install -y gdb gdb-multiarch >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 2. pwndbg — Plugin GDB focado em exploit dev / reversa
    # ----------------------------------------------------------------
    if [[ ! -d "$USER_HOME/.pwndbg" ]]; then
        log "Instalando pwndbg..."
        git clone https://github.com/pwndbg/pwndbg "$USER_HOME/.pwndbg" >> "$LOG_FILE" 2>&1
        cd "$USER_HOME/.pwndbg"
        ./setup.sh >> "$LOG_FILE" 2>&1 || warn "setup pwndbg encontrou issues, mas continuando"
        cd "$OLDPWD"
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.pwndbg" 2>/dev/null || true
    fi
    
    # ----------------------------------------------------------------
    # 3. GEF — Outro excelente plugin GDB
    # ----------------------------------------------------------------
    if [[ ! -f "$USER_HOME/.gdbinit-gef.py" ]]; then
        log "Baixando GEF (GDB Enhanced Features)..."
        wget -q -O "$USER_HOME/.gdbinit-gef.py" https://github.com/hugsy/gef/raw/main/gef.py >> "$LOG_FILE" 2>&1
        chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.gdbinit-gef.py" 2>/dev/null || true
    fi
    
    # ----------------------------------------------------------------
    # 4. peda — Python Exploit Development Assistant
    # ----------------------------------------------------------------
    if [[ ! -d "$USER_HOME/.peda" ]]; then
        log "Instalando peda..."
        git clone https://github.com/longld/peda "$USER_HOME/.peda" >> "$LOG_FILE" 2>&1
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.peda" 2>/dev/null || true
    fi
    
    # ----------------------------------------------------------------
    # 5. Configura .gdbinit com opção de escolher plugin
    # ----------------------------------------------------------------
    GDBINIT="$USER_HOME/.gdbinit"
    if [[ ! -f "$GDBINIT" ]]; then
        cat > "$GDBINIT" << 'EOF'
# ============================================================================
# .gdbinit personalizado — Escolha seu plugin:
#   1. pwndbg   (padrão) -> set it to source ~/.pwndbg/gdbinit.py
#   2. GEF              -> source ~/.gdbinit-gef.py
#   3. peda             -> source ~/.peda/peda.py
# ============================================================================
# Para trocar, descomente a linha do plugin desejado e comente os outros.
# Por padrão, usa pwndbg.

source ~/.pwndbg/gdbinit.py
# source ~/.gdbinit-gef.py
# source ~/.peda/peda.py

# Configurações úteis
set disassembly-flavor intel
set pagination off
set confirm off
EOF
        chown "$SUDO_USER:$SUDO_USER" "$GDBINIT" 2>/dev/null || true
        log ".gdbinit configurado com pwndbg como padrão."
    fi
    
    # ----------------------------------------------------------------
    # 6. lldb — Debugger LLVM (alternativa ao GDB)
    # ----------------------------------------------------------------
    apt-get install -y lldb >> "$LOG_FILE" 2>&1
    
    log "Debuggers configurados."
}

# ===== FUNÇÃO: FERRAMENTAS DE FORENSE / MALWARE =====
install_forensic_tools() {
    log "━━━ Instalando ferramentas forenses e de análise de malware ━━━"
    
    # ----------------------------------------------------------------
    # 1. binwalk — Scanner de firmware, análise de binários embarcados
    # ----------------------------------------------------------------
    apt-get install -y binwalk >> "$LOG_FILE" 2>&1 || {
        warn "binwalk não no repositório. Instalando via pip..."
        pip3 install binwalk 2>/dev/null || true
    }
    
    # ----------------------------------------------------------------
    # 2. foremost — Recuperação de arquivos por signatures
    # ----------------------------------------------------------------
    apt-get install -y foremost >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 3. YARA — Pattern matching para malware
    # ----------------------------------------------------------------
    apt-get install -y yara >> "$LOG_FILE" 2>&1
    
    # Regras YARA populares (malware) - opcional
    if [[ ! -d "$USER_HOME/yara-rules" ]]; then
        log "Baixando regras YARA públicas..."
        git clone --depth=1 https://github.com/Yara-Rules/rules "$USER_HOME/yara-rules" >> "$LOG_FILE" 2>&1
        chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/yara-rules" 2>/dev/null || true
    fi
    
    # ----------------------------------------------------------------
    # 4. Volatility 3 — Análise de memória forense
    # ----------------------------------------------------------------
    if ! command -v vol &> /dev/null; then
        log "Instalando Volatility 3..."
        git clone --depth=1 https://github.com/volatilityfoundation/volatility3 /opt/volatility3 >> "$LOG_FILE" 2>&1
        # Instala dependências Python
        pip3 install -r /opt/volatility3/requirements.txt >> "$LOG_FILE" 2>&1
        ln -sf /opt/volatility3/vol.py /usr/local/bin/vol
        chmod +x /opt/volatility3/vol.py
        log "Volatility 3 instalado. Use 'vol -h' para ajuda."
    fi
    
    # ----------------------------------------------------------------
    # 5. floss — FireEye's Strings Obfuscated (extrai strings ofuscadas)
    # ----------------------------------------------------------------
    if ! command -v floss &> /dev/null; then
        log "Instalando floss (FireEye)..."
        pip3 install floss >> "$LOG_FILE" 2>&1 || warn "floss pip falhou. Instale manualmente."
    fi
    
    # ----------------------------------------------------------------
    # 6. exiftool — Metadados de arquivos
    # ----------------------------------------------------------------
    apt-get install -y libimage-exiftool-perl >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 7. hashdeep / md5deep — Hash de arquivos
    # ----------------------------------------------------------------
    apt-get install -y hashdeep >> "$LOG_FILE" 2>&1
    
    log "Ferramentas forenses instaladas."
}

# ===== FUNÇÃO: REDE / ANÁLISE DE TRÁFEGO =====
install_network_tools() {
    log "━━━ Instalando ferramentas de rede ━━━"
    
    # ----------------------------------------------------------------
    # 1. Wireshark — Análise de pacotes
    # ----------------------------------------------------------------
    apt-get install -y wireshark tshark >> "$LOG_FILE" 2>&1
    # Permite que usuário não-root capture pacotes
    usermod -a -G wireshark "$SUDO_USER" 2>/dev/null || true
    warn "Para capturar sem root, faça logout/login ou execute: newgrp wireshark"
    
    # ----------------------------------------------------------------
    # 2. tcpdump — CLI de captura
    # ----------------------------------------------------------------
    apt-get install -y tcpdump >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 3. netcat — Diagnóstico e transferência
    # ----------------------------------------------------------------
    apt-get install -y netcat-openbsd >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 4. nmap — Scanner de rede (útil para lab)
    # ----------------------------------------------------------------
    apt-get install -y nmap >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 5. socat — Multipurpose relay
    # ----------------------------------------------------------------
    apt-get install -y socat >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # 6. inetsim — Simulador de serviços
    # ----------------------------------------------------------------
    apt-get install -y inetsim >> "$LOG_FILE" 2>&1 || {
        warn "inetsim não disponível. Baixando manualmente..."
    }
    
    log "Ferramentas de rede instaladas."
}

# ===== FUNÇÃO: PYTHON E BIBLIOTECAS =====
install_python_env() {
    log "━━━ Configurando ambiente Python ━━━"
    
    # ----------------------------------------------------------------
    # Python 3 e pip
    # ----------------------------------------------------------------
    apt-get install -y python3 python3-pip python3-dev python3-venv >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # Bibliotecas comuns para reversa/exploit
    # ----------------------------------------------------------------
    pip3 install --upgrade pip >> "$LOG_FILE" 2>&1
    pip3 install \
        pwntools \
        capstone \
        unicorn \
        keystone-engine \
        requests \
        beautifulsoup4 \
        cryptography \
        pefile \
        lief \
        frida-tools \
        mitmproxy \
        ipython \
        >> "$LOG_FILE" 2>&1
    
    log "Ambiente Python configurado com bibliotecas de segurança."
}

# ===== FUNÇÃO: FERRAMENTAS DE DESENVOLVIMENTO =====
install_dev_tools() {
    log "━━━ Instalando ferramentas de desenvolvimento ━━━"
    
    # ----------------------------------------------------------------
    # cmake / meson / ninja — Build systems
    # ----------------------------------------------------------------
    apt-get install -y cmake meson ninja-build >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # valgrind — Análise de memória
    # ----------------------------------------------------------------
    apt-get install -y valgrind >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # strace / ltrace — Syscall e library tracer
    # ----------------------------------------------------------------
    apt-get install -y strace ltrace >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # clang / llvm — Compilador alternativo
    # ----------------------------------------------------------------
    apt-get install -y clang lldb lld >> "$LOG_FILE" 2>&1
    
    # ----------------------------------------------------------------
    # Docker (opcional — para sandbox)
    # ----------------------------------------------------------------
    warn "Docker não será instalado automaticamente. Se quiser, execute:"
    echo "    curl -fsSL https://get.docker.com | sh"
    echo "  Depois adicione seu usuário ao grupo docker:"
    echo "    sudo usermod -aG docker \$USER"
    
    log "Ferramentas de desenvolvimento instaladas."
}

# ===== FUNÇÃO: CONFIGURAÇÕES FINAIS =====
final_config() {
    log "━━━ Configurações finais ━━━"
    
    # ----------------------------------------------------------------
    # Aliases úteis em .bashrc
    # ----------------------------------------------------------------
    BASHRC="$USER_HOME/.bashrc"
    
    # Só adiciona se não existir ainda
    if ! grep -q "### LAB ALIASES ###" "$BASHRC" 2>/dev/null; then
        cat >> "$BASHRC" << 'EOF'

### LAB ALIASES ###
alias hex="xxd"
alias hexdump="xxd"
alias asm="nasm -f elf64"
alias gdb-pwndbg="gdb -q"
alias gdb-gef="gdb -q -x ~/.gdbinit-gef.py"
alias gdb-peda="gdb -q -x ~/.peda/peda.py"
alias r2="radare2"
alias rizin="rizin"
alias strings="strings --all"
alias decode="base64 -d"
alias encode="base64"
alias myip="curl -s ifconfig.me"
alias lab-info="cat /etc/os-release && echo '---' && uname -a"
EOF
        log "Aliases adicionados ao .bashrc"
    fi
    
    # ----------------------------------------------------------------
    # Cria diretório de trabalho
    # ----------------------------------------------------------------
    LAB_DIR="$USER_HOME/lab"
    mkdir -p "$LAB_DIR"/{binarios,malware,scripts,notas,ferramentas}
    chown -R "$SUDO_USER:$SUDO_USER" "$LAB_DIR" 2>/dev/null || true
    log "Diretório de trabalho criado em: $LAB_DIR"
    
    # ----------------------------------------------------------------
    # Mensagem final
    # ----------------------------------------------------------------
    cat > "$USER_HOME/lab/README.md" << 'EOF'
# 🧪 Laboratório de Binários & Malware — Debian 12

## Estrutura de diretórios
~/lab/ ├── binarios/ # Amostras de binários para análise ├── malware/ # Amostras de malware (CUIDADO!) ├── scripts/ # Scripts de automação/ferramentas ├── notas/ # Anotações e writeups └── ferramentas/ # Ferramentas extras baixadas

## Ferramentas instaladas

### Análise de binários
- **radare2** / **rizin** — Reversa completa via terminal
- **Cutter** — GUI para radare2
- **Ghidra** — Reversa avançada (NSA)
- **objdump / readelf / strings** — GNU binutils
- **xxd / hexdump** — Visualização hexadecimal
- **UPX** — Empacotador/desempacotador

### Debugging
- **GDB** + **pwndbg** (padrão), **GEF**, **peda**
- **lldb** (LLVM)
- **strace / ltrace** — Syscall/ library tracer

### Forense / Malware
- **binwalk** — Análise de firmware
- **foremost** — Recovery de arquivos
- **YARA** + regras públicas
- **Volatility 3** — Análise de memória
- **floss** — Strings ofuscadas (FireEye)
- **exiftool** — Metadados

### Rede
- **Wireshark** / **tshark** — Captura e análise
- **tcpdump** / **nmap** — Diagnóstico
- **inetsim** — Simulador de serviços
- **netcat / socat** — Relays

### Desenvolvimento
- **gcc/g++/clang** — Compiladores
- **nasm/yasm** — Assembly
- **Python 3** + pwntools, capstone, unicorn, keystone, frida
- **cmake / meson / ninja** — Build systems
- **valgrind** — Análise de memória

## Proxy de rede (opcional)
Para isolar rede da VM da sua rede real, configure no QEMU/KVM:
- Rede interna (NAT) ou isolada
- Use `inetsim` para simular serviços quando offline
EOF
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/lab/README.md" 2>/dev/null || true
}

# ===== FUNÇÃO: INSTALAÇÃO MÍNIMA =====
install_minimal() {
    log "━━━ Modo mínimo: apenas ferramentas essenciais ━━━"
    install_essentials
    apt-get install -y gdb binutils python3 python3-pip xxd nasm strace ltrace >> "$LOG_FILE" 2>&1
    pip3 install pwntools capstone >> "$LOG_FILE" 2>&1
    log "Modo mínimo concluído."
}

# ===== FUNÇÃO: MENU INTERATIVO =====
interactive_menu() {
    echo ""
    echo "Escolha o que deseja instalar:"
    echo "  1) Tudo completo (full lab)   — ~2GB download"
    echo "  2) Apenas o mínimo essencial   — ~200MB"
    echo "  3) Personalizado (escolher categorias)"
    echo ""
    echo -n "Opção [1-3] (padrão: 1): "
    read -r opt
    
    case "${opt:-1}" in
        1)
            INSTALL_ALL=true
            ;;
        2)
            INSTALL_MIN=true
            ;;
        3)
            echo ""
            echo "Selecione as categorias (s/N):"
            
            echo -n "  Ferramentas essenciais do sistema? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_ESS=true || CAT_ESS=false
            
            echo -n "  Análise de binários (radare2, Ghidra, etc)? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_BIN=true || CAT_BIN=false
            
            echo -n "  Debuggers (GDB + plugins, lldb)? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_DBG=true || CAT_DBG=false
            
            echo -n "  Forense / Malware (YARA, Volatility, etc)? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_FOR=true || CAT_FOR=false
            
            echo -n "  Rede (Wireshark, nmap, etc)? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_NET=true || CAT_NET=false
            
            echo -n "  Python + bibliotecas de segurança? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_PY=true || CAT_PY=false
            
            echo -n "  Ferramentas de desenvolvimento? [s/N]: "
            read -r r; [[ "$r" == "s" || "$r" == "S" ]] && CAT_DEV=true || CAT_DEV=false
            
            # Executa conforme seleção
            [[ "$CAT_ESS" == true ]] && install_essentials
            [[ "$CAT_BIN" == true ]] && install_binary_tools
            [[ "$CAT_DBG" == true ]] && install_debuggers
            [[ "$CAT_FOR" == true ]] && install_forensic_tools
            [[ "$CAT_NET" == true ]] && install_network_tools
            [[ "$CAT_PY" == true ]] && install_python_env
            [[ "$CAT_DEV" == true ]] && install_dev_tools
            final_config
            return
            ;;
    esac
}

# ===== FUNÇÃO: VALIDAÇÃO PÓS-INSTALAÇÃO =====
post_validation() {
    log "━━━ Validando instalação ━━━"
    
    echo ""
    echo "  Ferramenta               Status"
    echo "  ───────────────────────────────────────────"
    
    for cmd in gdb radare2 cutter nasm upx python3 pip3 wireshark tshark nmap yara vol strace ltrace; do
        if command -v "$cmd" &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} $cmd"
        else
            echo -e "  ${YELLOW}✗${NC} $cmd (não encontrado no PATH)"
        fi
    done
    
    echo ""
    log "Validação concluída. Log salvo em: $LOG_FILE"
}

# ========================================================================
# MAIN
# ========================================================================
main() {
    show_banner
    check_root
    check_os
    
    echo "Log de instalação: $LOG_FILE"
    echo ""
    
    # Processa argumentos
    if [[ $# -gt 0 ]]; then
        case "$1" in
            --full|-f)
                INSTALL_ALL=true
                ;;
            --min|-m)
                INSTALL_MIN=true
                ;;
            --help|-h)
                echo "Uso: $0 [--full | --min | --help]"
                echo "  --full   Instala todas as ferramentas"
                echo "  --min    Instala apenas o mínimo"
                echo "  --help   Mostra esta ajuda"
                exit 0
                ;;
            *)
                echo "Argumento desconhecido: $1"
                echo "Uso: $0 [--full | --min | --help]"
                exit 1
                ;;
        esac
    fi
    
    # Início da instalação
    system_update
    
    if [[ "$INSTALL_ALL" == true ]]; then
        log "Modo FULL — instalando todas as ferramentas..."
        install_essentials
        install_binary_tools
        install_debuggers
        install_forensic_tools
        install_network_tools
        install_python_env
        install_dev_tools
        final_config
    elif [[ "$INSTALL_MIN" == true ]]; then
        install_minimal
        final_config
    else
        interactive_menu
        # Se não escolheu personalizado e não caiu nos casos acima
        if [[ "$INSTALL_ALL" == false && "$INSTALL_MIN" == false ]]; then
            # Já foi executado dentro do interactive_menu
            :
        fi
    fi
    
    # Se instalou completo e não passou pelo menu personalizado
    if [[ "$INSTALL_ALL" == true ]]; then
        final_config
    fi
    
    post_validation
    
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║           ✅  LABORATÓRIO PRONTO!                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "  📁 Diretório de trabalho: ~/lab/"
    echo "  📄 README: ~/lab/README.md"
    echo "  📋 Log: $LOG_FILE"
    echo ""
    echo "  ▶️  Recomendações pós-instalação:"
    echo "    1. Faça logout e login novamente (para grupos como wireshark)"
    echo "    2. Leia o README: cat ~/lab/README.md"
    echo "    3. Teste as ferramentas: gdb --version, radare2 -version"
    echo "    4. Configure snapshots da VM ANTES de analisar malware!"
    echo ""
}

# ===== EXECUÇÃO =====
main "$@"
