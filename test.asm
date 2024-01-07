
test.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:	f3 0f 1e fa          	endbr64 
   4:	55                   	push   rbp
   5:	48 89 e5             	mov    rbp,rsp
   8:	48 83 ec 10          	sub    rsp,0x10
   c:	64 48 8b 04 25 28 00 	mov    rax,QWORD PTR fs:0x28
  13:	00 00 
  15:	48 89 45 f8          	mov    QWORD PTR [rbp-0x8],rax
  19:	31 c0                	xor    eax,eax
  1b:	c7 45 f4 61 62 63 64 	mov    DWORD PTR [rbp-0xc],0x64636261
  22:	0f b6 45 f5          	movzx  eax,BYTE PTR [rbp-0xb]
  26:	88 45 f3             	mov    BYTE PTR [rbp-0xd],al
  29:	0f be 45 f3          	movsx  eax,BYTE PTR [rbp-0xd]
  2d:	48 8b 55 f8          	mov    rdx,QWORD PTR [rbp-0x8]
  31:	64 48 2b 14 25 28 00 	sub    rdx,QWORD PTR fs:0x28
  38:	00 00 
  3a:	74 05                	je     41 <main+0x41>
  3c:	e8 00 00 00 00       	call   41 <main+0x41>
  41:	c9                   	leave  
  42:	c3                   	ret    

Disassembly of section .comment:

0000000000000000 <.comment>:
   0:	00 47 43             	add    BYTE PTR [rdi+0x43],al
   3:	43 3a 20             	rex.XB cmp spl,BYTE PTR [r8]
   6:	28 55 62             	sub    BYTE PTR [rbp+0x62],dl
   9:	75 6e                	jne    79 <main+0x79>
   b:	74 75                	je     82 <main+0x82>
   d:	20 31                	and    BYTE PTR [rcx],dh
   f:	31 2e                	xor    DWORD PTR [rsi],ebp
  11:	34 2e                	xor    al,0x2e
  13:	30 2d 31 75 62 75    	xor    BYTE PTR [rip+0x75627531],ch        # 7562754a <main+0x7562754a>
  19:	6e                   	outs   dx,BYTE PTR ds:[rsi]
  1a:	74 75                	je     91 <main+0x91>
  1c:	31 7e 32             	xor    DWORD PTR [rsi+0x32],edi
  1f:	32 2e                	xor    ch,BYTE PTR [rsi]
  21:	30 34 29             	xor    BYTE PTR [rcx+rbp*1],dh
  24:	20 31                	and    BYTE PTR [rcx],dh
  26:	31 2e                	xor    DWORD PTR [rsi],ebp
  28:	34 2e                	xor    al,0x2e
  2a:	30 00                	xor    BYTE PTR [rax],al

Disassembly of section .note.gnu.property:

0000000000000000 <.note.gnu.property>:
   0:	04 00                	add    al,0x0
   2:	00 00                	add    BYTE PTR [rax],al
   4:	10 00                	adc    BYTE PTR [rax],al
   6:	00 00                	add    BYTE PTR [rax],al
   8:	05 00 00 00 47       	add    eax,0x47000000
   d:	4e 55                	rex.WRX push rbp
   f:	00 02                	add    BYTE PTR [rdx],al
  11:	00 00                	add    BYTE PTR [rax],al
  13:	c0 04 00 00          	rol    BYTE PTR [rax+rax*1],0x0
  17:	00 03                	add    BYTE PTR [rbx],al
  19:	00 00                	add    BYTE PTR [rax],al
  1b:	00 00                	add    BYTE PTR [rax],al
  1d:	00 00                	add    BYTE PTR [rax],al
	...

Disassembly of section .eh_frame:

0000000000000000 <.eh_frame>:
   0:	14 00                	adc    al,0x0
   2:	00 00                	add    BYTE PTR [rax],al
   4:	00 00                	add    BYTE PTR [rax],al
   6:	00 00                	add    BYTE PTR [rax],al
   8:	01 7a 52             	add    DWORD PTR [rdx+0x52],edi
   b:	00 01                	add    BYTE PTR [rcx],al
   d:	78 10                	js     1f <.eh_frame+0x1f>
   f:	01 1b                	add    DWORD PTR [rbx],ebx
  11:	0c 07                	or     al,0x7
  13:	08 90 01 00 00 1c    	or     BYTE PTR [rax+0x1c000001],dl
  19:	00 00                	add    BYTE PTR [rax],al
  1b:	00 1c 00             	add    BYTE PTR [rax+rax*1],bl
  1e:	00 00                	add    BYTE PTR [rax],al
  20:	00 00                	add    BYTE PTR [rax],al
  22:	00 00                	add    BYTE PTR [rax],al
  24:	43 00 00             	rex.XB add BYTE PTR [r8],al
  27:	00 00                	add    BYTE PTR [rax],al
  29:	45 0e                	rex.RB (bad) 
  2b:	10 86 02 43 0d 06    	adc    BYTE PTR [rsi+0x60d4302],al
  31:	7a 0c                	jp     3f <main+0x3f>
  33:	07                   	(bad)  
  34:	08 00                	or     BYTE PTR [rax],al
	...
