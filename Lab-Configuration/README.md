## 📖 Guia de utilização

## 1️⃣ Salvar o script na VM Debian 12
** Dentro da VM, salve como debian12-lab-prep.sh:

# Você pode criar com nano/vim ou transferir via scp
```
nano debian12-lab-prep.sh

```
# Cole o conteúdo acima, salve (Ctrl+O, Ctrl+X)

## 2️⃣ Dar permissão de execução
```
chmod +x debian12-lab-prep.sh

```
## 3️⃣ Executar

** Modo completo (recomendado, ~2GB download):

```
sudo ./debian12-lab-prep.sh --full

```
** Modo mínimo (só o básão, 200MB):

```
sudo ./debian12-lab-prep.sh --min

```

** Modo interativo (escolhe o que instalar):

```
sudo ./debian12-lab-prep.sh

```

##  4️⃣ O que esperar
O script loga tudo em /tmp/debian12-lab-prep-<data>.log
Cada etapa mostra [✓] quando concluída
Se algo falhar, o script não para (warn) na maioria dos casos
##  5️⃣ Pós-instalação
bash



# Testar ferramentas principais
gdb --version
radare2 -version
python3 -c "from pwn import *; print('pwntools OK')"
strings --help

# Ver o README criado
cat ~/lab/README.md

# Navegar no lab
cd ~/lab && tree
##  6️⃣ Recomendações importantes


Item	Descrição
Snapshots	Antes de analisar malware de verdade, tire snapshot da VM
Rede isolada	Configure uma rede NAT ou isolada no QEMU/KVM para não contaminar sua rede real
Proxy / inetsim	Use inetsim para simular serviços quando a VM estiver offline
Atualizações	Rode sudo apt update && sudo apt upgrade regularmente
Anti-virus	Considere desabilitar o clamav se for manipular malware — ele pode deletar amostras




