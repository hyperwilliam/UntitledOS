org 0x8000
bits 32


jmp short protected_mode ; jumps past the header, making this larger or smaller will break our second stage bootloader.
; Header, I'll Put A Lot Of Info About The Header If You Want To Use My Bootloader! (Well, My Stage 2 Bootloader...)
; This Spells Out:
db 0x48 ;"H"
db 0x44 ; "D"
db 0x52 ; "R"
db 0x32 ; This Describes What Mode To Start In, Most Useful For x86
db 0x86 ; Describes What Instruction Set This OS Is. Might Be Useful
db 0x01 ; Describes The Version Of The Header.
db 0x00 ; Rest Of These Are Reserved For Future Additions To Header,
times 32-($-$$) db 0
protected_mode:
mov eax, 0x0008
mov es, ax
mov [ypos], 5
   mov esi, string
   mov ah, 0x0B
   call print32
   mov esi, string2
   mov ah, 0x1F
   call print32
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
   mov al, 0x1f
   out 0x21, al
   call iowait
   mov al, 0x70
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
   mov al, 0xFD
   out 0x21, al
   mov al, 0xFF
   out 0xA1, al 
   mov esi, pic
   call print32
   mov esi, cmd
   call print32
   mov esi, chrPrompt
   call print32
   dec [ypos]
   mov [xpos], 2
   sti
   jmp $
   ; call ShellInit (This, Would In Theory Start The Shell, That Still, Is Not Ready.)

; -------- General Includes ---------
%include "src/kernel/idt.asm"
; %include "src/kernel/shell.asm" (Shell Isnt Ready Yet!)

string: db "32 Bit Mode!!!!", 0
string2: db "UntitledOS Alpha 1!", 0
pic: db "PIC Initialised!", 0
idt: db "IDT Loaded, Very Good!", 0
idt2: db "Interrupts Work, Awesome!", 0
cmd: db "Command Prompt Ready!"
buffer times 64 db 0
count db 0
xpos db 0
ypos db 0

print32:
push edi
mov edi, 0xB8000
push eax
movzx eax, byte [ypos]
xor edx, edx
mov dl, 160
mul dx
add edi, eax
movzx eax, byte [xpos]
mov dl, 2
mul dx
mov [value], eax
add edi, eax
pop eax
.print:
lodsb
or al, al
jz .inc
cmp al, 0xFE
jz .alt
stosw
jmp .print
.inc:
inc [ypos]
pop edi
ret
.alt:
inc [xpos]
pop edi
ret


value: dd 0x00
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
mov ah, 0x4C
mov esi, errorcode8
call print32
cli
hlt
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
push esi
xor eax, eax
in al,60h
call ScancodeConv
cmp al, 0xFF
jz End
pop esi
push esi
mov ah, 0x0F
cmp al, 0x0A
jz .enter
call calcCHR
jmp End
.enter:
inc [ypos]
mov [xpos], 0
mov esi, buffer
call compareSTR
mov esi, chrPrompt
call print32
dec [ypos]
mov [xpos], 2
End:
mov al,20h
out 20h,al
pop esi
iret

calcCHR:
mov [chrBuffer], al
mov esi, chrBuffer
call print32
ret

chrBuffer: db 33
db 0xfe

chrPrompt: db "> ", 0x00

compareSTR:
push edi
push eax
.loop:
mov edi, helloCmd
lodsb
cmp [edi], al
pushf
cmp al, 0x00
jz .end
popf
jmp .loop
.end:
popf
jz .valid
mov esi, invalid
call print32
jmp .ret
.valid:
mov esi, helloMsg
call print32
.ret:
pop eax
pop edi
ret

invalid: db "Invalid Command!", 0x00
helloMsg: db "Hello, World!", 0x00
helloCmd: db "hello", 0x00
;------------ Drivers ----------
%include "src/kernel/drivers/ps2.inc"

irq0:
mov al,20h
out 20h,al
iret ; we arent supposed to get this irq.

irq1:
mov al,20h
out 20h,al
iret


iowait:
push ax
mov al, 0x0000
out 0x80, al
pop ax
ret

isrs:
   cli
   mov [ypos], 0
   mov [xpos], 0
   mov ah, 0x7F
   mov esi, line
   call print32
   call drawerr
   mov ah, 0x4F
   mov [ypos], 1
   mov esi, err
   call print32
   mov esi, err2
   call print32
   dec [ypos]
   mov [xpos], 11
   ret

line: db "FATAL ERROR!                                                                    ", 0
err: db "UntitledOS Ran Into A Problem, And It Needs To Reboot.", 0 ;
err2: db "ERROR CODE:", 0
unhandlederr: db "UNRECOGNISED", 0

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
times 4096-($-$$) db 0
