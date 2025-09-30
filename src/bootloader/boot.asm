;
[ORG 0x7c00]

call Start
nop



Start:
   mov [bootdrive], dl
   xor ax, ax  ;make it zero
   mov ds, ax
   cld

   mov ah, 00h
   mov al, 03h
   int 10h

   mov si, msg
   call bios_print
   in al, 0x92
   or al, 2
   out 0x92, al
   mov si, A20
   call bios_print

; Load second stage (4 sectors for kernel)
mov ah, 0x02    ; BIOS read sector function
mov al, 4       ; Read 4 sectors for kernel
mov ch, 0       ; Cylinder 0
mov cl, 2       ; Sector 2 (sectors start at 1)
mov dh, 0       ; Head 0
mov dl, [bootdrive] ; Drive number from BIOS
mov bx, 0x7E00  ; Load to ES:BX = 0x0000:0x7E00

int 0x13        ; Call BIOS
jc error        ; Jump if error (carry flag set)

; Print success message
mov si, LOAD
call bios_print

   lgdt [gdt_descriptor]
   mov si, GDT
   call bios_print   

   cli
   mov eax, cr0
   or eax, 1
   mov cr0, eax
   jmp CODE_SEG:protected_mode
   



; GDT
gdt_start:
    ; Null descriptor
    dd 0x0
    dd 0x0
    
    ; Code segment descriptor
    dw 0xffff    ; Limit (bits 0-15)
    dw 0x0       ; Base (bits 0-15)
    db 0x0       ; Base (bits 16-23)
    db 10011010b ; Flags
    db 11001111b ; Flags + Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31)
    
    ; Data segment descriptor
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

hang:
   jmp hang

error:
  mov si, DER
  call bios_print

[bits 32]
protected_mode:
  mov al, 'P'
  mov ah, 0x0C
  mov [0xb8280], ax
  mov al, 'R'
  mov ah, 0x0E
  mov [0xb8282], ax
  mov al, 'O'
  mov ah, 0x0A
  mov [0xb8284], ax
  mov al, 'T'
  mov ah, 0x09
  mov [0xb8286], ax
  mov al, 'E'
  mov ah, 0x0B
  mov [0xb8288], ax
  mov al, 'C'
  mov ah, 0x0D
  mov [0xb828A], ax
  mov al, 'T'
  mov ah, 0x0F
  mov [0xb828C], ax
  mov al, 'E'
  mov ah, 0x0F
  mov [0xb828E], ax
  mov al, 'D'
  mov ah, 0x0F
  mov [0xb8290], ax
  mov al, '_'
  mov ah, 0x0F
  mov [0xb8292], ax
  mov al, 'I'
  mov ah, 0x0F
  mov [0xb8294], ax
  mov al, 'N'
  mov ah, 0x0F
  mov [0xb8296], ax
  mov al, 'I'
  mov ah, 0x0F
  mov [0xb8298], ax
  mov al, 'T'
  mov ah, 0x0F
  mov [0xb829A], ax
  jmp $

msg   db 'BOOT-INIT', 13, 10, 0
A20   db '[DEBUG] A20 LINE ENABLED BY: FAST A20', 13, 10, 0
GDT   db '[DEBUG] GDT LOADED, GET READY!', 13, 10, 0
LOAD  db '[DEBUG] KERNEL LOADED, NICE...', 13, 10, 0
DER   db 'ERROR: DISK FAILURE!', 13, 10, 0
bootdrive db 0
bios_print:
   lodsb
   or al, al  ;zero=end of str
   jz done    ;get out
   mov ah, 0x0E
   mov bh, 0
   int 0x10
   jmp bios_print
done:
   ret

   times 510-($-$$) db 0
   db 0x55
   db 0xAA
