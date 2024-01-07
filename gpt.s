;section .bss
;    tape:    resb 1024
section .data
    tape:    times 1024 db 0
    dp:      dq tape

section .text
    global _start

_start:
    mov rsi, dp
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
.L0:
    cmp byte [rsi], 0
    je .L0_end
    inc rsi
    inc byte [rsi]
    inc rsi
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    dec rsi
    dec rsi
    dec byte [rsi]
    jmp .L0
.L0_end:
    inc rsi
    inc rsi
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    inc byte [rsi]
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    mov r10, rsi
    syscall
    dec rsi
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    mov r10, rsi
    syscall
    mov rax, 60 ; syscall: exit
    xor rdi, rdi
    syscall
