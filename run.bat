:: I Designed This Script To Run On Windows!
nasm -f bin src/bootloader/boot.asm -o build/boot.bin
qemu-system-i386 -fda build/boot.bin
