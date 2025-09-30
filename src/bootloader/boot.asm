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

; Load second stage (4 sectors for the kernel)
mov ah, 0x02    ; BIOS read sector function
mov al, 16       ; Read 16 sectors for the kernel
mov ch, 0       ; Cylinder 0
mov cl, 2       ; Sector 2 (sectors start at 1)
mov dh, 0       ; Head 0
mov dl, [bootdrive] ; Drive number from BIOS
mov bx, 0x8000  ; Load to ES:BX = 0x0000:0x7E00

int 0x13        ; Call BIOS
jc error        ; Jump if error (carry flag set)

; Print success message
mov si, LOAD
call bios_print

   lgdt [gdt_descriptor]
   mov si, GDT
   call bios_print   

   mov ax, 0x4F02  ; VESA set mode function
   mov bx, 0x4118  ; Mode number and LFB/DM flags
   int 0x10        ; Call VESA BIOS
   cmp ax, 0x004F
   jne errorvesa

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
errorvesa:
  mov si, VESAERROR
  call bios_print


[bits 32]
protected_mode:
  jmp 0x7E00

msg   db 'BOOT-INIT', 13, 10, 0
A20   db '[DEBUG] A20 LINE ENABLED BY: FAST A20... Probably We Dont Check If It Worked...', 13, 10, 0
GDT   db '[DEBUG] GDT LOADED, GET READY!', 13, 10, 0
LOAD  db '[DEBUG] KERNEL LOADED, NICE...', 13, 10, 0
DER   db 'ERROR: DISK FAILURE!', 13, 10, 0
VESAERROR   db 'ERROR: UNSUPPORTED VESA... Probably I dont really know', 13, 10, 0
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
