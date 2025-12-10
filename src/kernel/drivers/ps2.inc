; PS/2 Driver, Probably Not The Best, But It Will Work
bits 32
ScancodeConv:
cmp al, 0x02
jz Key1
cmp al, 0x03
jz Key2
cmp al, 0x04
jz Key3
cmp al, 0x05
jz Key4
cmp al, 0x06
jz Key5
cmp al, 0x07
jz Key6
cmp al, 0x08
jz Key7
cmp al, 0x09
jz Key8
cmp al, 0x0A
jz Key9
cmp al, 0x0B
jz Key0
cmp al, 0x82
jz KeyRel
cmp al, 0x83
jz KeyRel
cmp al, 0x84
jz KeyRel
cmp al, 0x85
jz KeyRel
cmp al, 0x86
jz KeyRel
cmp al, 0x87
jz KeyRel
cmp al, 0x88
jz KeyRel
cmp al, 0x89
jz KeyRel
cmp al, 0x8A
jz KeyRel
cmp al, 0x8B
jz KeyRel
cmp al, 0x1E
jz KeyA
cmp al, 0x30
jz KeyB
cmp al, 0x2E
jz KeyC
cmp al, 0x20
jz KeyD
cmp al, 0x12
jz KeyE
cmp al, 0x21
jz KeyF
cmp al, 0x22
jz KeyG
cmp al, 0x23
jz KeyH
cmp al, 0x17
jz KeyI
cmp al, 0x24
jz KeyJ
cmp al, 0x25
jz KeyK
cmp al, 0x26
jz KeyL
cmp al, 0x32
jz KeyM
cmp al, 0x31
jz KeyN
cmp al, 0x18
jz KeyO
cmp al, 0x19
jz KeyP
cmp al, 0x10
jz KeyQ
cmp al, 0x13
jz KeyR
cmp al, 0x1F
jz KeyS
cmp al, 0x14
jz KeyT
cmp al, 0x16
jz KeyU
cmp al, 0x2F
jz KeyV
cmp al, 0x11
jz KeyW
cmp al, 0x2D
jz KeyX
cmp al, 0x15
jz KeyY
cmp al, 0x2C
jz KeyZ
cmp al, 0x39
jz KeySpace
jnz KeyRel
ret
Key1:
mov al, 0x31
ret
Key2:
mov al, 0x32
ret
Key3:
mov al, 0x33
ret
Key4:
mov al, 0x34
ret
Key5:
mov al, 0x35
ret
Key6:
mov al, 0x36
ret
Key7:
mov al, 0x37
ret
Key8:
mov al, 0x38
ret
Key9:
mov al, 0x39
ret
Key0:
mov al, 0x30
ret
KeyA:
mov al, 0x41
ret
KeyB:
mov al, 0x42
ret
KeyC:
mov al, 0x43
ret
KeyD:
mov al, 0x44
ret
KeyE:
mov al, 0x45
ret
KeyF:
mov al, 0x46
ret
KeyG:
mov al, 0x47
ret
KeyH:
mov al, 0x48
ret
KeyI:
mov al, 0x49
ret
KeyJ:
mov al, 0x4A
ret
KeyK:
mov al, 0x4B
ret
KeyL:
mov al, 0x4C
ret
KeyM:
mov al, 0x4D
ret
KeyN:
mov al, 0x4E
ret
KeyO:
mov al, 0x4F
ret
KeyP:
mov al, 0x50
ret
KeyQ:
mov al, 0x51
ret
KeyR:
mov al, 0x52
ret
KeyS:
mov al, 0x53
ret
KeyT:
mov al, 0x54
ret
KeyU:
mov al, 0x55
ret
KeyV:
mov al, 0x56
ret
KeyW:
mov al, 0x57
ret
KeyX:
mov al, 0x58
ret
KeyY:
mov al, 0x59
ret
KeyZ:
mov al, 0x5A
ret
KeySpace:
mov al, 0x00
ret
KeyRel:
mov al, 0xFF
ret