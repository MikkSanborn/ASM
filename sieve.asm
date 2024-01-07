
BITS 64

%define MAX (0xffff)
%define COUNT_BYTES (MAX / 16)

%macro SYS_PRINT 1
    mov rdx, %1     ; count_chars
    mov rax, 1      ; 0x01 = sys_write
    mov rdi, 1      ; fd 1 = stdout
    mov rsi, str    ; char *buf
    syscall
%endmacro

section .data
    ; void* tape. Represents a boolean[COUNT_BYTES]
    tape:   times COUNT_BYTES db 0xff
    str:    times 16 db 0x00
    str_end:

section .text
    global _start

; An implementation of the sieve of Eratasthones in x86-64 ASM.
; "tape" contains a bit for each number that will be set to denote "prime" or
; non-prime. The "indecies" will skip even numbers, so to calculate a certain
; number's primeness (once completed), can be thought of as the `(num-1)/2-th'
; bit. To find if a specific number, num, is prime or not, test the value
; (*(tape + (num / 16)) & (1 << num & 0x7)).
;
;        00000111 11222223 33334444 ...
;        13579135 79135791 35791357 ...
;        |||||||| |||||||| ||||||||
; tape = 01110110 11010011 00101101 ...
;
; To test `num = 19 = 0x13 = 0b00010011', check the bit:
; *(tape + (num >> 4)) & (1 << ((num & 0b0..01110) >> 1))
; For example, 41 = 0x29 = 0b00101001 can be checked by testing the value
; `*(tape + 0b10) & (0b1 << 4)'
;
; The starting state of the program is a tape of 1's, The base cases are then
; handled (n = 1 set to false, skip n = 2 as it is implicit). From there, for
; each remaining bit, if it is true, leave it as true and mark all multiples of
; it as false. This process is done as follows (exapmle using n = 3):
;
; for (int i = 1; i < COUNT_BYTES; i++) {
;   if (!tape<i>) continue;
;   int n = i << 1 + 1; // i * 2 + 1
;   for (int j = 0; j < COUNT_BYTES; j += n) {
;       tape<i> = 0;
;   }
; }
;
_start:
; i, n, t1, j
; rsi, rdi, rdx, rcx, r8, r9, rax
; i = rsi, t1 = rdi
    ; initialize values and set tape<0> = 0
    mov BYTE [tape], 0xfe

    mov esi, 0

; for (int i = 1; i < COUNT_BYTES; i++)
main_loop_inc:
    ; i++
    inc esi

    ; i < COUNT_BYTES
    cmp esi, MAX ; COUNT_BYTES
    jge main_loop_out

    ; {
    ;   > test tape<i>
        ; B/t1 = rdi, b = rcx, m = rax
    xor rdi, rdi
    mov edi, esi                ; B = i >> 3
    shr edi, 0x3                ;

    mov ecx, esi                ; b = i & 0b0111
    and ecx, 0x7                ;

    mov eax, 1                  ; m = 1 << b
    shl eax, cl                 ;
        ; ecx free

    add rdi, tape               ; t1 = B + t1
;   mov edi, BYTE PTR [edi]     ; t1 = *(char *) t1
    mov dil, BYTE [rdi]         ; t1 = *(char *) t1
    and edi, eax                ; t1 = t1 & m
        ; eax free
    cmp edi, 0
    je  main_loop_inc
        ; edi free

        ; const i = esi
        ; const n = r8d
    mov r8d, esi                ; n = (i << 1) | 1 = (i*2) + 1
    shl r8d, 0x1                ;
    or  r8d, 0x1                ;
        ; j = eax
    mov eax, esi                ; j = i
        ; arr = rcx
inner_loop_inc:                 ; for (int j = i + n; j < COUNT_BYTES; j += n)
    ; j += n
    add eax, r8d

    ; if (j >= COUNT_BYTES) jmp main_loop_inc
    cmp eax, MAX ; COUNT_BYTES
    jge main_loop_inc

    ; {

        ; B, arr = r9
        ; m = rdx
        ; rcx used for shX

        ; REG CHECK --
            ;  ax = j
            ;  cx = <reserved for shift>
            ;  dx = >m
            ;  di = ___
            ;  si = i
            ;  r8 = n
            ;  r9 = >arr = &(tape<j>)

    xor r9 , r9                 ; (clear r9)
    mov r9d, eax                ; arr = tape + (j >> 3)
    shr r9d, 0x3                ;
    add r9 , tape               ;

    xor rcx, rcx                ; m = 1 << (j & 0x7)
    mov ecx, eax                ;
    and ecx, 0x7                ;
    mov rdx, 0x1                ;
    shl edx,  cl                ;
        ; ecx free (reserved)

    not edx                     ; m = ~m

    and BYTE [r9],  dl          ; *(tape + j) &= m
        ; r9, rdx free

    jmp inner_loop_inc
    ; }
main_loop_out: ; } // implicit, from GOTO used previously

        ; all regs free

    ; print "2\n"
    xor rax, rax
    mov DWORD [str], 0x0a32
    mov rax, 2

    SYS_PRINT rax

    mov rdx, COUNT_BYTES ; count_chars
    mov rax, 1      ; 0x01 = sys_write
    mov rdi, 1      ; fd 1 = stdout
    mov rsi, tape   ; char *buf
    syscall

; how to print this correctly/nicely:
        ; rcx, r8, r9 free?
;       ; i = rcx
;   xor rcx, rcx                ; i = 0
;print_loop_inc:
;   inc rcx

;   cmp rcx, COUNT_BYTES
;   jge print_loop_out

    ; for (i = 1; i < COUNT_BYTES; i++) {
    ;   if (tape<i> == 0) continue;
    ;   char *s = str;
    ;   *s = '\n';
    ;   s++/-- <-- find out, make sure to not destroy tape
    ;   int j = i;
    ;   while (j != 0) {
    ;     *s = 0x30 + j & 0b1111;
    ;     s++;
    ;     j = j >> 4;
    ;   }
    ; }

;   jmp print_loop_inc
;print_loop_out:

    ; exit
    mov rdi, 0x10
    mov rax, 60 ; syscall: exit
    ;xor rdi, rdi
    syscall
