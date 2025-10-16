org 0x7c00
bits 16

jmp short INIT
nop

OEMLabel		db "BOOT    "	; Disk label
BytesPerSector		dw 512		; Bytes per sector
SectorsPerCluster	db 1		; Sectors per cluster
ReservedForBoot		dw 1		; Reserved sectors for boot record
NumberOfFats		db 2		; Number of copies of the FAT
RootDirEntries		dw 224		; Number of entries in root dir
					; (224 * 32 = 7168 = 14 sectors to read)
LogicalSectors		dw 2880		; Number of logical sectors
MediumByte		db 0F0h		; Medium descriptor byte
SectorsPerFat		dw 9		; Sectors per FAT
SectorsPerTrack		dw 18		; Sectors per track (36/cylinder)
Sides			dw 2		; Number of sides/heads
HiddenSectors		dd 0		; Number of hidden sectors
LargeSectors		dd 0		; Number of LBA sectors
DriveNo			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 for floppy
VolumeID		dd 00000000h	; Volume ID: any number
VolumeLabel		db "MyBOOT     "; Volume Label: any 11 chars
FileSystem		db "FAT12   "	; File system type: don't change!

INIT:
   mov [bootdrive], dl
   xor ax, ax
   mov ds, ax
   mov es, ax ; recommended by redditor z3r0OS, Hope It Works!
   cld
   mov ah, 00h
   mov al, 03h
   int 10h
   mov si, msg
   call bios_print
   in al, 0x92
   or al, 2
   out 0x92, al
   mov si, msg3
   call bios_print
   mov ah, 0x02    ; BIOS read sector function
   mov al, 16       ; Read 16 sectors for the kernel
   mov ch, 0       ; Cylinder 0
   mov cl, 2       ; Sector 2 (sectors start at 1)
   mov dh, 0       ; Head 0
   mov dl, [bootdrive]
   mov bx, 0x8000  ; Load to ES:BX = 0x0000:0x8000

   int 0x13        ; Call BIOS
   jc halt        ; Jump if error (carry flag set)
   mov si, msg4
   call bios_print
   jmp 0x8000

halt:
  mov si, msg2
  call bios_print
  jmp $

msg   db 'Bootloader Works, Very Good!', 13, 10, 0
msg2  db 'Disk Error, Guess It Didnt Work For Very Long, heh!', 13, 10, 0
msg3  db 'A20 Line Enabled', 13, 10, 0

msg4   db 'Stage 2 Loaded, Very Good', 13, 10, 0
bootdrive db 0


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

   times 510-($-$$) db 0
   db 0x55
   db 0xAA
