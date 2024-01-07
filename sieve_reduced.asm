
%define MAX (0xffffffff)
%define COUNT_BYTES (MAX / 16)

section .data
    tape:    times COUNT_BYTES db 0xff

section .text
    global _start
_start:
    mov [tape], 0xfe
    mov esi, 0
main_loop_inc:
    inc esi
    cmp esi, COUNT_BYTES
    jge main_loop_out
    mov edi, esi
    shr edi, 0x3
    mov ecx, esi
    and ecx, 0x7
    mov eax, 1
    shl eax, cl
    add edi, tape
    mov edi, BYTE [edi]
    and edi, eax
    cmp edi, 0
    je  main_loop_inc
    jmp main_loop_inc
main_loop_out:
    mov rax, 60
    xor rdi, rdi
    syscall
