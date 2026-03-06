:: You Might Need MSYS For this
mkdir build
nasm -felf32 src/bootloader/boot.asm -o build/boot.o
i686-elf-gcc -c src/kernel/kernel.c -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
i686-elf-gcc -T src/link.ld -o myos -ffreestanding -O2 -nostdlib build/boot.o build/kernel.o -lgcc
qemu-system-i386 -kernel myos
