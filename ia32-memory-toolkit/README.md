## 🕵️  IA-32 Low-Level Toolkit

Low-level memory inspection toolkit written in IA-32 Assembly (x86 32-bit).

This repository contains exercises, experiments and tooling developed during my studies of IA-32 architecture, stack frames, memory addressing modes and debugging workflows.

The project demonstrates practical usage of:

* stack frame construction (EBP / ESP)
* pointer walking (ESI / EDI)
* loop control using ECX
* string instructions (LODSB / STOSB)
* conditional branching
* calling convention via stack parameters
* byte-level memory inspection
* ASCII classification
* hex dump engine implementation
* debugging with GDB

---

## Course Reference

This repository is based on the following academic training:

Course:
IA-32 Assembly Programming and Computer Architecture

Provider:
NOU INTUIT (Independent Non-Commercial Educational Organization "INTUIT")

Course link:
https://intuit.ru/studies/courses/3537/779/info

This coursework is part of my structured training path in:

* low-level programming
* reverse engineering foundations
* exploit development preparation
* memory analysis workflows

---

## Certificate

The certificate issued after course completion is included in this directory:

 **Certificado em Russo**  [certificateRu.jpg](https://github.com/edenzafire/Low-Level-Security/blob/main/ia32-memory-toolkit/docs/certificateRu.jpg)
 **Certificado em Inglês** [certificateIn.jpg](https://github.com/edenzafire/Low-Level-Security/blob/main/ia32-memory-toolkit/docs/certificateIn.jpg)

This certificate is also referenced in my CV as supporting evidence of IA-32 architecture training.

---

## Repository Structure

ia32-lowlevel-toolkit/

src/
Assembly source files

docs/
course certificate and technical notes

gdb/
debugging sessions and register inspection walkthroughs

screenshots/
execution output examples

writeups/
technical documentation and reverse-engineering style explanations

---

## Implemented Components

Current toolkit modules:

hex_ascii_dump()
Memory traversal and byte visualization engine

print_ascii()
ASCII printable range detection helper

string analyzer (planned extension)
character classification engine

---

## Example Output

---[ IA32 MEMORY DUMP ]---
OFFSET    HEX DATA                                 ASCII
00000000  50 6f 72 74 66 6f 6c 2d 4c 69 6e 75 78    | Portfol-Linux
00000000  78 56 34 12                               | xV4.
---

## Key Technical Insights

*Endianness Visualization*

A crucial part of this project is demonstrating Little-Endian memory storage.

Observation: Notice that the hex value 0x12345678 is displayed as 78 56 34 12.

Concept: In IA-32 architecture, the Least Significant Byte (LSB) is stored at the lowest memory address. This project serves as a practical demonstration of this discrepancy between human-readable hexadecimal and its physical representation in Intel-based systems.

## How to Build and Run

To compile on a 64-bit Linux system (like Debian/Ubuntu), you need `gcc-multilib`:

```bash
# Compile
gcc -m32 -no-pie src/hexdump_toolkit.s -o hexdump_toolkit
```

# Run
./hexdump_toolkit

## Technical Focus

This project emphasizes understanding of:

IA-32 calling conventions
stack-based parameter passing
register-level memory traversal
low-level debugging workflows
assembly-based tooling development

---

## Author

Zafire Daniel

Low-level security engineering student focused on:

reverse engineering
memory inspection tooling
assembly internals
system-level debugging

