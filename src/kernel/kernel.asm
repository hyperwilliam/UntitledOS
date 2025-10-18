org 0x8000
bits 16

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
   jmp short $


string: db "32 Bit Mode!!!!", 0
string2: db "NOTICE! You Are Using An EXPERIMENTAL Version Of UntitledOS", 0
idt: db "IDT Loaded, Very Good!", 0

print32:
   lodsb
   stosw
   or al, al
   jnz print32
   ret


; GDT, Taken From UntitledOS
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

; IDT Stub
idt_start:


idt_end:

idtr:
    dw idt_end - idt_start - 1
    dd idt_start


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

