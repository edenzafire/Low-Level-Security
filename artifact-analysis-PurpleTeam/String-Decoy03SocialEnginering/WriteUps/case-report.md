
# CASE REPORT: OPERATION LUTHIERIA FLAMENCA
**Author:** Nikolay (Zafire Daniel)  
**Date:** May 19, 2026  
**Category:** Malware Analysis / Artifact Deobfuscation  
**Target Artifact:** `Medidas_Paco_De_Lucia_Oficial_1971.exe`  
**Classification:** Purple Team Simulation  

---

### EXECUTIVE SUMMARY

This report details the technical analysis of a stealthy stage-1 loader utilized during a simulated social engineering campaign themed around historical flamenco luthiery ("Medidas Paco De Lucía 1971").

⚔️ Purple Team Lifecycle Bridges

🔴 Offensive Operations (Red Team): Phishing Campaign Implementation & Payload Delivery

🔵 Defensive Operations (Blue Team): Detection Engineering & CrowdSec Active Response Lab

The artifact was engineered as a dual-purpose payload: delivering an encrypted 64-bit Meterpreter shellcode via native Windows APIs while evading automated heuristic detection mechanisms. The simulation follows a strict Purple Team workflow, analyzing the offensive evasion vectors to optimize defensive infrastructure (CrowdSec containerized stack).

[Social Engineering Bait] 
          │
          ▼
[Spoofed Artifact (.exe)] ────► [Heuristic Evasion / Delay]
                                             │
                                             ▼
[Established Reverse Shell] ◄─── [Dynamic Memory XOR Decryption]


---

## 0x01. STATIC TRIAGE & ARCHITECTURAL RECONNAISSANCE

Initial static verification was conducted to determine file integrity, headers, and compiled imports before execution.

```bash
$ file Medidas_Paco_De_Lucia_Oficial_1971.exe
Medidas_Paco_De_Lucia_Oficial_1971.exe: PE32+ executable (GUI) x86-64 (stripped to external PDB), for MS Windows, 11 sections
````

> **Evidence Link:**

 ![screenshots](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/01File.png)

The `file` utility confirms this is a **64-bit Windows Portable Executable (PE32+)** with a Graphical User Interface (GUI) subsystem, containing 11 sections. The file was explicitly stripped to complicate analysis.

Bash

```
$ xxd Medidas_Paco_De_Lucia_Oficial_1971.exe | head -n 1
00000000: 4d44 5a90 0003 0000 0400 0000 ffff 0000  MZ..............
```

> **Evidence Link:** 

 ![screenshots](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/02xxd.png)

Hexadecimal validation confirms the standard DOS header magic bytes **`4d5a`** (`MZ`), mapping the entry point structure of a true executable file rather than a raw documentation format.

### 0x01.1. Import Table Inspection (`rabin2`)

Bash

```
$ rabin2 -i Medidas_Paco_De_Lucia_Oficial_1971.exe
```

> **Evidences Link:**

 ![screenshots1](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/03rabin.png)

 ![screenshots2](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/04rabin.png)

The extraction of imported APIs via `rabin2` highlighted critical primitives typically leveraged in process injection and memory-resident malware execution:

- **`KERNEL32.dll!CreateThread`**: Used to spawn execution blocks asynchronously.
    
- **`KERNEL32.dll!VirtualAlloc`**: Allocates raw memory pages outside standard stack/heap paradigms.
    
- **`KERNEL32.dll!VirtualProtect`**: Changes page permissions, essential for altering memory blocks from Read/Write (`RW`) to Execute (`RX`).
    
- **`KERNEL32.dll!Sleep`**: Employed for anti-analysis timing delays (throttling sandboxes).
    
- **`SHELL32.dll!ShellExecuteA`**: Capable of spawning the legitimate decoy process.
    

### 0x01.2. Embedded String Analysis

Bash

```
$ rabin2 -z Medidas_Paco_De_Lucia_Oficial_1971.exe
```

> **Evidence Link:** 
 ![screenshots5](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/05rabin2.png)

 ![screenshots6](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/06rabin2.png)

 ![screenshots7](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/07rabin2.png)

The string table exposed two crucial elements inside the `.rdata` section:

1. Virtualization drivers strings (`C:\windows\System32\Drivers\Vmmouse.sys`, `VBoxGuest.sys`) matching specific heuristic signatures designed for **Anti-Sandbox / VM Detection**.
    
2. The decoy reference file path: `Medidas_Paco_De_Lucia_Oficial_1971.pdf`, confirming the injection of a social engineering lure to mask execution.
    

---

## 0x02. LOW-LEVEL STATIC ANALYSIS (RADARE2)

The binary was loaded into `radare2` executing a full analysis flags iteration (`aa`).

Bash

```
$ r2 -A Medidas_Paco_De_Lucia_Oficial_1971.exe
[0x1400014b0]> afl
0x1400014b0    1 29   entry0
0x140001180   45 769  fcn.140001180
0x1400018b0   12 118  entry1
0x140001880    4 38   entry2
0x140002300   18 214  fcn.140002300
```

> **Evidence Link:** 
 ![screenshots8](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/08radare.png)

 ![screenshots9](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/09radare.png)

The core function table mapping isolates **`fcn.140001180`** as the main functional controller of the loader, executing immediately after the initial runtime initialization stub (`entry0`).

### 0x02.1. Disassembling the Loader Entry Point

Snippet de código

```
[0x1400014b0]> s fcn.140001180
[0x140001180]> pdf
```

> **Evidence Link:**
 ![screenshots10](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/10pdf.png)

 ![screenshots11](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/11pdf.png)

 ![screenshots12](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/12pdf.png)

Snippet de código

```
0x140001180      4154           push r12
0x140001182      55             push rbp
0x140001183      57             push rdi
0x140001184      56             push rsi
0x140001185      53             push rbx
0x140001186      4881ec900000.  sub rsp, 0x90
...
0x1400011c8      4c8b255170...  mov r12, qword [sym.imp.KERNEL32.dll_Sleep]
0x1400011cf      eb18           jmp 0x1400011e9
```

The function prologue establishes a standard stack frame reserving `0x90` bytes. Crucially, the pointer to `KERNEL32.dll!Sleep` is loaded into the **`r12`** register at address `0x1400011c8`.

### 0x02.2. Tracking Control Flow Obstruction (`pif`)

To evaluate how the loader hides its critical calls from automated runtime inspection, the program flow was queried for indirect execution branches:

Snippet de código

```
[0x140001180]> pif ~ call
0x1400011e5   call r12
0x14000122e   call rax
```

> **Evidence Link:** 

 ![screenshots13](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/13pdf.png)

 ![screenshots14](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/14pdf.png)

 ![screenshots15](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/15pif.png)


Snippet de código

```
0x1400011e1   b9e8030000     mov ecx, 0x3e8      ; 1000 milliseconds (Loop Controller)
0x1400011e6   41ffd4         call r12            ; Sleep()
```

The execution flow reveals an obfuscated loop pattern. Instead of issuing a single long sleep call, it loads `0x3e8` (1000 ms) inside a conditional iteration block checking system uptime metrics to verify environment legitimacy before executing the payload. The shellcode activation is bound to `call rax`, where **`rax`** receives the dynamic address returned by `VirtualAlloc`.

---

## 0x03. RUNTIME ANALYSIS & MEMORY INSPECION (GDB)

To completely bypass the anti-analysis delays and catch the un-obfuscated shellcode, a cross-compiled Linux binary version of the loader (`veneno_linux.bin`) was analyzed using the **GNU Debugger (GDB)**.

Bash

```
$ gdb ./veneno_linux.bin
(gdb) break decrypt
(gdb) continue
```

> **Evidence Link:** 

 ![screenshots16](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/16gdbini.png)

 ![screenshots18](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/18gdb.png)

The breakpoint successfully halted execution at the signature XOR loop entry point:

Plaintext

```
Breakpoint 4, decrypt (data=0x555555558080 <payload>, len=509, key=119 'w') at veneno_linux.cpp:47
47          for (unsigned int i = 0; i < len; i++) {
```

The debugger extracts the precise configuration parameters in runtime:

- **`data`** Pointer Target: `0x555555558080`
    
- **`len`** (Payload Size): `509 bytes`
    
- **`key`** (XOR Obfuscation Key): `119` (Decimal) -> **`0x77`** (Hexadecimal)
    

### 0x03.1. Pre-Decryption RAM State

Before loop processing, the raw memory area was dumped to inspect the high-entropy state:

Plaintext

```
(gdb) x/20xb payload
0x555555558080 <payload>:   0x8b   0x3f   0xf4   0x93   0x87   0x9f   0xbb   0x77
0x555555558088 <payload+8>: 0x77   0x77   0x36   0x26   0x36   0x27   0x25   0x3f
0x555555558090 <payload+16>:0x46   0xa5   0x26   0x21
```

> **Evidence Link:** 

 ![screenshots17](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/17gdb20xb.png)

 ![screenshots19](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/19ggdb.png)


The memory contents verify complete obfuscation, starting with the random byte sequence `0x8b 0x3f 0xf4`. Notably, bytes 7, 8, and 9 are identified as **`0x77 0x77 0x77`**.

### 0x03.2. Post-Decryption State & Signature Carving

The function was forced to run until completion using the `finish` routine, popping the execution stack right after the loop unrolled:

Plaintext

```
(gdb) finish
Run till exit from #0  decrypt (...) at veneno_linux.cpp:47
(gdb) x/20xb payload
0x555555558080 <payload>:   0xfc   0x48   0x83   0xe4   0xf0   0xe8   0xcc   0x00
0x555555558088 <payload+8>: 0x00   0x00   0x41   0x51   0x41   0x50   0x52   0x48
0x555555558090 <payload+16>:0x31   0xd2   0x51   0x56
```

> **Evidence Link:** 

 ![screenshots20](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/20gdbfinish.png)

The memory inspection reveals a critical, definitive mutation:

1. **XOR Collision Cancellation:** The bytes at `<payload+8>` (`0x77 0x77 0x77`) colided with the key `0x77`: **0x77 XOR 0x77 = 0x00** They transformed exactly into **`0x00 0x00 0x00`**, proving the accuracy of the key extraction.
    
2. **Signature Carving (Metasploit x64):** The initial 5 bytes unrolled into: **0xfc 0x48 0x83 0xe4 0xf0**
    

This structural sequence represents a highly recognizable low-level signature:

- `0xfc` -> **`CLD`** (Clear Direction Flag), stabilizing string manipulation operations in x86_64 architecture.
    
- `0x48 0x83 0xe4 0xf0` -> **`AND RSP, 0xFFFFFFFFFFFFFFF0`**, forcing a 16-byte stack alignment to prevent access violations during foreign API transitions.
    

This confirms the presence of an active **Metasploit Framework (Meterpreter) Windows x64 shellcode** staged in the allocation buffer.

---

## 0x04. GRAPH CONTROL FLOW VALIDATION (GHIDRA)

To map out the execution tree and validate the logic paths of the compiled PE file, the artifact was imported into the Ghidra CodeBrowser suite.

```
[Entry Stub / entry] ---> Calls [FUN_140001180] (Main Payload Controller)
```

> **Evidence Link:** 

 ![screenshots21](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/21Ghidra01.png)

The decompiler output tracks the initialization vectors, confirming that the standard `entry` structure hands over control execution to **`FUN_140001180`**, bypassing traditional runtime traps.

### 0x04.1. Pseudo-Code Correlative Decompilation

C++

```
ulonglong FUN_140001180(undefined8 param_1, undefined8 param_2...) {
    char *pcVar1;
    longlong lVar5;
    ...
    GetStartupInfoA(&local_98);
    if (DAT_1400070a0 != 0) {
        // Obfuscated execution branches block
    }
}
```

> **Evidence Link:**

 ![screenshots22](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/22Ghidra02.png)

Ghidra’s high-level descompilation structuralizes the initial assembly block. It maps stack pointer variable initializations alongside automated `GetStartupInfoA` acquisition queries used to verify if execution parameters were altered by debug environments.

### 0x04.2. Control Flow Graph Topology (CFG)

```
             [Initial Entry Block]
                       |
                       v
             [Sandbox Checking Nodes]
              /                     \
    (True Branch)                 (False Branch)
         /                               \
[Decoy PDF Spawn Path]        [XOR Decryption Core]
         |                               |
         \                               v
          +----------> [Exit Node] <-----+
```

> **Evidence Link:** 

 ![screenshots23](https://github.com/edenzafire/Low-Level-Security/blob/main/artifact-analysis-PurpleTeam/String-Decoy03SocialEnginering/screenshots/23Ghidra03.png)

The **Function Graph** visualizes the physical splitting points of execution branches:

- **Green Edges (True Paths):** Direct execution loops associated with standard environmental setups.
    
- **Red Edges (False/Conditional Deviations):** Represent automated redirection paths executed if the timing checks fail or virtualization markers are hit, shifting the payload execution out of the active loop to silently terminate without deploying the reverse connection.
    

---

## 0x05. BLUE TEAM TELEMETRY & MITIGATION ARCHITECTURE

To finalize the Purple Team workflow, the deployment behavior of this artifact was cross-examined against defensive infrastructure telemetry.

### 0x05.1. Delivery Tracking (Apache Container Logs)

The delivery vector simulates an internal network link leading to the staging area. Server monitoring tracked the acquisition request:

Plaintext

```
172.20.0.1 - - [19/May/2026:15:31:02 -0300] "GET /phishing/Medidas_Paco_De_Lucia_Oficial_1971.exe HTTP/1.1" 200 48293 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64)..."
```

### 0x05.2. CrowdSec Container Defense Integration

The simulated infrastructure incorporates a **CrowdSec security agent** container mounted over Debian 12 to detect structural web exploitation or brute-force tracking used to locate payload repositories.

- **Heuristic Mitigation Layer:** While the loader successfully evades simple endpoint file hashes through its localized runtime XOR layer, its outer delivery vector was thwarted at the web layer.
    
- **Scenario Triggers:** Repeated directory indexing queries looking for `.exe` artifacts triggered the `crowdsecurity/http-crawl-non_exist` and custom file access scenarios.
    
- **Remediation:** The CrowdSec local API communicated an infrastructure block, automatically spawning an `iptables` / `nftables` drop decision against the offending source IP, breaking the delivery pipeline before execution could be established.
    

---

## FINAL LAB CONCLUSION

The "Operação Luthieria Flamenca" artifact demonstrates high structural efficiency in masking well-known command and control agents via simple binary level obfuscation.

1. **Static Analysis** successfully extracted the pretext and structural API definitions, highlighting intentional evasion layout.
    
2. **Dynamic Manipulation (GDB)** completely neutralizes the layer of protection, proving that obfuscated assets can be unrolled and signature-fingerprinted within volatile memory buffers.
    
3. **Graph Analysis (Ghidra)** confirmed the defensive importance of identifying environmental timing logic loops.
    
4. **Mitigation Orchestration** proves that multi-layered detection (combining host telemetry with CrowdSec tracking layers) provides a robust defense structure, successfully denying automated execution even against targeted payloads.
