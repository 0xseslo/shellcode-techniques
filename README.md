# shellcode-techniques

A categorized collection of x86 and x86-64 Linux shellcodes, written in raw
assembly (NASM). Collected and refined while solving CTF pwn challenges —
no libc, no abstractions, just syscalls.

Each technique lives in its own folder with the `.asm` source, a short
`README.md` explaining what it does and when to use it, and the final
shellcode as ready-to-use bytes (`\x` escaped) you can paste straight into
an exploit script.

## Structure

```
shellcode-techniques/
├── x86/
│   ├── execve/
│   │   ├── execve.asm
│   │   ├── bytes.txt
│   │   └── README.md
│   ├── orw/
│   │   ├── orw.asm
│   │   ├── bytes.txt
│   │   └── README.md
│   └── openat_sendfile/
│       ├── openat_sendfile.asm
│       ├── bytes.txt
│       └── README.md
│
├── x64/
│   ├── execve/
│   │   ├── execve.asm
│   │   ├── bytes.txt
│   │   └── README.md
│   ├── orw/
│   │   ├── orw.asm
│   │   ├── bytes.txt
│   │   └── README.md
│   └── openat_sendfile/
│       ├── openat_sendfile.asm
│       ├── bytes.txt
│       └── README.md
│
└── README.md
```

Every technique folder follows the same three-file pattern:

| File | Purpose |
|---|---|
| `<name>.asm` | NASM source, commented, ready to assemble |
| `bytes.txt` | Final opcode bytes, `\x`-escaped, copy-paste ready |
| `README.md` | What it does, when it's useful, size, constraints |

## Categories

- **execve** — spawns `/bin/sh` via `execve()`. The classic.
- **orw** — open / read / write: reads a file (e.g. `flag.txt`) and writes
  its contents to stdout. Used when `execve` is blocked (seccomp, no shell
  access) but file read is allowed.
- **openat_sendfile** — opens a file with `openat()` and streams it out via
  `sendfile()`, without a manual read/write loop. Useful when `read`/`write`
  are filtered but `sendfile` isn't, or as a shorter alternative to `orw`.

More categories (reverse shell, bind shell, mmap stager, encoders) get added
as new folders following the same pattern.

## Per-technique README template

Each category's `README.md` follows this format:

```md
# <technique name>

## What it does
One or two sentences.

## Syscalls used
- syscall_name (number)
- ...

## When to use it
Short note on the scenario (e.g. seccomp blocks execve, no shell, etc.)

## Constraints / bad chars
Any null bytes, restricted characters, or known limitations.

## Size
N bytes

## Build
    nasm -f elf64 name.asm -o name.o
    ld name.o -o name

## Bytes
    "\x..."
```

## Tools

- **NASM** — assembler
- **GDB** — debugging
- **objdump** — disassembly / byte extraction (`objdump -d name | ...`)

## Environment

- OS: Linux
- Architectures: x86, x86-64

## Notes

Everything here is written and tested for CTF / learning purposes. Shellcodes
are kept minimal and, where relevant, null-free or restricted to a specific
charset (noted per technique) so they can survive common input filters.
