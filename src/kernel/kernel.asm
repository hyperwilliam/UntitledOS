org 0x8000
bits 16
jmp main

%include "src/kernel/idt.asm"
; %include "src/kernel/shell.asm" (Shell Isnt Ready Yet!)

bits 16

main:

mov si, msg
call bios_print
lgdt [gdt_descriptor]
mov si, msg2
call bios_print
cli
mov eax, cr0
or eax, 1
mov cr0, eax
jmp CODE_SEG:protected_mode

bits 32
protected_mode:
   mov edi, 0xB8320
   mov esi, string
   mov ah, 0x0B
   call print32
   mov edi, 0xB83C0
   mov esi, string2
   mov ah, 0x1F
   call print32
   mov edi, 0xB8460
   mov esi, idt
   mov ah, 0x0F
   lidt [idtr]
   call print32
   mov al, 0x11
   mov dx, 0x20
   out dx, al
   call iowait
   mov al, 0x11
   mov dx, 0xA0
   out dx, al
   call iowait
   mov al, 0x20
   out 0x21, al
   call iowait
   mov al, 0x30
   out 0xA1, al
   call iowait
   mov al, 0x02
   out 0x21, al
   call iowait
   mov al, 2
   out 0xA1, al
   call iowait
   mov al, 1
   out 0x21, al
   call iowait
   out 0xA1, al
   call iowait
   mov al, 0xFE
   out 0x21, al
   out 0xA1, al 
   mov esi, pic
   mov edi, 0xB8500
   call print32
   mov edi, 0xB85A0
   sti
   jmp $ ;shell isnt ready yet, also it gives a #UD Exception Not Long after enabling interrupts.


string: db "32 Bit Mode!!!!", 0
string2: db "UntitledOS Pre-Alpha Revision 5!", 0
pic: db "PIC Initialised!", 0
idt: db "IDT Loaded, Very Good!", 0
idt2: db "Interrupts Work, Awesome!", 0
print32:
   lodsb
   stosw
   or al, al
   jnz print32
   ret

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

; Constants
CODE_SEG equ 0x08
DATA_SEG equ 0x10

isr0:
call isrs
mov esi, errorcode0
call print32
jmp short $

isr1:
call isrs
mov esi, errorcode1
call print32
jmp short $


isr2:
call isrs
mov esi, errorcode2
call print32
jmp short $


isr3:
mov esi, brkp
call print32
iret

isr4:
call isrs
mov esi, errorcode4
call print32
jmp short $

isr5:
call isrs
mov esi, errorcode5
call print32

isr6:
call isrs
mov esi, errorcode6
call print32
jmp short $

isr7:
call isrs
mov esi, errorcode7
call print32
jmp short $

isr8:
call isrs
mov esi, errorcode8
call print32
jmp short $

isr9:
call isrs
mov esi, errorcode9
call print32
jmp short $

isrA:
call isrs
mov esi, errorcodeA
call print32
jmp short $

isrB:
call isrs
mov esi, errorcodeB
call print32
jmp short $

isrC:
call isrs
mov esi, errorcodeC
call print32
jmp short $

isrD:
call isrs
mov esi, errorcodeD
call print32
jmp short $

isrE:
call isrs
mov esi, errorcodeE
call print32
jmp short $

Reserved:
call isrs
mov esi, reserved
call print32
jmp short $

isr10:
call isrs
mov esi, errorcode10
call print32
jmp short $

isr11:
call isrs
mov esi, errorcode11
call print32
jmp short $

isr12:
call isrs
mov esi, errorcode12
call print32
jmp short $

isr13:
call isrs
mov esi, errorcode13
call print32
jmp short $

isr14:
call isrs
mov esi, errorcode14
call print32
jmp short $

isr15:
call isrs
mov esi, errorcode15
call print32
jmp short $

irq0:
iret

iowait:
push ax
mov ax, 0x0000
out 0x80, al
pop ax
ret

isrs:
   mov edi, 0xB8000
   mov ah, 0x7F
   mov esi, line
   call print32
   call drawerr
   mov ah, 0x4F
   mov edi, 0xB80A0
   mov esi, err
   call print32
   mov esi, err2
   add byte edi, 50
   call print32
   ret

line: db "FATAL ERROR!                                                                   ", 0
err: db "UntitledOS Ran Into A Problem, And It Needs To Reboot.", 0 ;
err2: db "ERROR CODE:", 0
unhandlederr: db "UNRECOGNISED", 0

brkp: db "Breakpoint Interrupt Received!", 0
errorcode0: db "#DE", 0
errorcode1: db "#DB", 0
errorcode2: db "NMI", 0
errorcode4: db "#OF", 0
errorcode5: db "#BR", 0
errorcode6: db "#UD", 0
errorcode7: db "#NM", 0
errorcode8: db "#DF", 0
errorcode9: db "CSO", 0
errorcodeA: db "#TS", 0
errorcodeB: db "#NP", 0
errorcodeC: db "#SS", 0
errorcodeD: db "#GP", 0
errorcodeE: db "#PF", 0
errorcode10: db "#MF", 0
errorcode11: db "#AC", 0
errorcode12: db "#MC", 0
errorcode13: db "#XM", 0
errorcode14: db "#VE", 0
errorcode15: db "Control Protection", 0
reserved:   db "Reserved Interrupt!", 0

drawerr:
   mov ah, 0x44
   mov esi, line
   call print32
   add byte [counter], -1
   jnz drawerr
   mov ah, 0x77
   mov esi, line
   call print32
   ret
counter: db 23




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
msg db 'Stage 2 Entered, Very Good!', 13, 10, 0
msg2  db 'GDT Loaded!', 13, 10, 0
xpos db 0
ypos db 0
times 4096-($-$$) db 0
