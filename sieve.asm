
BITS 64

%define MAX_VAL (0x10000000)
%define MAX (MAX_VAL >> 1)
%define COUNT_BYTES (MAX_VAL >> 3)  ; MAX_VAL / 8 -- only odds, 8 bits = 1 byte

%define STR_LEN (0x1000)
%define STACK_SIZE (0x20)

%define tape r12

%macro SYS_PRINT 1
    mov rdx, %1     ; count_chars
    mov rax, 0x1    ; 0x01 = sys_write
    mov rdi, 0x1    ; fd 1 = stdout
    mov rsi, str
    syscall
%endmacro

section .data
    str:    times (STR_LEN + STACK_SIZE) db 0xff
    str_end:
    stack:  times STACK_SIZE db 0x0a

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

    ;; how to create space on the heap
        ; get original break
    mov rax, 0x0c
    mov rdi, 0x00
    syscall

    mov r12, rax                ; save base of heap

    mov rax, 0xc                ; rax = sys_brk
    mov rdi, r12                ; rdi = break + COUNT_BYTES (new loc)
    add rdi, COUNT_BYTES        ;
    syscall                     ; rax = sys_brk(COUNT_BYTES)

    mov r13, rax                ; store copy of end

    ; need to set all of "tape" as 1's
    ; >implicit< mov rsi, 0x0
    mov rax, r12
    mov rdi, r12
    add rdi, COUNT_BYTES

prefill_loop:
    cmp rax, rdi
    jge prefill_loop_out

    mov DWORD [rax      ], 0xffffffff
    mov DWORD [rax + 0x4], 0xffffffff

    add rax, 0x8
    jmp prefill_loop

prefill_loop_out:
    mov BYTE [tape], 0xfe

    xor rsi, rsi                ; clear rsi

; for (int i = 1; i < COUNT_BYTES; i++)
main_loop_inc:
    ; i++
    inc rsi

    ; i < COUNT_BYTES
    cmp rsi, MAX
    jge main_loop_out

    ; {
    ;   > test tape<i>
        ; B/t1 = rdi, b = rcx, m = rax
    xor rdi, rdi
    mov rdi, rsi                ; B = i >> 3
    shr rdi, 0x3                ;

    mov rcx, rsi                ; b = i & 0b0111
    and rcx, 0x7                ;

    mov rax, 0x1                ; m = 1 << b
    shl rax, cl                 ;
        ; rcx free

    add rdi, tape               ; t1 = B + t1

    ;; TODO CORRECT

    mov dil, BYTE [rdi]         ; t1 = *(char *) t1
    and rdi, rax                ; t1 = t1 & m
        ; rax free
    cmp rdi, 0x0
    je  main_loop_inc
        ; rdi free

        ; const i = rsi
        ; const n = r8 
    mov r8 , rsi                ; n = (i << 1) | 1 = (i*2) + 1
    shl r8 , 0x1                ;
    or  r8 , 0x1                ;
        ; j = rax
    mov rax, rsi                ; j = i
        ; arr = rcx
inner_loop_inc:                 ; for (int j = i + n; j < COUNT_BYTES; j += n)
    ; j += n
    add rax, r8 

    ; if (j >= COUNT_BYTES) jmp main_loop_inc
    cmp rax, MAX
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
    mov r9 , rax                ; arr = tape + (j >> 3)
    shr r9 , 0x3                ;
    add r9 , tape               ;

    xor rcx, rcx                ; m = 1 << (j & 0x7)
    mov rcx, rax                ;
    and rcx, 0x7                ;
    mov rdx, 0x1                ;
    shl rdx,  cl                ;
        ; rcx free (reserved)

    not rdx                     ; m = ~m

    and BYTE [r9],  dl          ; *(tape + j) &= m
        ; r9, rdx free

    jmp inner_loop_inc
    ; }
main_loop_out: ; }
        ; all regs free

%ifdef DEBUG
    ; for debug only --
    jmp print_lazy_and_exit
    ; -- end debug
%endif

    ; print "2\n"
    mov WORD [str], 0x0a32
    SYS_PRINT 0x2

    mov r9 , 0x1                ; set buf to 1

; how to print this correctly/nicely:
        ; rcx, ~r8~, r9 free/safe
        ; rsi, rdi, rdx, rax are temp
        ; i = r8
    xor r8 , r8                 ; i = 0
print_loop_inc:             ; for (int i = 1; i < MAX; i++) {
    xor r11, r11                ; count_digits = 0;
    inc r8                      ; i++

    cmp r8 , MAX                ; if (i >= MAX) break;
    jge print_loop_out          ;

    ; B/t1 = rdi, b = rcx, m = rax
    xor rdi, rdi                ; B = i >> 3
    mov rdi, r8                 ;
    shr rdi, 0x3                ;

    ; TODO potential optimization here by inlining the 8 consecutive
        ; iterations of checking this individual byte.
    mov rcx, r8                 ; b = i & 0b0111
    and rcx, 0x7                ;

    mov rax, 0x1                ; m = 1 << b
    shl rax,  cl

    add rdi, tape               ; t1 = B + t1
    mov dil, BYTE [rdi]         ; t1 = *(char *) t1
    and rdi, rax                ; t1 = t1 & m

    cmp rdi, 0x0                ; if (tape<i> == 0) continue;
    je print_loop_inc           ;
        ; rax, rdi free, rcx <reserved>

    ; count = r9
    ; j = rax
    ;     rdi reserved for division!
    mov rax, r8                 ; j = 2*i + 1; // can modify j without destroying i
    shl rax, 0x1                ;
    or  rax, 0x1

calc_loop:
    cmp rax, 0x0                ; if (j <= 0) break; // don't have to worry
    jle calc_loop_exit          ;       about numbers ending in "0" as they
                                ;       are always composite (n*10)

    inc r9                      ; count++; // pre-increment to keep string
                                ;             accurate

    ; divide
    cdq
    mov rcx, 0xa                ; must use reg, div by 10
    idiv rcx                    ; divide by 10 (0xa)

    add rdx, 0x30               ; char c = (j % 10) + 0x30;
    mov rcx, stack
    add rcx, r11
    mov BYTE [rcx], dl         ; *(str + count) = c;
    inc r11                     ; count_digits++;

    jmp calc_loop           ; }

calc_loop_exit:

    ; numbers are in wrong order, need to switch
    mov rax, str - 0x1
    add rax, r9
    sub rax, r11
swap_nums_loop:
    mov dl, BYTE [rcx]
    mov BYTE [rax], dl

    inc rax
    dec rcx

    cmp rcx, stack
    jge swap_nums_loop

swap_nums_complete:

    inc r9
    mov BYTE [rax], 0x0a

    cmp r9 , STR_LEN
    jl  print_loop_inc

    dec r9
    SYS_PRINT r9                ; print output

    mov r9 , 0x1

    jmp print_loop_inc
                            ; }
print_loop_out:
    dec r9
    SYS_PRINT r9                ; print remaining output

    mov rax, 0x0c   ; reset the heap
    mov rdi, r12    ;
    syscall         ;

    ; exit
    mov rdi, 0x0    ; return code 0
    mov rax, 0x3c   ; syscall: exit
    syscall

%ifdef DEBUG
print_lazy_and_exit:
        ; temporary byte dump
    mov rdx, COUNT_BYTES ; count_chars
    mov rax, 0x1    ; 0x01 = sys_write
    mov rdi, 0x1    ; fd 1 = stdout
    mov rsi, tape   ; char *buf
    syscall

    ; exit
    mov rdi, 0x0    ; return code 0
    mov rax, 0x3c   ; syscall: exit
    syscall
%endif

