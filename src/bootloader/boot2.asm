org 0x7E00
bits 16
jmp short main

DEBUG equ 1
HDRVER equ 0x01
CODE_SEG equ 0x08

main:
   ; check header
   xor ax, ax
   mov al, [0x8002]
   mov ah, [0x8003]
   mov si, 0x8002
   cmp ax, 0x4448
   jnz error
   mov bl, [0x8004]
   mov bh, [0x8007]
   cmp bl, 0x52
   jnz error
   cmp bh, HDRVER
   jnz error
   mov cl, [0x8006]
   cmp cl, 0x86
   jnz error2
   mov si, hdrmsg
   call bios_print
   mov ch, [0x8005]
   cmp ch, 0x64
   jz error3
   cmp ch, 0x16
   jz jmp
   cmp ch, 0x32
   jz jmp32
   jmp short $

jmp:
mov si, msg16
call bios_print
jmp 0x8000

jmp32:
mov si, msg32
call bios_print
lgdt [gdt_descriptor]
cli
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:0x8000


%if DEBUG
debug:
push ax
mov si, yes
call bios_print
pop ax
ret
%endif

error:
push ax
mov si, errmsg
call bios_print
pop ax
jmp short $

error2:
push ax
mov si, Arch_mismatch
call bios_print
pop ax
jmp short $

error3:
push ax
mov si, msg64
call bios_print
pop ax
jmp short $

; GDT, Taken From UntitledOS Legacy Branch
gdt_start:
    gdt_null:
    dd 0x0
    dd 0x0
    
    gdt_code:
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10011010b ; Flags
    db 11001111b ; Flags + Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)
    
    gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
    
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; GDT size
    dd gdt_start                 ; GDT address


bios_print:
   lodsb
   or al, al  ;zero=end of str
   jz done    ;GET OUT
   mov ah, 0x0E
   mov bh, 0
   int 0x10
   jmp bios_print
done:
   ret

msg64 db "ERROR: 64-BIT OPERATION IS NOT SUPPORTED YET", 13, 10, 0
errmsg db "FATAL: HEADER MISMATCH! You Need To Replace The Kernel.", 13, 10, 0
Arch_mismatch db "FATAL: ARCH MISMATCH! This Kernel Is Not Compatible With Your Computer.", 13, 10, 0
hdrmsg db "HEADER MATCHES, CONTINUING.", 13, 10, 0
msg32 db "MODE DETECTED: 32-BIT", 13, 10, 0
msg16 db "MODE DETECTED: 16-BIT", 13, 10, 0
%if DEBUG
yes db "debuggz", 13, 10, 0
%endif
bootdrive db 0
times 2048-($-$$) db 0
