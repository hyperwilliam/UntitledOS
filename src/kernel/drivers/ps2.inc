; PS/2 Driver, Probably Not The Best, But It Will Work (better with the power of lookup tables!)
bits 32
ScancodeConv:
push ax
xor eax,eax
pop ax
cmp al, 0x2A
jz shiftpressed
cmp al, 0xAA
jz shiftreleased
cmp al, 0x36
jz shiftpressed
cmp al, 0xB6
jz shiftreleased
mov bl, [shifted]

mov esi, scancode_to_ascii_map
add esi, eax
add si,bx
mov al, [esi]

ret

scancode_to_ascii_map:
    db 0, 27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', 8
    db 9, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 10
    db 0, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', 39, '`'
    db 0, 92, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, '*', 0, ' '
    times 168 db 0xff
scancode_to_shifted_ascii_map:
    db 0, 27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', 8
    db 9, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 10
    db 0, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~'
    db 0, '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0, '*', 0, ' '
    times 168 db 0xff
shifted: db 0x00

shiftpressed:
mov [shifted], 0xE2
mov al, 0xFF
ret

shiftreleased:
mov [shifted], 0x00
mov al, 0xFF
ret
